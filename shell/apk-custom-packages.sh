#!/usr/bin/env bash

set -euo pipefail


# ==========================================================
# OpenWrt Custom APK Packages
# ==========================================================
#
# 这里只维护最终需要安装的软件包。
#
# 软件包来源由 build-x86-64.yml 负责：
#
#   OpenWrt Official APK
#   PassWall APK
#   Aurora APK
#   Bandix APK
#   OpenClash APK
#
# ==========================================================


CUSTOM_PACKAGES="
luci
luci-i18n-base-zh-cn

ppp
ppp-mod-pppoe
kmod-pppoe

luci-proto-ipv6
odhcp6c
odhcpd-ipv6only

mwan3
luci-app-mwan3
luci-i18n-mwan3-zh-cn

luci-app-openclash

luci-app-passwall
luci-i18n-passwall-zh-cn

luci-theme-aurora
luci-app-aurora-config
luci-i18n-aurora-config-zh-cn

bandix
luci-app-bandix
luci-i18n-bandix-zh-cn

luci-app-run

luci-app-filebrowser-go
luci-i18n-filebrowser-go-zh-cn

luci-app-ttyd
luci-i18n-ttyd-zh-cn

luci-app-upnp
luci-i18n-upnp-zh-cn

luci-app-vlmcsd
luci-i18n-vlmcsd-zh-cn

luci-i18n-timewol-zh-cn
luci-i18n-autoreboot-zh-cn
"


# ==========================================================
# 清理空白
# ==========================================================

CUSTOM_PACKAGES="$(
    echo "${CUSTOM_PACKAGES}" |
    xargs
)"


# ==========================================================
# 输出
# ==========================================================

echo
echo "=========================================="
echo "Custom APK packages"
echo "=========================================="
echo

for package in ${CUSTOM_PACKAGES}; do
    echo "  ${package}"
done

echo
echo "=========================================="
echo "Total packages:"
echo "=========================================="

COUNT=0

for package in ${CUSTOM_PACKAGES}; do
    COUNT=$((COUNT + 1))
done

echo "${COUNT}"
echo
