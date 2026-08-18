#!/bin/bash

# ==========================================================
# OpenWrt / ImmortalWrt 25.12.x
# Third-party APK package list
#
# 第三方 APK 来源：
# https://github.com/wukongdaily/apk
#
# 本文件只负责定义 CUSTOM_PACKAGES。
# 不进行源码编译。
# ==========================================================

CUSTOM_PACKAGES=""

# ==========================================================
# PassWall
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES xray-core"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES sing-box"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES hysteria"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-socket"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-tproxy"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-passwall-zh-cn"

# ==========================================================
# OpenClash
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash"

# ==========================================================
# Aurora
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-aurora-config"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-aurora-config-zh-cn"

# ==========================================================
# Shadcn
#
# 如果第三方仓库没有这个 APK，自动跳过
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-shadcn"

# ==========================================================
# Bandix
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES bandix"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-bandix"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-bandix-zh-cn"

# ==========================================================
# Run
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-run"

# ==========================================================
# FileBrowser Go
#
# wukongdaily 当前清单明确提供中文语言包。
# 主程序如果存在 APK 则一起加入。
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-filebrowser-go-zh-cn"

# ==========================================================
# Timewol
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-timewol-zh-cn"

# ==========================================================
# Autoreboot
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-autoreboot-zh-cn"

# ==========================================================
# VLMCSd
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-vlmcsd-zh-cn"

# ==========================================================
# OpenWrt / LuCI 中文
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-base-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-package-manager-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-upnp-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ttyd-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-mwan3-zh-cn"

# ==========================================================
# 输出
# ==========================================================

echo
echo "=========================================="
echo "CUSTOM_PACKAGES"
echo "=========================================="
echo

echo "${CUSTOM_PACKAGES}"

echo
echo "=========================================="
echo "Package count"
echo "=========================================="

echo "${CUSTOM_PACKAGES}" | wc -w

echo
