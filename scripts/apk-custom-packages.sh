#!/usr/bin/env bash

# OpenWrt 25.12.x third-party APK manifest.
# Keep this list limited to packages supplied by the current x86
# wukongdaily APK repository. Packages that are not present in that
# repository must not be requested here because apk will fail the image
# build when a requested package cannot be selected.

CUSTOM_PACKAGES="luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn bandix luci-app-bandix luci-i18n-bandix-zh-cn luci-app-passwall luci-i18n-passwall-zh-cn luci-app-passwall2 luci-i18n-passwall2-zh-cn chinadns-ng dns2socks tcping geoview luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn clashoo luci-app-clashoo luci-i18n-clashoo-zh-cn luci-app-lucky lucky luci-i18n-lucky-zh-cn luci-app-rtp2httpd luci-i18n-rtp2httpd-zh-cn luci-app-partexp luci-i18n-partexp-zh-cn"

export CUSTOM_PACKAGES
