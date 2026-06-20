# Overleaf 编译复现工具 / Overleaf compile reproduction tools

用于复现 **“官方 Overleaf 能编译，但本镜像 (ayaka-notes/texlive-full) 编译不了”** 的问题。
Reproduces **"compiles on official Overleaf, but fails with the ayaka-notes/texlive-full image"** bugs.

## 它是怎么跑的 / How it works

1. `overleaf-fetch.mjs` —— 用 Overleaf **只读分享链接** 拿到匿名会话，下载项目 zip。
   Uses the Overleaf **read-only share link** to get an anonymous session and download the project zip.
   - 链接里的 `#xxxx` 锚点会作为 `tokenHashPrefix` 传给 Overleaf 的 grant 接口。
     The `#xxxx` anchor is passed as `tokenHashPrefix` to Overleaf's grant endpoint.
   - 安全：只允许 `https://*.overleaf.com`（防 SSRF）。
     Security: only `https://*.overleaf.com` is allowed (anti-SSRF).
2. `overleaf-compile-test.sh` —— 解压、确定编译器/TeXLive 年份/主文件，在镜像里用 `latexmk` 编译，收集日志。
   Unpacks, resolves compiler / TeX Live year / main file, runs `latexmk` in the image, collects logs.

## 用法 / Usage

```bash
scripts/overleaf-compile-test.sh \
  --link  "https://www.overleaf.com/read/xxxxxxxxxxxx#yyyyyy" \
  --compiler auto|pdflatex|xelatex|lualatex|latex \
  --texlive  auto|2026|2025|2024|2023|2022|2021|2020 \
  --main     path/to/main.tex \      # 可选 / optional
  --out      ./compile-result
```

输出 / Output: `compile-result/` 内含 `output.pdf`、`output.log`、`output.stdout/stderr`、`preview.png`、`summary.md`、`result.env`。

## 与 CLSI 的一致性 / Fidelity to CLSI

编译命令、环境、沙箱均对齐 Overleaf CLSI（`services/clsi`）：
The compile command, environment and sandbox match Overleaf CLSI (`services/clsi`):

- 命令 / command（`LatexRunner.js`）：
  `latexmk -cd -jobname=output -auxdir=$COMPILE_DIR -outdir=$COMPILE_DIR -synctex=1 -interaction=batchmode -time -f <engine> $COMPILE_DIR/main.tex`
- 环境 / env（`DockerRunner.js` / `settings.defaults.js`）：`HOME=/tmp`、`CLSI=1`、`PATH=.../usr/local/texlive/<year>/bin/x86_64-linux/`
- 沙箱 / sandbox：`--network none`、`--user tex`、`--cap-drop ALL`、`--security-opt no-new-privileges`、
  `--ulimit cpu=timeout+5:timeout+10`、`--security-opt seccomp=clsi-seccomp.json`（即 CLSI 的 `seccomp/clsi-profile.json`）。
- `clsi-seccomp.json` 直接取自 Overleaf CLSI。/ vendored verbatim from Overleaf CLSI.

有意的少量差异 / intentional deviations：`--memory=2g`（保护 runner，CLSI 默认实际由 compile group 配置决定）；额外加 `timeout` 墙钟兜底。
`--memory=2g` (protects the runner; CLSI's real limit comes from compile-group config) and an extra wall-clock `timeout`.

## 安全 / Security

- 所有输入（链接、编译器、年份、主文件）先经**白名单校验**，含非法字符即拒绝；从不内联进 shell。
  All inputs are **allowlist-validated** and rejected on illegal characters; never inlined into shell.
- 被编译的 LaTeX 跑在**断网、无密钥**的容器里，即使含 `\write18` 也读不到任何 secret。
  The compiled LaTeX runs in a **network-less, secret-less** container; even `\write18` can't read any secret.
- CI 里下载/编译不可信项目的工作流是**只读权限、无 token**；评论/发 release 由单独的特权工作流完成，且它从不执行项目内容。
  In CI, the workflow that downloads/compiles untrusted projects is **read-only with no token**; commenting is done by a separate privileged workflow that never executes project content.

## 已知限制 / Known limitations

- 仅支持 `/read/` 只读匿名链接；读写匿名链接 overleaf.com 默认禁止。
  Only anonymous `/read/` links; anonymous read-write links are disabled by overleaf.com.
- 编译器/年份优先用用户填写；socket 自动探测在 overleaf.com 上不稳定，默认禁用（缺 `ws` 时自动跳过）。
  Compiler/year come from the user's input first; socket auto-probe is unreliable on overleaf.com and off by default (skipped when `ws` is absent).
- 不处理 `.Rtex/.Rmd/.md` 的预处理（Overleaf 会先转 `.tex`）。/ no `.Rtex/.Rmd/.md` pre-processing (Overleaf converts to `.tex` first).
