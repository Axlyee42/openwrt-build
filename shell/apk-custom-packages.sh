#!/usr/bin/env bash

set -euo pipefail


# ============================================================
# OpenWrt 25.12.x x86-64
#
# Final package list
#
# 这个脚本只负责生成：
#
#   /tmp/custom-packages
#
# 后续由 build-x86-64.yml 的 ImageBuilder 流程读取。
#
# 不在这里编译第三方源码。
# 不在这里处理 SDK。
# 不在这里直接下载 APK。
# ============================================================


OUTPUT="/tmp/custom-packages"


rm -f "${OUTPUT}"

touch "${OUTPUT}"


# ============================================================
# 基础 LuCI
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

luci
luci-i18n-base-zh-cn

# LuCI 软件包管理
luci-app-package-manager
luci-i18n-package-manager-zh-cn

EOF


# ============================================================
# PPP / PPPoE
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

ppp
ppp-mod-pppoe
kmod-pppoe

luci-proto-ppp
luci-proto-ipv6

odhcp6c
odhcpd-ipv6only

EOF


# ============================================================
# 多 WAN
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

mwan3
luci-app-mwan3
luci-i18n-mwan3-zh-cn

EOF


# ============================================================
# UPnP
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

luci-app-upnp
luci-i18n-upnp-zh-cn

EOF


# ============================================================
# TTYD
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

luci-app-ttyd
luci-i18n-ttyd-zh-cn

EOF


# ============================================================
# PassWall
#
# PassWall LuCI
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

luci-app-passwall
luci-i18n-passwall-zh-cn

EOF


# ============================================================
# PassWall 核心
#
# 这些包来自 PassWall packages feed。
#
# Geoview：
#   Sing-box 分流需要
#
# Xray：
#   Xray Core
#
# Sing-box：
#   Sing-box Core
#
# Hysteria：
#   Hysteria Core
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

geoview
xray-core
sing-box
hysteria

EOF


# ============================================================
# OpenClash
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

luci-app-openclash

EOF


# ============================================================
# Aurora
#
# 第三方 APK / 本地包
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

luci-theme-aurora
luci-app-aurora-config
luci-i18n-aurora-config-zh-cn

EOF


# ============================================================
# Bandix
#
# 第三方 APK / 本地包
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

bandix
luci-app-bandix
luci-i18n-bandix-zh-cn

EOF


# ============================================================
# Run
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

luci-app-run

EOF


# ============================================================
# FileBrowser Go
#
# 当前使用你之前已经成功找到的第三方包。
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

luci-app-filebrowser-go
luci-i18n-filebrowser-go-zh-cn

EOF


# ============================================================
# VLMCSd
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

luci-app-vlmcsd
luci-i18n-vlmcsd-zh-cn

EOF


# ============================================================
# TimeWOL
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

luci-app-timewol
luci-i18n-timewol-zh-cn

EOF


# ============================================================
# AutoReboot
# ============================================================

cat >> "${OUTPUT}" <<'EOF'

luci-app-autoreboot
luci-i18n-autoreboot-zh-cn

EOF


# ============================================================
# 读取仓库中用户额外指定的包
#
# 如果 build workflow 在运行前已经生成：
#
#   /tmp/extra-packages
#
# 则追加进去。
#
# 这样以后增加包时，不需要修改这个脚本。
# ============================================================

if [ -f /tmp/extra-packages ]; then

    cat /tmp/extra-packages >> "${OUTPUT}"

fi


# ============================================================
# 清理
#
# 删除：
#   - 空行
#   - 注释
#
# 去重。
# ============================================================

sed -i \
    '/^[[:space:]]*$/d' \
    "${OUTPUT}"

sed -i \
    '/^[[:space:]]*#/d' \
    "${OUTPUT}"


sort -u \
    "${OUTPUT}" \
    -o "${OUTPUT}"


# ============================================================
# 最终检查
# ============================================================

echo
echo "=========================================="
echo "Final custom package list"
echo "=========================================="
echo

cat "${OUTPUT}"


echo
echo "=========================================="
echo "Package count"
echo "=========================================="

wc -l "${OUTPUT}"


# ============================================================
# 必须存在的核心包检查
# ============================================================

echo
echo "=========================================="
echo "Checking required packages"
echo "=========================================="

REQUIRED_PACKAGES=(
    "luci"
    "luci-i18n-base-zh-cn"

    "luci-app-package-manager"
    "luci-i18n-package-manager-zh-cn"

    "ppp"
    "ppp-mod-pppoe"
    "kmod-pppoe"

    "mwan3"
    "luci-app-mwan3"

    "luci-app-upnp"

    "luci-app-passwall"
    "luci-i18n-passwall-zh-cn"

    "geoview"
    "xray-core"
    "sing-box"
    "hysteria"

    "luci-app-openclash"

    "luci-theme-aurora"
    "luci-app-aurora-config"

    "bandix"
    "luci-app-bandix"

    "luci-app-run"

    "luci-app-filebrowser-go"

    "luci-app-vlmcsd"

    "luci-app-timewol"

    "luci-app-autoreboot"
)


FAILED=0


for PACKAGE in "${REQUIRED_PACKAGES[@]}"; do

    if grep -Fxq "${PACKAGE}" "${OUTPUT}"; then

        echo "OK: ${PACKAGE}"

    else

        echo "ERROR: Missing package:"
        echo "       ${PACKAGE}"

        FAILED=1

    fi

done


if [ "${FAILED}" -ne 0 ]; then

    echo
    echo "=========================================="
    echo "ERROR: Required package check failed."
    echo "=========================================="

    exit 1

fi


echo
echo "=========================================="
echo "Package list generated successfully."
echo "=========================================="
