#!/usr/bin/env bash

set -euo pipefail

# ==========================================================
# OpenWrt 25.12.x ImageBuilder
#
# 第三方 APK 清单
#
# 这里仅维护需要加入固件的软件名称。
#
# 实际 APK 来自：
#
# https://github.com/wukongdaily/apk
#
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

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-passwall"
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
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-shadcn"


# ==========================================================
# Bandix
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES bandix"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-bandix"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-bandix-zh-cn"


# ==========================================================
# luci-app-run
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-run"


# ==========================================================
# FileBrowser Go
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-filebrowser-go"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-filebrowser-go-zh-cn"


# ==========================================================
# VLMCSd
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES vlmcsd"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-vlmcsd"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-vlmcsd-zh-cn"


# ==========================================================
# Timewol
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-timewol"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-timewol-zh-cn"


# ==========================================================
# Autoreboot
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-autoreboot"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-autoreboot-zh-cn"


# ==========================================================
# OpenWrt 官方仓库中的中文包
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
echo "Custom APK packages"
echo "=========================================="
echo

echo "${CUSTOM_PACKAGES}"

echo
echo "=========================================="
echo "Package count"
echo "=========================================="

echo "${CUSTOM_PACKAGES}" | wc -w

echo

export CUSTOM_PACKAGES
