```bash
#!/usr/bin/env bash
#
# OpenWrt Third-Party APK Verification
#
# ONLY:
#   - locate generated APK
#   - verify required package names
#
# NEVER:
#   - compile
#   - download
#   - modify .config
#   - modify GITHUB_ENV
#

set -Eeuo pipefail

ROOT_DIR="${OPENWRT_ROOT:-$(pwd)}"

APK_ROOT="${APK_ROOT:-${ROOT_DIR}/bin/packages}"

###############################################################################
# Required packages
#
# 注意：
#   这里只写 package NAME。
#
# 不写：
#   版本号
#   revision
#   架构
#   .apk
###############################################################################

REQUIRED_PACKAGES=(
    "luci-theme-aurora"
    "luci-app-aurora-config"

    "bandix"
    "luci-app-bandix"

    "luci-app-run"

    "luci-app-passwall"
    "luci-app-passwall2"

    "geoview"
    "xray-core"
    "sing-box"
    "hysteria"
)

###############################################################################
# 可选包
#
# 编译环境中不存在时不报错。
###############################################################################

OPTIONAL_PACKAGES=(
    "luci-app-openclash"

    "clashoo"
    "luci-app-clashoo"

    "dae"
    "daed"

    "mosdns"
    "luci-app-mosdns"

    "nikki"
    "luci-app-nikki"

    "lucky"
    "luci-app-lucky"

    "quickfile"
    "luci-app-quickfile"

    "quickstart"
    "luci-app-quickstart"

    "rtp2httpd"
    "luci-app-rtp2httpd"

    "naiveproxy"

    "tcping"

    "chinadns-ng"
)

###############################################################################
# 找 APK
###############################################################################

find_apk() {

    local package="$1"

    find "${APK_ROOT}" \
        -type f \
        -name "${package}-*.apk" \
        -print \
        | sort \
        | head -n 1
}

###############################################################################
# 检查
###############################################################################

check_package() {

    local package="$1"

    local apk

    apk="$(find_apk "${package}")"

    if [[ -n "${apk}" ]]; then

        printf 'OK      %-32s %s\n' \
            "${package}" \
            "${apk}"

        return 0

    fi

    printf 'MISSING %-32s\n' \
        "${package}"

    return 1
}

###############################################################################
# 主流程
###############################################################################

main() {

    echo
    echo "============================================================"
    echo " Third-party APK verification"
    echo "============================================================"
    echo
    echo "APK root:"
    echo "  ${APK_ROOT}"
    echo

    [[ -d "${APK_ROOT}" ]] ||
        {
            echo "ERROR: APK directory does not exist."
            exit 1
        }

    local missing=0

    echo "Required packages:"
    echo

    for package in "${REQUIRED_PACKAGES[@]}"; do

        if ! check_package "${package}"; then
            missing=$((missing + 1))
        fi

    done

    echo
    echo "Optional packages:"
    echo

    for package in "${OPTIONAL_PACKAGES[@]}"; do

        check_package "${package}" || true

    done

    echo
    echo "Available APK packages:"
    echo

    find "${APK_ROOT}" \
        -type f \
        -name '*.apk' \
        -printf '%f\n' \
        | sort -u

    echo

    if (( missing > 0 )); then

        echo "ERROR: ${missing} required third-party APK package(s) are missing."

        exit 1
    fi

    echo "Third-party APK verification PASSED."

}

main "$@"
```
