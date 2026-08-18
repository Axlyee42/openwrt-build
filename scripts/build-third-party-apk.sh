```bash
#!/usr/bin/env bash
#
# Build OpenWrt third-party APK packages
#

set -Eeuo pipefail

ROOT_DIR="${OPENWRT_ROOT:-$(pwd)}"

JOBS="${JOBS:-$(nproc)}"

log() {
    printf '\033[1;32m[APK] %s\033[0m\n' "$*"
}

die() {
    printf '\033[1;31m[APK] ERROR: %s\033[0m\n' "$*" >&2
    exit 1
}

cd "${ROOT_DIR}"

[[ -f Makefile ]] ||
    die "Not an OpenWrt source tree."

###############################################################################
# 更新 package index
###############################################################################

log "Refreshing package metadata"

./scripts/feeds update -a

###############################################################################
# 让 OpenWrt 识别 package/third-party
###############################################################################

log "Refreshing package indexes"

make defconfig

###############################################################################
# 获取第三方 Makefile
###############################################################################

mapfile -t PACKAGES < <(
    find package/third-party \
        -mindepth 2 \
        -maxdepth 2 \
        -type f \
        -name Makefile \
        -print \
        | sort \
        | while read -r makefile; do

            awk '
                /^define Package\// {
                    sub(/^define Package\//, "", $0)
                    print $0
                    exit
                }
            ' "${makefile}"

        done
)

###############################################################################
# 去重
###############################################################################

mapfile -t PACKAGES < <(
    printf '%s\n' "${PACKAGES[@]}" |
        sed '/^$/d' |
        sort -u
)

if (( ${#PACKAGES[@]} == 0 )); then
    die "No third-party OpenWrt packages found."
fi

log "Detected packages:"

for package in "${PACKAGES[@]}"; do
    echo "  - ${package}"
done

###############################################################################
# 编译
###############################################################################

for package in "${PACKAGES[@]}"; do

    log "Building ${package}"

    make \
        "package/third-party/${package}/compile" \
        -j"${JOBS}" \
        V=s

done

log "Third-party APK build completed."
```
