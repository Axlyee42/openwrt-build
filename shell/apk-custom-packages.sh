#!/usr/bin/env bash

set -euo pipefail

# ==========================================================
# OpenWrt 25.12.x
# Custom packages
#
# 本脚本只负责：
#   1. 添加第三方 package
#   2. 不负责生成 .config
#   3. 不负责验证 CONFIG_PACKAGE
#   4. 不因为可选第三方包缺失而误判整个编译失败
#
# OpenWrt 25.12+ 使用 APK
# ==========================================================


OPENWRT_DIR="${OPENWRT_DIR:-$(pwd)}"

cd "${OPENWRT_DIR}"


CUSTOM_DIR="${OPENWRT_DIR}/package/custom"

mkdir -p "${CUSTOM_DIR}"


echo
echo "=========================================="
echo "OpenWrt Custom Packages"
echo "=========================================="
echo
echo "OpenWrt directory:"
echo "${OPENWRT_DIR}"
echo
echo "Custom package directory:"
echo "${CUSTOM_DIR}"
echo


# ==========================================================
# 通用函数
# ==========================================================

clone_repo() {

    local URL="$1"
    local DEST="$2"

    echo
    echo "------------------------------------------"
    echo "Installing: ${DEST}"
    echo "Source: ${URL}"
    echo "------------------------------------------"

    rm -rf "${DEST}"

    git clone \
        --depth=1 \
        "${URL}" \
        "${DEST}"

}


copy_package() {

    local SRC="$1"
    local DEST="$2"

    echo
    echo "------------------------------------------"
    echo "Copying package"
    echo "Source: ${SRC}"
    echo "Destination: ${DEST}"
    echo "------------------------------------------"

    if [ ! -d "${SRC}" ]; then

        echo "WARNING: source directory does not exist:"
        echo "${SRC}"

        return 0

    fi

    rm -rf "${DEST}"

    cp -a \
        "${SRC}" \
        "${DEST}"

}


# ==========================================================
# 临时第三方仓库
# ==========================================================

TMP_DIR="${RUNNER_TEMP:-/tmp}/openwrt-custom-packages"

rm -rf "${TMP_DIR}"

mkdir -p "${TMP_DIR}"


# ==========================================================
# 1. Aurora
#
# luci-theme-aurora
# ==========================================================

clone_repo \
    "https://github.com/eamonxg/luci-theme-aurora.git" \
    "${CUSTOM_DIR}/luci-theme-aurora"


# ==========================================================
# 2. Aurora Config
#
# luci-app-aurora-config
# ==========================================================

clone_repo \
    "https://github.com/eamonxg/luci-app-aurora-config.git" \
    "${CUSTOM_DIR}/luci-app-aurora-config"


# ==========================================================
# 3. Shadcn
#
# luci-theme-shadcn
# ==========================================================

clone_repo \
    "https://github.com/eamonxg/luci-theme-shadcn.git" \
    "${CUSTOM_DIR}/luci-theme-shadcn"


# ==========================================================
# 4. OpenClash
#
# luci-app-openclash
# ==========================================================

clone_repo \
    "https://github.com/vernesong/OpenClash.git" \
    "${CUSTOM_DIR}/OpenClash"


# ==========================================================
# 5. luci-app-run
# ==========================================================

clone_repo \
    "https://github.com/wukongdaily/luci-app-run.git" \
    "${CUSTOM_DIR}/luci-app-run"


# ==========================================================
# 6. Bandix
#
# Backend:
#   openwrt-bandix
#
# LuCI:
#   luci-app-bandix
#
# 两个项目需要配套
# ==========================================================

clone_repo \
    "https://github.com/timsaya/openwrt-bandix.git" \
    "${CUSTOM_DIR}/openwrt-bandix"


clone_repo \
    "https://github.com/timsaya/luci-app-bandix.git" \
    "${CUSTOM_DIR}/luci-app-bandix"


# ==========================================================
# 7. sbwml/openwrt_pkgs
#
# 用于获取：
#
# luci-app-filebrowser-go
# luci-app-vlmcsd
# luci-app-timewol
# luci-app-autoreboot
#
# 如果上游目录结构发生变化：
# 只输出 WARNING
# 不直接让整个编译失败
# ==========================================================

echo
echo "=========================================="
echo "Downloading sbwml/openwrt_pkgs"
echo "=========================================="


git clone \
    --depth=1 \
    https://github.com/sbwml/openwrt_pkgs.git \
    "${TMP_DIR}/openwrt_pkgs"


# ==========================================================
# 8. FileBrowser Go
# ==========================================================

echo
echo "=========================================="
echo "FileBrowser Go"
echo "=========================================="


if [ -d "${TMP_DIR}/openwrt_pkgs/luci-app-filebrowser-go" ]; then

    copy_package \
        "${TMP_DIR}/openwrt_pkgs/luci-app-filebrowser-go" \
        "${CUSTOM_DIR}/luci-app-filebrowser-go"

else

    echo "WARNING: luci-app-filebrowser-go was not found."

fi


# ==========================================================
# 9. VLMCSd
# ==========================================================

echo
echo "=========================================="
echo "VLMCSd"
echo "=========================================="


if [ -d "${TMP_DIR}/openwrt_pkgs/luci-app-vlmcsd" ]; then

    copy_package \
        "${TMP_DIR}/openwrt_pkgs/luci-app-vlmcsd" \
        "${CUSTOM_DIR}/luci-app-vlmcsd"

else

    echo "WARNING: luci-app-vlmcsd was not found."

fi


# ==========================================================
# 10. Timewol
#
# 不同版本仓库可能存在：
#
# luci-app-timewol
#
# 或：
#
# luci-app-control-timewol
# ==========================================================

echo
echo "=========================================="
echo "Timewol"
echo "=========================================="


if [ -d "${TMP_DIR}/openwrt_pkgs/luci-app-timewol" ]; then

    copy_package \
        "${TMP_DIR}/openwrt_pkgs/luci-app-timewol" \
        "${CUSTOM_DIR}/luci-app-timewol"


elif [ -d "${TMP_DIR}/openwrt_pkgs/luci-app-control-timewol" ]; then

    copy_package \
        "${TMP_DIR}/openwrt_pkgs/luci-app-control-timewol" \
        "${CUSTOM_DIR}/luci-app-timewol"


else

    echo "WARNING: Timewol package was not found."

fi


# ==========================================================
# 11. Autoreboot
# ==========================================================

echo
echo "=========================================="
echo "Autoreboot"
echo "=========================================="


if [ -d "${TMP_DIR}/openwrt_pkgs/luci-app-autoreboot" ]; then

    copy_package \
        "${TMP_DIR}/openwrt_pkgs/luci-app-autoreboot" \
        "${CUSTOM_DIR}/luci-app-autoreboot"

else

    echo "WARNING: luci-app-autoreboot was not found."

fi


# ==========================================================
# 12. 清理第三方源码中的 Git 信息
#
# 减少最终构建目录体积
# ==========================================================

echo
echo "=========================================="
echo "Cleaning .git directories"
echo "=========================================="


find "${CUSTOM_DIR}" \
    -type d \
    -name ".git" \
    -prune \
    -exec rm -rf {} +


# ==========================================================
# 13. 显示最终 package
# ==========================================================

echo
echo "=========================================="
echo "Installed custom packages"
echo "=========================================="


find "${CUSTOM_DIR}" \
    -maxdepth 2 \
    -type f \
    -name "Makefile" \
    -print \
    | sort


echo
echo "=========================================="
echo "Custom package tree"
echo "=========================================="


find "${CUSTOM_DIR}" \
    -maxdepth 2 \
    -type d \
    | sort


echo
echo "=========================================="
echo "Custom packages completed"
echo "=========================================="
echo


exit 0
