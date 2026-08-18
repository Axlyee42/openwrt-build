#!/usr/bin/env bash

#
# ==========================================================
# Third-party APK packages for OpenWrt 25.12.x
# ==========================================================
#
# IMPORTANT:
#
# 这里只填写第三方 APK。
#
# OpenWrt 官方仓库中的软件，例如：
#
# luci
# luci-ssl
# luci-app-mwan3
# luci-app-upnp
# luci-app-ttyd
# luci-compat
# kmod-tun
# kmod-inet-diag
# kmod-nft-tproxy
# bash
# curl
# ip-full
# unzip
#
# 不要放在这里。
#
# ==========================================================


CUSTOM_PACKAGES="
luci-theme-aurora
luci-app-aurora-config
luci-i18n-aurora-config-zh-cn

bandix
luci-app-bandix
luci-i18n-bandix-zh-cn

luci-app-run

luci-app-filemanager
luci-i18n-filemanager-zh-cn

luci-app-filebrowser-go
luci-i18n-filebrowser-go-zh-cn

luci-app-timewol
luci-i18n-timewol-zh-cn

luci-app-vlmcsd
luci-i18n-vlmcsd-zh-cn

luci-app-autoreboot
luci-i18n-autoreboot-zh-cn

luci-app-passwall
luci-i18n-passwall-zh-cn

geoview
xray-core
sing-box
hysteria

luci-app-openclash
"
