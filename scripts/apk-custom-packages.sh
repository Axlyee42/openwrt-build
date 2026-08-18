#!/usr/bin/env bash

# OpenWrt 25.12.x THIRD-PARTY APK manifest only.
#
# Official OpenWrt packages are intentionally NOT listed here.
# The workflow adds official packages separately to BASE_PACKAGES.
# These names are provided by wukongdaily/apk for x86_64.

CUSTOM_PACKAGES="luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn bandix luci-app-bandix luci-i18n-bandix-zh-cn luci-app-passwall2 luci-i18n-passwall2-zh-cn luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn clashoo luci-app-clashoo luci-i18n-clashoo-zh-cn luci-app-lucky lucky luci-i18n-lucky-zh-cn luci-app-rtp2httpd luci-i18n-rtp2httpd-zh-cn luci-app-partexp luci-i18n-partexp-zh-cn"

export CUSTOM_PACKAGES
