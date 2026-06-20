#!/usr/bin/env bash
# ============================================================================
# 用 ayaka-notes/texlive-full 镜像复现 Overleaf 项目的编译
# Reproduce an Overleaf project's compile using the ayaka-notes/texlive-full image
#
# 它做了什么 / What it does:
#   1) 从 Overleaf 只读分享链接下载项目 zip / download the project zip from a read share link
#   2) 解出编译器 / TeXLive 年份 / 主文件 / resolve compiler, TeX Live year, main file
#   3) 在我们的镜像里用 latexmk 编译（与 Overleaf CLSI 相同的命令）
#      compile with latexmk inside our image (same command as Overleaf's CLSI)
#   4) 收集 output.log / stdout / stderr / pdf / collect the logs and pdf
#
# 用法 / Usage:
#   scripts/overleaf-compile-test.sh \
#       --link  "https://www.overleaf.com/read/xxxx#yyyy" \
#       --compiler pdflatex|xelatex|lualatex|latex \   # 必填，无 auto / required, no auto
#       --texlive  2026|2025|2024|2023|2022|2021|2020 \ # 必填，无 auto / required, no auto
#       [--main   path/to/main.tex] \
#       [--registry ghcr.io/ayaka-notes/texlive-full] \
#       [--timeout 600] \
#       [--out    ./compile-result]
# ============================================================================
set -uo pipefail

# ---- 默认值 / defaults ----
LINK=""
COMPILER=""                  # 必填，由用户/表单提供，无自动探测 / required from user/form, no auto-detection
TEXLIVE=""                   # 必填 / required
MAIN=""
REGISTRY="ghcr.io/ayaka-notes/texlive-full"
TIMEOUT="600"
OUT="./compile-result"
IMAGE_USER="tex"             # 与 Overleaf 默认编译镜像一致 / matches Overleaf's default compile image user
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- 解析参数 / parse args ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --link)     LINK="$2"; shift 2;;
    --compiler) COMPILER="$2"; shift 2;;
    --texlive)  TEXLIVE="$2"; shift 2;;
    --main)     MAIN="$2"; shift 2;;
    --registry) REGISTRY="$2"; shift 2;;
    --timeout)  TIMEOUT="$2"; shift 2;;
    --out)      OUT="$2"; shift 2;;
    --user)     IMAGE_USER="$2"; shift 2;;
    -h|--help)  grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    *) echo "未知参数 / unknown arg: $1" >&2; exit 2;;
  esac
done

if [[ -z "$LINK" ]]; then
  echo "错误：必须提供 --link / Error: --link is required" >&2
  exit 2
fi

# 规范化空白输入（来自 issue 表单的 "_No response_" 等）/ normalise empty inputs from issue forms
norm() { local v="${1//$'\r'/}"; v="$(echo "$v" | xargs 2>/dev/null)"; case "$v" in ""|"_No response_"|"自动检测"|"自动"|"Auto"|"auto"|"Auto-detect"|"Auto (latest)"|"自动 / Auto") echo "auto";; *) echo "$v";; esac; }
COMPILER="$(norm "$COMPILER")"
TEXLIVE="$(norm "$TEXLIVE")"
MAIN_RAW="$MAIN"; MAIN="$(echo "${MAIN//$'\r'/}" | xargs 2>/dev/null)"
[[ "$MAIN" == "_No response_" ]] && MAIN=""

# ============================================================================
# 严格校验所有输入，杜绝命令注入 / strictly validate all inputs, no command injection
# 这些值最终会进入 shell / docker / 网络请求，必须先白名单校验。
# These values flow into shell / docker / network requests, so allowlist them first.
# ============================================================================
fail_input() {
  echo "❌ 输入校验失败 / invalid input: $1" >&2
  mkdir -p "$OUT"
  {
    echo "## ❌ 输入校验失败 / Invalid input"
    echo
    echo "$1"
    echo
    echo "请检查 issue 表单内容后重试。/ Please fix the issue form and retry."
  } > "$OUT/summary.md"
  echo "status=invalid_input" > "$OUT/result.env"
  echo "pdf=no" >> "$OUT/result.env"
  exit 11
}

# 链接：必须是 https 且主机属于 overleaf.com（防 SSRF），路径/锚点仅限安全字符
# link: must be https on an overleaf.com host (anti-SSRF); path/anchor restricted to safe chars
if ! [[ "$LINK" =~ ^https://([a-z0-9-]+\.)*overleaf\.com/(read/[A-Za-z0-9]+|[A-Za-z0-9]+)(#[A-Za-z0-9]+)?$ ]]; then
  fail_input "Overleaf 链接格式不合法或主机不是 overleaf.com / link is malformed or host is not overleaf.com: \`${LINK}\`"
fi
# 编译器白名单（必须明确选择，不接受 auto/自动探测）/ compiler allowlist (must be explicit; no auto-detection)
case "$COMPILER" in
  pdflatex|xelatex|lualatex|latex) ;;
  *) fail_input "请在表单里明确选择编译器（pdflatex/xelatex/lualatex/latex），不支持 auto / select a specific compiler; 'auto' is not supported: \`${COMPILER}\`";;
esac
# TeXLive 年份白名单（必须明确选择，不接受 auto）/ year allowlist (must be explicit; no auto)
if ! [[ "$TEXLIVE" =~ ^202[0-6]$ ]]; then
  fail_input "请在表单里明确选择 TeX Live 年份（2020–2026），不支持 auto / select a specific TeX Live year (2020–2026); 'auto' is not supported: \`${TEXLIVE}\`"
fi
# 主文件：可空；若给定必须是安全的相对 .tex 路径，禁止 .. 与绝对路径
# main file: optional; if given, must be a safe relative .tex path, no .. and no absolute path
if [[ -n "$MAIN" ]]; then
  if [[ "$MAIN" == /* || "$MAIN" == *".."* || ! "$MAIN" =~ ^[A-Za-z0-9._/\ -]+\.tex$ ]]; then
    fail_input "主文件路径不合法 / invalid main file path: \`${MAIN}\`"
  fi
fi

mkdir -p "$OUT"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
SUMMARY="$OUT/summary.md"
: > "$SUMMARY"

say() { echo "$@"; }
note() { echo "$@" >> "$SUMMARY"; }

say "==> 1/5 从 Overleaf 下载项目 / downloading project from Overleaf"
if ! node "$SCRIPT_DIR/overleaf-fetch.mjs" --link "$LINK" --zip "$WORK/project.zip" --meta "$WORK/meta.json"; then
  note "❌ **下载失败 / Download failed** — 链接可能失效、未开启只读分享，或不是 \`/read/\` 链接。"
  note "❌ The link may be invalid, link-sharing may be off, or it is not a \`/read/\` link."
  exit 7
fi

# 读取元数据（仅 projectId，不做任何编译器/年份的自动探测）/ read metadata (only projectId; no auto-detection of compiler/year)
META="$WORK/meta.json"
get_meta() { node -e "const m=require('$META');process.stdout.write(String(m['$1']??''))" 2>/dev/null; }
PROJECT_NAME="$(get_meta projectId)"

say "==> 2/5 解压项目 / unpacking project"
SRC="$WORK/src"
mkdir -p "$SRC"
unzip -q -o "$WORK/project.zip" -d "$SRC" || { note "❌ 解压失败 / unzip failed"; exit 8; }

# ---- 解析主文件 / resolve main file ----
# 优先级 / precedence: 用户指定 > 自动检测(含 \documentclass 与 \begin{document})
# 说明：主文件只是“定位根 .tex 文件”，与编译器/年份无关；用户留空时才按文件内容定位。
# Note: this only LOCATES the root .tex file; it is unrelated to compiler/year. Used only when the user leaves it blank.
if [[ -n "$MAIN" ]]; then
  MAIN_REL="$MAIN"
else
  MAIN_REL=""
fi

find_main() {
  # 找同时含 \documentclass 和 \begin{document} 的 .tex，取路径最短者 / shortest .tex with both markers
  local best="" bestdepth=9999 f depth
  while IFS= read -r -d '' f; do
    if grep -lqE '\\documentclass' "$f" && grep -lqE '\\begin\{document\}' "$f"; then
      depth=$(awk -F/ '{print NF}' <<<"$f")
      if (( depth < bestdepth )); then bestdepth=$depth; best="$f"; fi
    fi
  done < <(find "$SRC" -type f -iname '*.tex' -print0)
  [[ -n "$best" ]] && printf '%s' "${best#$SRC/}"
}

if [[ -n "$MAIN_REL" && -f "$SRC/$MAIN_REL" ]]; then
  : # 使用给定值 / use as-is
else
  DETECTED_MAIN="$(find_main)"
  if [[ -z "$DETECTED_MAIN" ]]; then
    note "❌ **找不到主文件 / Main file not found** — 未发现同时包含 \`\\documentclass\` 和 \`\\begin{document}\` 的 .tex。请在 issue 中填写主文件路径。"
    note "❌ No .tex containing both \`\\documentclass\` and \`\\begin{document}\` was found. Please specify the main file path in the issue."
    exit 9
  fi
  if [[ -n "$MAIN_REL" ]]; then
    say "    指定的主文件不存在，改用自动检测 / specified main not found, using auto-detected: $DETECTED_MAIN"
  fi
  MAIN_REL="$DETECTED_MAIN"
fi
MAIN_DIR="$(dirname "$SRC/$MAIN_REL")"
MAIN_BASE="$(basename "$MAIN_REL")"

# ---- 编译器：严格按用户在表单里的选择，不做任何自动探测 ----
# ---- compiler: strictly the user's choice from the form; no auto-detection ----
COMPILER_SRC="用户选择 / user-selected"  # 已在顶部白名单校验过 / already allowlist-validated at the top

# latexmk 引擎参数（与 CLSI 一致）/ latexmk engine flag (matches CLSI)
case "$COMPILER" in
  latex)    ENGINE_FLAG="-pdfdvi";;
  pdflatex) ENGINE_FLAG="-pdf";;
  xelatex)  ENGINE_FLAG="-xelatex";;
  lualatex) ENGINE_FLAG="-lualatex";;
esac

# ---- TeXLive 年份：严格按用户选择（已在顶部校验为 2020–2026）/ year: strictly the user's choice (validated 2020–2026 above) ----
YEAR_SRC="用户选择 / user-selected"
IMAGE="${REGISTRY}:${TEXLIVE}.1"

say "==> 3/5 拉取镜像 / pulling image: $IMAGE"
if ! docker pull "$IMAGE"; then
  note "❌ **拉取镜像失败 / Failed to pull image** \`$IMAGE\` — 请确认该 TeXLive 年份的镜像存在。"
  note "❌ Please verify the image for this TeX Live year exists."
  exit 10
fi

# ---- 编译命令（复刻 CLSI LatexRunner）/ compile command (replicates CLSI LatexRunner) ----
# latexmk -cd -jobname=output -auxdir=/compile -outdir=/compile -synctex=1 \
#         -interaction=batchmode -time -f <engine> /compile/<main>
LATEXMK_CMD=(latexmk -cd -jobname=output -auxdir=/compile -outdir=/compile \
  -synctex=1 -interaction=batchmode -time -f "$ENGINE_FLAG" "/compile/$MAIN_BASE")

# 让镜像里的 tex 用户可写 / make the compile dir writable by the image's tex user
chmod -R a+rwX "$MAIN_DIR" 2>/dev/null || true

say "==> 4/5 编译 / compiling: $COMPILER on TeXLive $TEXLIVE (main: $MAIN_REL)"
say "    docker run ... $IMAGE ${LATEXMK_CMD[*]}"
START=$(date +%s)
# 与 CLSI 完全一致的容器环境 / container env identical to CLSI
#   - HOME=/tmp, CLSI=1 (Settings.clsi.docker.env)
#   - PATH 同 DockerRunner.js（含当年 texlive bin）/ PATH as in DockerRunner.js (with that year's texlive bin)
TL_BIN="/usr/local/texlive/${TEXLIVE}/bin/x86_64-linux"
CLSI_PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${TL_BIN}/"
# 沙箱化（对齐 CLSI DockerRunner）：无网络、丢弃全部能力、禁止提权、CPU ulimit、seccomp 白名单
# Sandbox (matches CLSI DockerRunner): no network, drop ALL caps, no-new-privileges, CPU ulimit, seccomp allowlist
# 容器内不含任何密钥 / no secrets inside the container.
SECCOMP_FILE="$SCRIPT_DIR/clsi-seccomp.json"      # 来自 Overleaf CLSI / vendored from Overleaf CLSI
SECCOMP_OPT=()
[[ -f "$SECCOMP_FILE" ]] && SECCOMP_OPT=(--security-opt "seccomp=$SECCOMP_FILE")
docker run --rm \
  --user "$IMAGE_USER" \
  --network none \
  --security-opt no-new-privileges \
  "${SECCOMP_OPT[@]}" \
  --cap-drop ALL \
  --pids-limit 512 \
  --ulimit "cpu=$((TIMEOUT+5)):$((TIMEOUT+10))" \
  -v "$MAIN_DIR":/compile \
  -w /compile \
  -e HOME=/tmp \
  -e CLSI=1 \
  -e PATH="$CLSI_PATH" \
  --memory=2g \
  --stop-timeout=10 \
  "$IMAGE" \
  timeout "${TIMEOUT}s" "${LATEXMK_CMD[@]}" \
  > "$OUT/output.stdout" 2> "$OUT/output.stderr"
STATUS=$?
END=$(date +%s)
ELAPSED=$((END-START))

say "==> 5/5 收集日志 / collecting logs"
# 从编译目录拷出产物 / copy artifacts out of the compile dir
for f in output.log output.pdf output.synctex.gz output.fls output.fdb_latexmk output.blg; do
  [[ -f "$MAIN_DIR/$f" ]] && cp "$MAIN_DIR/$f" "$OUT/" 2>/dev/null || true
done

PDF_OK=no; [[ -f "$OUT/output.pdf" ]] && PDF_OK=yes
PDF_SIZE=0; [[ -f "$OUT/output.pdf" ]] && PDF_SIZE=$(stat -c%s "$OUT/output.pdf")

# 若有 PDF，用镜像里的 ghostscript 渲染首页预览图（尽力而为）/ if a PDF exists, render a first-page preview via ghostscript (best-effort)
# 写到编译目录（$MAIN_DIR=/compile，tex 用户已可写，刚成功写了 output.pdf）再拷到 $OUT，
# 避免 CI 上 runner(uid 1001) 与镜像 tex(uid 1000) 的属主不一致导致无法写入 $OUT。
# Write into the compile dir (/compile, already writable by tex — it just wrote output.pdf), then copy to $OUT;
# this avoids the CI uid mismatch (runner uid 1001 vs image tex uid 1000) that blocked writing into $OUT.
if [[ "$PDF_OK" == yes ]]; then
  docker run --rm --user "$IMAGE_USER" --network none -v "$MAIN_DIR":/compile -w /compile -e HOME=/tmp "$IMAGE" \
    gs -dQUIET -dNOPAUSE -dBATCH -sDEVICE=png16m -r100 -dFirstPage=1 -dLastPage=1 \
       -sOutputFile=/compile/preview.png /compile/output.pdf >/dev/null 2>&1 || true
  [[ -f "$MAIN_DIR/preview.png" ]] && cp "$MAIN_DIR/preview.png" "$OUT/" 2>/dev/null || true
fi

# ---- 生成 summary.md / build summary ----
{
  echo "## 🧪 TeXLive 镜像编译测试结果 / TeXLive image compile test result"
  echo
  echo "| 项 / Item | 值 / Value |"
  echo "|---|---|"
  echo "| 项目 / Project | \`${PROJECT_NAME:-(unknown)}\` |"
  echo "| 镜像 / Image | \`$IMAGE\` |"
  echo "| 编译器 / Compiler | \`$COMPILER\` （来源 / source: $COMPILER_SRC） |"
  echo "| TeXLive 年份 / Year | \`$TEXLIVE\` （来源 / source: $YEAR_SRC） |"
  echo "| 主文件 / Main file | \`$MAIN_REL\` |"
  echo "| latexmk 退出码 / exit code | \`$STATUS\` |"
  echo "| 生成 PDF / PDF produced | $([ "$PDF_OK" = yes ] && echo "✅ 是 / yes ($PDF_SIZE bytes)" || echo "❌ 否 / no") |"
  echo "| 用时 / Duration | ${ELAPSED}s |"
  echo
  if [[ "$PDF_OK" == yes && "$STATUS" -eq 0 ]]; then
    echo "### ✅ 编译成功 / Compiled successfully"
    echo "本镜像可以编译该项目。若 Overleaf 同样成功，则非镜像问题；请附上你期望的差异。"
    echo "This image compiled the project. If Overleaf also succeeds, this is not an image bug; please describe the expected difference."
  else
    echo "### ❌ 编译失败 / Compile failed"
    echo "本镜像未能编译该项目。下方为 \`output.log\` 末尾，完整日志见 Artifacts。"
    echo "This image failed to compile. The tail of \`output.log\` is below; full logs are attached as artifacts."
  fi
  echo
  echo "<details><summary>output.log (tail 80) </summary>"
  echo
  echo '```text'
  if [[ -f "$OUT/output.log" ]]; then tail -n 80 "$OUT/output.log"; else echo "(no output.log produced)"; fi
  echo '```'
  echo "</details>"
  echo
  echo "<details><summary>stderr (tail 40)</summary>"
  echo
  echo '```text'
  tail -n 40 "$OUT/output.stderr" 2>/dev/null || true
  echo '```'
  echo "</details>"
} >> "$SUMMARY"

# 机器可读结果 / machine-readable result for the workflow
{
  echo "status=$STATUS"
  echo "pdf=$PDF_OK"
  echo "image=$IMAGE"
  echo "compiler=$COMPILER"
  echo "texlive=$TEXLIVE"
  echo "main=$MAIN_REL"
} > "$OUT/result.env"

say ""
say "结果已写入 / results written to: $OUT"
say "  - summary.md  (issue 评论用 / for the issue comment)"
say "  - output.log, output.stdout, output.stderr, output.pdf"

# 编译失败时以非零退出，方便 CI 标红 / non-zero exit on failure so CI marks it red
[[ "$PDF_OK" == yes && "$STATUS" -eq 0 ]] && exit 0 || exit 1
