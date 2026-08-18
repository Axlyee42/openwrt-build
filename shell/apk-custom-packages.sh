#!/usr/bin/env bash

set -euo pipefail

# ==========================================================
# OpenWrt 25.12.x
# Custom Packages
#
# 本脚本负责：
#   1. 添加第三方 package
#   2. 添加第三方 LuCI App
#   3. 添加第三方 App 所需要的后端依赖
#
# 不负责：
#   - 生成 .config
#   - 设置 CONFIG_PACKAGE_xxx
#   - 设置网络
#   - 设置默认语言
#
# 这些由 build-x86-64.yml 负责
# ==========================================================


OPENWRT_DIR="${OPENWRT_DIR:-$(pwd)}"

cd "${OPENWRT_DIR}"

CUSTOM_DIR="${OPENWRT_DIR}/package/custom"

mkdir -p "${CUSTOM_DIR}"

TMP_DIR="${RUNNER_TEMP:-/tmp}/openwrt-custom-packages"

rm -rf "${TMP_DIR}"

mkdir -p "${TMP_DIR}"


echo
echo "=========================================="
echo "OpenWrt Custom Packages"
echo "=========================================="

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
    echo "Clone:"
    echo "${URL}"
    echo
    echo "Destination:"
    echo "${DEST}"
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
    echo "Copy package:"
    echo "${SRC}"
    echo
    echo "Destination:"
    echo "${DEST}"
    echo "------------------------------------------"

    if [ ! -d "${SRC}" ]; then

        echo "WARNING: package directory not found:"
        echo "${SRC}"

        return 0

    fi

    rm -rf "${DEST}"

    cp -a \
        "${SRC}" \
        "${DEST}"
}


# ==========================================================
# 1. Aurora
# ==========================================================

clone_repo \
    "https://github.com/eamonxg/luci-theme-aurora.git" \
    "${CUSTOM_DIR}/luci-theme-aurora"


# ==========================================================
# 2. Aurora Config
# ==========================================================

clone_repo \
    "https://github.com/eamonxg/luci-app-aurora-config.git" \
    "${CUSTOM_DIR}/luci-app-aurora-config"


# ==========================================================
# 3. Shadcn
# ==========================================================

clone_repo \
    "https://github.com/eamonxg/luci-theme-shadcn.git" \
    "${CUSTOM_DIR}/luci-theme-shadcn"


# ==========================================================
# 4. OpenClash
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
# 6. Bandix Backend
# ==========================================================

clone_repo \
    "https://github.com/timsaya/openwrt-bandix.git" \
    "${CUSTOM_DIR}/openwrt-bandix"


# ==========================================================
# 7. Bandix LuCI
# ==========================================================

clone_repo \
    "https://github.com/timsaya/luci-app-bandix.git" \
    "${CUSTOM_DIR}/luci-app-bandix"


# ==========================================================
# 8. 下载 sbwml/openwrt_pkgs
# ==========================================================

echo
echo "=========================================="
echo "Downloading sbwml/openwrt_pkgs"
echo "=========================================="


git clone \
    --depth=1 \
    https://github.com/sbwml/openwrt_pkgs.git \
    "${TMP_DIR}/openwrt_pkgs"


SBWML="${TMP_DIR}/openwrt_pkgs"


# ==========================================================
# 9. 查找 FileBrowser 后端
#
# luci-app-filebrowser-go
#        ↓
# filebrowser
# ==========================================================

echo
echo "=========================================="
echo "FileBrowser"
echo "=========================================="


FILEBROWSER_FOUND=""


for DIR in \
    "${SBWML}/filebrowser" \
    "${SBWML}/package/filebrowser" \
    "${SBWML}/packages/filebrowser" \
    "${SBWML}/luci-app-filebrowser-go/../filebrowser"
do

    if [ -d "${DIR}" ] && [ -f "${DIR}/Makefile" ]; then

        FILEBROWSER_FOUND="${DIR}"

        break

    fi

done


if [ -n "${FILEBROWSER_FOUND}" ]; then

    echo "Found filebrowser:"
    echo "${FILEBROWSER_FOUND}"

    copy_package \
        "${FILEBROWSER_FOUND}" \
        "${CUSTOM_DIR}/filebrowser"

else

    echo
    echo "ERROR: filebrowser backend was not found."
    echo
    echo "Searching repository..."
    echo

    find "${SBWML}" \
        -type f \
        -name Makefile \
        -print \
        | grep -i filebrowser \
        || true

    echo
    echo "The package luci-app-filebrowser-go depends on:"
    echo "filebrowser"
    echo
    echo "Build cannot continue safely."

    exit 1

fi


# ==========================================================
# 10. FileBrowser LuCI
# ==========================================================

echo
echo "=========================================="
echo "luci-app-filebrowser-go"
echo "=========================================="


FILEBROWSER_LUCI=""


for DIR in \
    "${SBWML}/luci-app-filebrowser-go" \
    "${SBWML}/package/luci-app-filebrowser-go" \
    "${SBWML}/packages/luci-app-filebrowser-go"
do

    if [ -d "${DIR}" ] && [ -f "${DIR}/Makefile" ]; then

        FILEBROWSER_LUCI="${DIR}"

        break

    fi

done


if [ -n "${FILEBROWSER_LUCI}" ]; then

    copy_package \
        "${FILEBROWSER_LUCI}" \
        "${CUSTOM_DIR}/luci-app-filebrowser-go"

else

    echo
    echo "ERROR: luci-app-filebrowser-go was not found."

    exit 1

fi


# ==========================================================
# 11. 查找 VLMCSd 后端
#
# luci-app-vlmcsd
#        ↓
#      vlmcsd
# ==========================================================

echo
echo "=========================================="
echo "VLMCSd"
echo "=========================================="


VLMCS_FOUND=""


for DIR in \
    "${SBWML}/vlmcsd" \
    "${SBWML}/package/vlmcsd" \
    "${SBWML}/packages/vlmcsd" \
    "${SBWML}/luci-app-vlmcsd/../vlmcsd"
do

    if [ -d "${DIR}" ] && [ -f "${DIR}/Makefile" ]; then

        VLMCS_FOUND="${DIR}"

        break

    fi

done


if [ -n "${VLMCS_FOUND}" ]; then

    echo "Found vlmcsd:"
    echo "${VLMCS_FOUND}"

    copy_package \
        "${VLMCS_FOUND}" \
        "${CUSTOM_DIR}/vlmcsd"

else

    echo
    echo "ERROR: vlmcsd backend was not found."
    echo
    echo "Searching repository..."
    echo

    find "${SBWML}" \
        -type f \
        -name Makefile \
        -print \
        | grep -Ei 'vlmcs|kms' \
        || true

    echo
    echo "The package luci-app-vlmcsd depends on:"
    echo "vlmcsd"
    echo
    echo "Build cannot continue safely."

    exit 1

fi


# ==========================================================
# 12. VLMCSd LuCI
# ==========================================================

echo
echo "=========================================="
echo "luci-app-vlmcsd"
echo "=========================================="


VLMCS_LUCI=""


for DIR in \
    "${SBWML}/luci-app-vlmcsd" \
    "${SBWML}/package/luci-app-vlmcsd" \
    "${SBWML}/packages/luci-app-vlmcsd"
do

    if [ -d "${DIR}" ] && [ -f "${DIR}/Makefile" ]; then

        VLMCS_LUCI="${DIR}"

        break

    fi

done


if [ -n "${VLMCS_LUCI}" ]; then

    copy_package \
        "${VLMCS_LUCI}" \
        "${CUSTOM_DIR}/luci-app-vlmcsd"

else

    echo
    echo "ERROR: luci-app-vlmcsd was not found."

    exit 1

fi


# ==========================================================
# 13. Timewol
# ==========================================================

echo
echo "=========================================="
echo "Timewol"
echo "=========================================="


TIMEWOL_FOUND=""


for DIR in \
    "${SBWML}/luci-app-timewol" \
    "${SBWML}/package/luci-app-timewol" \
    "${SBWML}/packages/luci-app-timewol" \
    "${SBWML}/luci-app-control-timewol" \
    "${SBWML}/package/luci-app-control-timewol" \
    "${SBWML}/packages/luci-app-control-timewol"
do

    if [ -d "${DIR}" ] && [ -f "${DIR}/Makefile" ]; then

        TIMEWOL_FOUND="${DIR}"

        break

    fi

done


if [ -n "${TIMEWOL_FOUND}" ]; then

    copy_package \
        "${TIMEWOL_FOUND}" \
        "${CUSTOM_DIR}/luci-app-timewol"

else

    echo "WARNING: Timewol package was not found."

fi


# ==========================================================
# 14. Autoreboot
# ==========================================================

echo
echo "=========================================="
echo "Autoreboot"
echo "=========================================="


AUTOREBOOT_FOUND=""


for DIR in \
    "${SBWML}/luci-app-autoreboot" \
    "${SBWML}/package/luci-app-autoreboot" \
    "${SBWML}/packages/luci-app-autoreboot"
do

    if [ -d "${DIR}" ] && [ -f "${DIR}/Makefile" ]; then

        AUTOREBOOT_FOUND="${DIR}"

        break

    fi

done


if [ -n "${AUTOREBOOT_FOUND}" ]; then

    copy_package \
        "${AUTOREBOOT_FOUND}" \
        "${CUSTOM_DIR}/luci-app-autoreboot"

else

    echo "WARNING: Autoreboot package was not found."

fi


# ==========================================================
# 15. 清理 Git
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
# 16. 检查所有 Makefile
# ==========================================================

echo
echo "=========================================="
echo "Installed Custom Packages"
echo "=========================================="


find "${CUSTOM_DIR}" \
    -maxdepth 2 \
    -type f \
    -name Makefile \
    -print \
    | sort


# ==========================================================
# 17. 最终依赖检查
#
# 重点确认：
#
# filebrowser
# vlmcsd
# ==========================================================

echo
echo "=========================================="
echo "Checking required backend packages"
echo "=========================================="


if [ ! -f "${CUSTOM_DIR}/filebrowser/Makefile" ]; then

    echo "ERROR: filebrowser Makefile is missing."

    exit 1

fi


if [ ! -f "${CUSTOM_DIR}/vlmcsd/Makefile" ]; then

    echo "ERROR: vlmcsd Makefile is missing."

    exit 1

fi


if [ ! -f "${CUSTOM_DIR}/luci-app-filebrowser-go/Makefile" ]; then

    echo "ERROR: luci-app-filebrowser-go Makefile is missing."

    exit 1

fi


if [ ! -f "${CUSTOM_DIR}/luci-app-vlmcsd/Makefile" ]; then

    echo "ERROR: luci-app-vlmcsd Makefile is missing."

    exit 1

fi


echo
echo "OK: filebrowser"
echo "OK: luci-app-filebrowser-go"
echo "OK: vlmcsd"
echo "OK: luci-app-vlmcsd"


# ==========================================================
# 18. 完成
# ==========================================================

echo
echo "=========================================="
echo "Custom package preparation completed"
echo "=========================================="

echo
echo "Custom packages are located at:"
echo "${CUSTOM_DIR}"

echo

exit 0
