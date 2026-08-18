```bash
#!/usr/bin/env bash
#
# OpenWrt Third-Party Source Packages
#
# ONLY:
#   - download third-party source
#   - place source under package/third-party
#
# NEVER:
#   - modify .config
#   - run make defconfig
#   - compile packages
#   - check generated APK
#   - modify GITHUB_ENV
#

set -Eeuo pipefail

ROOT_DIR="${OPENWRT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TP_DIR="${ROOT_DIR}/package/third-party"

GIT_DEPTH="${GIT_DEPTH:-1}"

log() {
    printf '\033[1;32m[TP] %s\033[0m\n' "$*"
}

warn() {
    printf '\033[1;33m[TP] %s\033[0m\n' "$*" >&2
}

die() {
    printf '\033[1;31m[TP] ERROR: %s\033[0m\n' "$*" >&2
    exit 1
}

clone_repo() {
    local repo="$1"
    local dest="$2"
    local branch="${3:-main}"

    local url="https://github.com/${repo}.git"

    rm -rf "${dest}"

    mkdir -p "$(dirname "${dest}")"

    log "clone ${repo}"

    git clone \
        --depth="${GIT_DEPTH}" \
        --single-branch \
        --branch="${branch}" \
        "${url}" \
        "${dest}"
}

copy_package() {
    local src="$1"
    local dst="$2"

    [[ -d "${src}" ]] ||
        die "package source not found: ${src}"

    rm -rf "${dst}"
    mkdir -p "${dst}"

    cp -a "${src}/." "${dst}/"
}

clean_git() {
    find "${TP_DIR}" \
        -type d \
        -name .git \
        -prune \
        -exec rm -rf {} + 2>/dev/null || true

    find "${TP_DIR}" \
        -type d \
        -name .github \
        -prune \
        -exec rm -rf {} + 2>/dev/null || true
}

prepare_root() {
    rm -rf "${TP_DIR}"
    mkdir -p "${TP_DIR}"
}

###############################################################################
# Aurora
###############################################################################

install_aurora() {

    local tmp="${RUNNER_TEMP:-/tmp}/aurora"

    rm -rf "${tmp}"

    clone_repo \
        "eamonxg/luci-theme-aurora" \
        "${tmp}"

    if [[ -d "${tmp}/luci-theme-aurora" ]]; then
        copy_package \
            "${tmp}/luci-theme-aurora" \
            "${TP_DIR}/luci-theme-aurora"
    fi

    if [[ -d "${tmp}/luci-app-aurora-config" ]]; then
        copy_package \
            "${tmp}/luci-app-aurora-config" \
            "${TP_DIR}/luci-app-aurora-config"
    fi

    rm -rf "${tmp}"
}

###############################################################################
# Bandix
###############################################################################

install_bandix() {

    local tmp="${RUNNER_TEMP:-/tmp}/bandix"

    rm -rf "${tmp}"

    clone_repo \
        "timsaya/luci-app-bandix" \
        "${tmp}/luci-app-bandix"

    clone_repo \
        "timsaya/openwrt-bandix" \
        "${tmp}/openwrt-bandix"

    copy_package \
        "${tmp}/luci-app-bandix" \
        "${TP_DIR}/luci-app-bandix"

    copy_package \
        "${tmp}/openwrt-bandix" \
        "${TP_DIR}/bandix"

    rm -rf "${tmp}"
}

###############################################################################
# PassWall
###############################################################################

install_passwall() {

    local tmp="${RUNNER_TEMP:-/tmp}/passwall"

    rm -rf "${tmp}"

    clone_repo \
        "Openwrt-Passwall/openwrt-passwall" \
        "${tmp}"

    if [[ -d "${tmp}/luci-app-passwall" ]]; then
        copy_package \
            "${tmp}/luci-app-passwall" \
            "${TP_DIR}/luci-app-passwall"
    fi

    rm -rf "${tmp}"
}

###############################################################################
# PassWall packages
#
# PassWall 的核心依赖单独来自 packages 仓库。
###############################################################################

install_passwall_packages() {

    local tmp="${RUNNER_TEMP:-/tmp}/passwall-packages"

    rm -rf "${tmp}"

    clone_repo \
        "Openwrt-Passwall/openwrt-passwall-packages" \
        "${tmp}"

    if [[ -d "${tmp}" ]]; then

        while IFS= read -r makefile; do

            local dir
            dir="$(dirname "${makefile}")"

            if grep -qE \
                'Package/(geoview|xray-core|sing-box|hysteria)' \
                "${makefile}" 2>/dev/null; then

                local name
                name="$(basename "${dir}")"

                copy_package \
                    "${dir}" \
                    "${TP_DIR}/${name}"

            fi

        done < <(
            find "${tmp}" \
                -type f \
                -name Makefile
        )

    fi

    rm -rf "${tmp}"
}

###############################################################################
# OpenClash
###############################################################################

install_openclash() {

    local tmp="${RUNNER_TEMP:-/tmp}/openclash"

    rm -rf "${tmp}"

    clone_repo \
        "vernesong/OpenClash" \
        "${tmp}"

    if [[ -d "${tmp}/luci-app-openclash" ]]; then

        copy_package \
            "${tmp}/luci-app-openclash" \
            "${TP_DIR}/luci-app-openclash"

    fi

    rm -rf "${tmp}"
}

###############################################################################
# 其它第三方包
#
# 这些包如果已经通过你的其它第三方 feed 提供，
# 不在这里重复 clone。
#
# 这样可以避免：
#
#   同一个 package
#       ↓
#   多个 feed
#       ↓
#   两个版本同时进入 bin/packages
#
###############################################################################

install_optional_feed() {

    local repo="$1"
    local dest="$2"
    local branch="${3:-main}"

    if [[ -z "${repo}" ]]; then
        return 0
    fi

    clone_repo \
        "${repo}" \
        "${TP_DIR}/${dest}" \
        "${branch}"
}

###############################################################################
# main
###############################################################################

main() {

    cd "${ROOT_DIR}"

    [[ -f Makefile ]] ||
        die "Not an OpenWrt source tree: ${ROOT_DIR}"

    prepare_root

    install_aurora

    install_bandix

    install_passwall

    install_passwall_packages

    install_openclash

    clean_git

    log "Third-party source preparation completed."

    echo
    echo "Third-party package trees:"
    find "${TP_DIR}" \
        -type f \
        -name Makefile \
        -print \
        | sort
}

main "$@"
```
