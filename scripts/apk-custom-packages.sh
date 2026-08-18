#!/usr/bin/env bash

# OpenWrt 25.12.x THIRD-PARTY APK manifest only.
# Official OpenWrt packages are added by the workflow separately.
#
# PassWall/PassWall2 dependencies that are absent from the official OpenWrt
# 25.12 feed are intentionally included here so apk dependency resolution can
# complete inside the ImageBuilder.

CUSTOM_PACKAGES="luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn bandix luci-app-bandix luci-i18n-bandix-zh-cn luci-app-passwall luci-i18n-passwall-zh-cn luci-app-passwall2 luci-i18n-passwall2-zh-cn chinadns-ng dns2socks tcping geoview luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn clashoo luci-app-clashoo luci-i18n-clashoo-zh-cn luci-app-lucky lucky luci-i18n-lucky-zh-cn luci-app-rtp2httpd luci-i18n-rtp2httpd-zh-cn luci-app-partexp luci-i18n-partexp-zh-cn"

export CUSTOM_PACKAGES
