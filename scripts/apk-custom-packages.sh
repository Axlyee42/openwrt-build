#!/usr/bin/env bash

# OpenWrt 25.12.x THIRD-PARTY APK manifest only.
#
# IMPORTANT:
# The wukongdaily x86 APK repository contains not only the plugins explicitly
# selected for the image, but also APKs which replace packages that are not in
# the official 25.12.5 feeds (Argon, SSR dependencies, RTP2HTTPD dependencies,
# Hysteria, etc.).  They must all be copied into ImageBuilder/packages so apk
# can resolve dependencies during make image.

CUSTOM_PACKAGES="luci-theme-argon luci-app-argon-config luci-i18n-argon-config-zh-cn luci-i18n-autoreboot-zh-cn luci-i18n-filebrowser-go-zh-cn luci-i18n-timewol-zh-cn luci-i18n-vlmcsd-zh-cn hysteria rtp2httpd dns2tcp ipt2socks lua-neturl shadowsocksr-libev-ssr-local shadowsocksr-libev-ssr-redir luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn bandix luci-app-bandix luci-i18n-bandix-zh-cn luci-app-passwall luci-i18n-passwall-zh-cn luci-app-passwall2 luci-i18n-passwall2-zh-cn chinadns-ng dns2socks tcping geoview luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn clashoo luci-app-clashoo luci-i18n-clashoo-zh-cn luci-app-lucky lucky luci-i18n-lucky-zh-cn luci-app-rtp2httpd luci-i18n-rtp2httpd-zh-cn luci-app-partexp luci-i18n-partexp-zh-cn"

export CUSTOM_PACKAGES
