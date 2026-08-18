#!/usr/bin/env bash
#
# OpenWrt Third-Party Source Packages
#
# PURPOSE:
#   ONLY prepare third-party OpenWrt package source trees.
#
# THIS SCRIPT DOES NOT:
#   - modify .config
#   - run make
#   - run make defconfig
#   - compile APK/IPK
#   - inspect generated APK/IPK
#   - modify GITHUB_ENV
#
# OUTPUT:
#
#   ${OPENWRT_ROOT}/package/third-party/
#
# The following third-party sources are prepared:
#
#   Aurora
#   Bandix
#   PassWall
#   PassWall dependency packages
#   OpenClash
#
# PassWall dependency packages are copied from:
#
#   Openwrt-Passwall/openwrt-passwall-packages
#
# This script deliberately clones repositories using their DEFAULT
# upstream branch unless an explicit branch is supplied.
#
# This avoids failures caused by assuming every repository uses "main".
#

set -Eeuo pipefail

###############################################################################
# Paths
###############################################################################

ROOT_DIR="${OPENWRT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

TP_DIR="${ROOT_DIR}/${THIRD_PARTY_DIR:-package/third-party}"

RUNNER_TEMP_DIR="${RUNNER_TEMP:-/tmp}/openwrt-third-party"

GIT_DEPTH="${GIT_DEPTH:-1}"

###############################################################################
# Logging
###############################################################################

log() {
    printf '%b\n' "\033[1;32m[TP]\033[0m $*"
}

warn() {
    printf '%b\n' "\033[1;33m[TP]\033[0m $*" >&2
}

die() {
    printf '%b\n' "\033[1;31m[TP] ERROR:\033[0m $*" >&2
    exit 1
}

###############################################################################
# Validation
###############################################################################

require_openwrt_tree() {

    [[ -d "${ROOT_DIR}" ]] ||
        die "OpenWrt root does not exist: ${ROOT_DIR}"

    [[ -f "${ROOT_DIR}/Makefile" ]] ||
        die "Not an OpenWrt source tree: ${ROOT_DIR}"
}

###############################################################################
# Git clone helper
#
# IMPORTANT:
#
# Do NOT assume "main".
#
# If branch is supplied:
#
#   clone_repo repo destination branch
#
# Otherwise:
#
#   clone_repo repo destination
#
# Git will use the repository's default branch.
###############################################################################

clone_repo() {

    local repo="$1"
    local dest="$2"
    local branch="${3:-}"

    local url="https://github.com/${repo}.git"

    rm -rf "${dest}"

    mkdir -p "$(dirname "${dest}")"

    log "Cloning ${repo}"

    if [[ -n "${branch}" ]]; then

        log "Using branch: ${branch}"

        git clone \
            --depth="${GIT_DEPTH}" \
            --single-branch \
            --branch="${branch}" \
            "${url}" \
            "${dest}"

    else

        log "Using upstream default branch"

        git clone \
            --depth="${GIT_DEPTH}" \
            --single-branch \
            "${url}" \
            "${dest}"

    fi
}

###############################################################################
# Copy package tree
###############################################################################

copy_package() {

    local src="$1"
    local dst="$2"

    [[ -d "${src}" ]] ||
        die "Package source not found: ${src}"

    [[ -f "${src}/Makefile" ]] ||
        die "Package Makefile not found: ${src}/Makefile"

    rm -rf "${dst}"

    mkdir -p "${dst}"

    cp -a \
        "${src}/." \
        "${dst}/"

    log "Installed package source: $(basename "${dst}")"
}

###############################################################################
# Copy a repository package directory
#
# Used when a repository itself is a package.
###############################################################################

copy_repo_as_package() {

    local repo_dir="$1"
    local package_name="$2"

    copy_package \
        "${repo_dir}" \
        "${TP_DIR}/${package_name}"
}

###############################################################################
# Remove Git metadata
###############################################################################

clean_git() {

    [[ -d "${TP_DIR}" ]] || return 0

    find "${TP_DIR}" \
        -type d \
        -name .git \
        -prune \
        -exec rm -rf {} + \
        2>/dev/null || true

    find "${TP_DIR}" \
        -type d \
        -name .github \
        -prune \
        -exec rm -rf {} + \
        2>/dev/null || true
}

###############################################################################
# Prepare target directory
###############################################################################

prepare_root() {

    log "Preparing third-party package directory"

    rm -rf "${TP_DIR}"

    mkdir -p "${TP_DIR}"

    rm -rf "${RUNNER_TEMP_DIR}"

    mkdir -p "${RUNNER_TEMP_DIR}"
}

###############################################################################
# Aurora
#
# Repository:
#
#   eamonxg/luci-theme-aurora
#
# IMPORTANT:
#
# No branch is specified.
#
# The repository's default branch is used.
#
# Aurora currently contains:
#
#   luci-theme-aurora
#   luci-app-aurora-config
#
###############################################################################

install_aurora() {

    local tmp="${RUNNER_TEMP_DIR}/aurora"

    log "Preparing Aurora"

    clone_repo \
        "eamonxg/luci-theme-aurora" \
        "${tmp}"

    if [[ -f "${tmp}/luci-theme-aurora/Makefile" ]]; then

        copy_repo_as_package \
            "${tmp}/luci-theme-aurora" \
            "luci-theme-aurora"

    else

        die \
            "Aurora theme package not found: ${tmp}/luci-theme-aurora/Makefile"

    fi

    if [[ -f "${tmp}/luci-app-aurora-config/Makefile" ]]; then

        copy_repo_as_package \
            "${tmp}/luci-app-aurora-config" \
            "luci-app-aurora-config"

    else

        warn \
            "Aurora config package not found; continuing without luci-app-aurora-config"

    fi
}

###############################################################################
# Bandix
#
# Frontend:
#
#   timsaya/luci-app-bandix
#
# Backend:
#
#   timsaya/openwrt-bandix
#
# The upstream project explicitly documents that the two packages are
# separate and should be installed together. 
###############################################################################

install_bandix() {

    local tmp="${RUNNER_TEMP_DIR}/bandix"

    log "Preparing Bandix frontend"

    clone_repo \
        "timsaya/luci-app-bandix" \
        "${tmp}/luci-app-bandix"

    copy_repo_as_package \
        "${tmp}/luci-app-bandix" \
        "luci-app-bandix"

    log "Preparing Bandix backend"

    clone_repo \
        "timsaya/openwrt-bandix" \
        "${tmp}/openwrt-bandix"

    copy_repo_as_package \
        "${tmp}/openwrt-bandix" \
        "bandix"
}

###############################################################################
# PassWall LuCI
###############################################################################

install_passwall() {

    local tmp="${RUNNER_TEMP_DIR}/passwall"

    log "Preparing PassWall"

    clone_repo \
        "Openwrt-Passwall/openwrt-passwall" \
        "${tmp}"

    if [[ -f "${tmp}/luci-app-passwall/Makefile" ]]; then

        copy_repo_as_package \
            "${tmp}/luci-app-passwall" \
            "luci-app-passwall"

    else

        die \
            "PassWall package not found: ${tmp}/luci-app-passwall/Makefile"

    fi
}

###############################################################################
# PassWall dependency packages
#
# Repository:
#
#   Openwrt-Passwall/openwrt-passwall-packages
#
# The upstream repository currently contains packages including:
#
#   chinadns-ng
#   dns2socks
#   geoview
#   hysteria
#   ipt2socks
#   naiveproxy
#   shadowsocksr-libev
#   sing-box
#   tcping
#   v2ray-geodata
#   xray-core
#
# and additional packages.
#
# We intentionally use an allow-list so unrelated packages from the upstream
# repository do not unexpectedly enter the firmware.
###############################################################################

install_passwall_packages() {

    local tmp="${RUNNER_TEMP_DIR}/passwall-packages"

    log "Preparing PassWall dependency packages"

    clone_repo \
        "Openwrt-Passwall/openwrt-passwall-packages" \
        "${tmp}"

    [[ -d "${tmp}" ]] ||
        die "PassWall packages repository was not cloned."

    #
    # These are the package directories we actually want.
    #
    # v2ray-geodata is special:
    #
    #   one source directory
    #       ↓
    #   v2ray-geoip
    #   v2ray-geosite
    #
    local packages=(
        "chinadns-ng"
        "dns2socks"
        "dns2tcp"
        "geoview"
        "hysteria"
        "ipt2socks"
        "naiveproxy"
        "shadowsocksr-libev"
        "sing-box"
        "tcping"
        "xray-core"
    )

    local package

    for package in "${packages[@]}"; do

        if [[ -f "${tmp}/${package}/Makefile" ]]; then

            copy_repo_as_package \
                "${tmp}/${package}" \
                "${package}"

        else

            warn \
                "PassWall package not found upstream: ${package}"

        fi

    done

    ###########################################################################
    # v2ray-geodata
    ###########################################################################

    if [[ -f "${tmp}/v2ray-geodata/Makefile" ]]; then

        copy_repo_as_package \
            "${tmp}/v2ray-geodata" \
            "v2ray-geodata"

    else

        warn \
            "v2ray-geodata Makefile not found."

    fi
}

###############################################################################
# OpenClash
#
# Repository:
#
#   vernesong/OpenClash
#
# Default upstream branch is used.
###############################################################################

install_openclash() {

    local tmp="${RUNNER_TEMP_DIR}/openclash"

    log "Preparing OpenClash"

    clone_repo \
        "vernesong/OpenClash" \
        "${tmp}"

    if [[ -f "${tmp}/luci-app-openclash/Makefile" ]]; then

        copy_repo_as_package \
            "${tmp}/luci-app-openclash" \
            "luci-app-openclash"

    else

        warn \
            "OpenClash package not found; continuing without OpenClash."

    fi
}

###############################################################################
# Package tree validation
###############################################################################

validate_packages() {

    local count

    count="$(
        find "${TP_DIR}" \
            -type f \
            -name Makefile \
            | wc -l
    )"

    log "Detected ${count} third-party Makefiles."

    [[ "${count}" -gt 0 ]] ||
        die "No third-party OpenWrt package Makefiles were generated."

    echo
    echo "============================================================"
    echo " Third-party package Makefiles"
    echo "============================================================"

    find "${TP_DIR}" \
        -type f \
        -name Makefile \
        -print \
        | sort

    echo
    echo "============================================================"
}

###############################################################################
# Show package definitions
#
# This is ONLY diagnostic.
#
# It does not modify .config.
###############################################################################

show_package_definitions() {

    echo
    echo "============================================================"
    echo " Third-party Package definitions"
    echo "============================================================"

    while IFS= read -r makefile; do

        awk '
            /^define Package\// {
                name=$0
                sub(/^define Package\//, "", name)
                print name
            }
        ' "${makefile}"

    done < <(
        find "${TP_DIR}" \
            -type f \
            -name Makefile \
            -print \
            | sort
    ) | sort -u

    echo
    echo "============================================================"
}

###############################################################################
# Cleanup
###############################################################################

cleanup() {

    rm -rf "${RUNNER_TEMP_DIR}"
}

###############################################################################
# Error trap
###############################################################################

on_error() {

    local line="${1:-unknown}"

    printf '%b\n' \
        "\033[1;31m[TP] ERROR: apk-custom-packages.sh failed at line ${line}\033[0m" \
        >&2

    printf '%b\n' \
        "\033[1;31m[TP] Command: ${BASH_COMMAND}\033[0m" \
        >&2
}

trap 'on_error "${LINENO}"' ERR

trap cleanup EXIT

###############################################################################
# Main
###############################################################################

main() {

    log "OpenWrt root: ${ROOT_DIR}"

    log "Third-party directory: ${TP_DIR}"

    require_openwrt_tree

    prepare_root

    ###########################################################################
    # Third-party sources
    ###########################################################################

    install_aurora

    install_bandix

    install_passwall

    install_passwall_packages

    install_openclash

    ###########################################################################
    # Remove Git metadata
    ###########################################################################

    clean_git

    ###########################################################################
    # Validate
    ###########################################################################

    validate_packages

    show_package_definitions

    ###########################################################################
    # Done
    ###########################################################################

    log "Third-party source preparation completed successfully."

    echo
    echo "Third-party package tree:"
    echo
    find "${TP_DIR}" \
        -maxdepth 2 \
        -type f \
        -name Makefile \
        -print \
        | sort

    echo
}

main "$@"
