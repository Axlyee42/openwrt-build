#!/usr/bin/env bash
#
# OpenWrt 25.12.x third-party APK manifest.
#
# This file is intentionally sourceable:
#   source scripts/apk-custom-packages.sh
#
# It only defines CUSTOM_PACKAGES. The workflow downloads and prepares APKs.
#

CUSTOM_PACKAGES=""

# Quickfile
CUSTOM_PACKAGES="$CUSTOM_PACKAGES quickfile luci-app-quickfile luci-i18n-quickfile-zh-cn"

# Aurora
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn"

# Partition expansion
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-partexp luci-i18n-partexp-zh-cn"

# Bandix
CUSTOM_PACKAGES="$CUSTOM_PACKAGES bandix luci-app-bandix luci-i18n-bandix-zh-cn"

# Quickstart
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-quickstart luci-i18n-quickstart-zh-cn"

# RTP2HTTPD
CUSTOM_PACKAGES="$CUSTOM_PACKAGES rtp2httpd luci-app-rtp2httpd luci-i18n-rtp2httpd-zh-cn"

# Lucky
CUSTOM_PACKAGES="$CUSTOM_PACKAGES lucky luci-app-lucky luci-i18n-lucky-zh-cn"

# MosDNS
CUSTOM_PACKAGES="$CUSTOM_PACKAGES mosdns luci-app-mosdns luci-i18n-mosdns-zh-cn"

# Nikki
CUSTOM_PACKAGES="$CUSTOM_PACKAGES nikki luci-i18n-nikki-zh-cn"

# Daed
CUSTOM_PACKAGES="$CUSTOM_PACKAGES daed luci-app-daed luci-i18n-daed-zh-cn luci-app-daede"

# Clashoo
CUSTOM_PACKAGES="$CUSTOM_PACKAGES clashoo luci-app-clashoo luci-i18n-clashoo-zh-cn"

# PassWall
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-passwall luci-i18n-passwall-zh-cn"

# PassWall2
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-passwall2 luci-i18n-passwall2-zh-cn"

# SSR Plus
CUSTOM_PACKAGES="$CUSTOM_PACKAGES xray-core naiveproxy luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn"

# PassWall2 / proxy runtimes
CUSTOM_PACKAGES="$CUSTOM_PACKAGES sing-box hysteria geoview"

# Taskplan
CUSTOM_PACKAGES="$CUSTOM_PACKAGES taskd luci-lib-taskd luci-app-taskplan luci-i18n-taskplan-zh-cn"

# iStore utilities
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-store luci-app-run"

# Normalize and deduplicate.
CUSTOM_PACKAGES="$(
    printf '%s\n' "${CUSTOM_PACKAGES}" |
        tr '[:space:]' '\n' |
        awk 'NF && !seen[$0]++' |
        paste -sd ' ' -
)"

export CUSTOM_PACKAGES
