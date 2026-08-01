#!/bin/sh
# 更新部分宏包到指定版本。
#
# 表：<包名>  <来源快照 YYYY/MM/DD>  <目标 revision>
# 从对应日期的 tlnet-archive 取出这些包拼成一个最小仓库，交给 tlmgr 更新。
# 每项都核对 revision 与 sha512，不符即失败。

set -eu

PKGS='
cyrillic            2022/06/18  63613
l3packages          2022/06/29  63705
microtype           2022/06/29  63708
tcolorbox           2022/06/29  63713
biber.x86_64-linux  2022/07/13  63870
biblatex            2022/07/13  63878
latex               2022/07/13  63825
textcase            2022/07/13  63868
babel               2022/08/10  63948
biber               2022/08/10  63965
bidi                2022/08/10  63930
l3backend           2022/08/10  64066
l3kernel            2022/08/10  64066
memoir              2022/08/10  64001
tudscr              2022/08/10  64085
koma-script         2022/10/13  64685
'

MIRROR=https://texlive.info/tlnet-archive

# 只在 x86_64-linux 上执行。TL 各架构的二进制是独立重编的，同一天的 revision
# 常不一致，部分架构的容器也并不存在，其它架构一律不动。
ARCH=$(tlmgr print-platform)
if [ "$ARCH" != "x86_64-linux" ]; then
    echo "==> $ARCH: 跳过"
    exit 0
fi

# texlive.info 是单机服务器，多个构建并行时容易抖。wget 自身的 --tries 只覆盖
# 部分错误（连接被拒、DNS 失败会直接放弃），所以外面再套一层退避重试。
# 用 -nv 而不是 -q：失败原因要能在构建日志里看到。
fetch() {
    i=1
    while [ "$i" -le 4 ]; do
        if wget -nv --tries=3 --waitretry=10 --timeout=120 -O "$2" "$1"; then
            return 0
        fi
        echo "    下载失败（第 $i 次）: $1" >&2
        rm -f "$2"
        sleep $((i * 10))
        i=$((i + 1))
    done
    echo "FATAL 下载反复失败: $1" >&2
    return 1
}

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
REPO=$WORK/repo
mkdir -p "$REPO/tlpkg" "$REPO/archive"
: > "$REPO/tlpkg/texlive.tlpdb"

# 显式累积包名，最后原样交给 tlmgr，不用 --all
TARGETS=''

for date in $(echo "$PKGS" | awk 'NF {print $2}' | sort -u); do
    names=$(echo "$PKGS" | awk -v d="$date" '$2 == d {printf "%s ", $1}')
    echo "==> $date: $names"
    fetch "$MIRROR/$date/tlnet/tlpkg/texlive.tlpdb" "$WORK/full.tlpdb"

    # 整块逐字复制，containersize/containerchecksum 与容器保持一致
    awk -v want=" $names " '
        /^name /  { keep = index(want, " " $2 " ") > 0 }
        keep      { print }
        /^$/      { keep = 0 }
    ' "$WORK/full.tlpdb" >> "$REPO/tlpkg/texlive.tlpdb"

    for name in $names; do
        want_rev=$(echo "$PKGS" | awk -v n="$name" '$1 == n {print $3}')
        got_rev=$(awk -v n="$name" '
            $0 == "name " n   { f = 1; next }
            f && /^revision / { print $2; exit }
        ' "$WORK/full.tlpdb")
        if [ "$got_rev" != "$want_rev" ]; then
            echo "FATAL $name: $date 的 revision 是 ${got_rev:-<缺失>}，期望 $want_rev" >&2
            exit 1
        fi
        sum=$(awk -v n="$name" '
            $0 == "name " n            { f = 1; next }
            f && /^containerchecksum / { print $2; exit }
        ' "$WORK/full.tlpdb")
        fetch "$MIRROR/$date/tlnet/archive/$name.tar.xz" \
            "$REPO/archive/$name.tar.xz"
        echo "$sum  $REPO/archive/$name.tar.xz" | sha512sum -c - > /dev/null
        echo "    $name r$want_rev ok"
        TARGETS="$TARGETS $name"
    done
done

# tlmgr 要求仓库里有 00texlive.config 才认它是个 TL 仓库
awk '
    /^name /  { keep = ($2 == "00texlive.config") }
    keep      { print }
    /^$/      { keep = 0 }
' "$WORK/full.tlpdb" >> "$REPO/tlpkg/texlive.tlpdb"

# tlmgr 用这个文件判断 tlpdb 要不要重读，缺了会直接报 cannot download 退出。
# 值是我们对自己拼的 tlpdb 算的，自指，不构成校验 —— 真正的校验是上面每个
# 容器对上游 tlpdb 里 containerchecksum 的比对。
( cd "$REPO/tlpkg" && sha512sum texlive.tlpdb > texlive.tlpdb.sha512 )

# texlive.infra 是 tlmgr 自身，普通 update 会被拒绝并要求改用 --self；
# 其余已装的走 update，未装的走 install
SELF=''
UPDATES=''
INSTALLS=''
for name in $TARGETS; do
    case "$name" in
        texlive.infra|texlive.infra.*)
            SELF="$SELF $name"
            continue
            ;;
    esac
    if [ -n "$(tlmgr info --only-installed --data name "$name" 2>/dev/null)" ]; then
        UPDATES="$UPDATES $name"
    else
        INSTALLS="$INSTALLS $name"
    fi
done

# --verify-repo=none：临时仓库无法签名。容器的完整性靠上面逐个比对上游 tlpdb
# 里的 containerchecksum，对上游本身的信任则落在 HTTPS 上。
# 必须最先执行：tlmgr 认为自身待更新时会拒绝其它操作
if [ -n "$SELF" ]; then
    echo "==> tlmgr update --self:$SELF"
    tlmgr update --self --repository "$REPO" --verify-repo=none
fi
if [ -n "$UPDATES" ]; then
    echo "==> tlmgr update:$UPDATES"
    # shellcheck disable=SC2086
    tlmgr update --repository "$REPO" --verify-repo=none $UPDATES
fi
if [ -n "$INSTALLS" ]; then
    echo "==> tlmgr install:$INSTALLS"
    # shellcheck disable=SC2086
    tlmgr install --repository "$REPO" --verify-repo=none $INSTALLS
fi

echo "==> update 完成"
