#!/usr/bin/env bash
#
# OpenWrt 25.12.x third-party APK manifest.
#
# IMPORTANT:
# This file is sourced by build-x86-64.yml.
# It MUST NOT clone repositories or build/extract APKs.
#
# The actual APK preparation is done by:
#   scripts/apk-prepare-packages.sh
#
# The list below follows the packages supported by the current
# wukongdaily/apk 25.12.x repository and the package set requested
# for this OpenWrt x86-64 project.
#
# Avoid enabling conflicting proxy frontends together unless you
# deliberately want both.
#

CUSTOM_PACKAGES=""

# Aurora
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn"

# Bandix
CUSTOM_PACKAGES="$CUSTOM_PACKAGES bandix luci-app-bandix luci-i18n-bandix-zh-cn"

# QuickFile / QuickStart
CUSTOM_PACKAGES="$CUSTOM_PACKAGES bash quickfile luci-app-quickfile luci-i18n-quickfile-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-quickstart luci-i18n-quickstart-zh-cn"

# Partition expansion
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-partexp luci-i18n-partexp-zh-cn"

# RTP2HTTPD
CUSTOM_PACKAGES="$CUSTOM_PACKAGES rtp2httpd luci-app-rtp2httpd luci-i18n-rtp2httpd-zh-cn"

# Lucky
CUSTOM_PACKAGES="$CUSTOM_PACKAGES lucky luci-app-lucky luci-i18n-lucky-zh-cn"

# MosDNS
CUSTOM_PACKAGES="$CUSTOM_PACKAGES mosdns luci-app-mosdns luci-i18n-mosdns-zh-cn"

# Nikki
CUSTOM_PACKAGES="$CUSTOM_PACKAGES nikki luci-i18n-nikki-zh-cn"

# Daed / Daede
CUSTOM_PACKAGES="$CUSTOM_PACKAGES daed luci-app-daed luci-i18n-daed-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-daede"

# Clashoo
# Do not add nikki and clashoo together if your configuration uses
# the conflicting LuCI configuration files.
CUSTOM_PACKAGES="$CUSTOM_PACKAGES clashoo luci-app-clashoo luci-i18n-clashoo-zh-cn"

# PassWall
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-passwall luci-i18n-passwall-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria"

# PassWall2
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-passwall2 luci-i18n-passwall2-zh-cn"

# SSR Plus
CUSTOM_PACKAGES="$CUSTOM_PACKAGES xray-core naiveproxy luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn"

# TaskPlan
CUSTOM_PACKAGES="$CUSTOM_PACKAGES taskd luci-lib-taskd luci-app-taskplan luci-i18n-taskplan-zh-cn"

# iStore / Run
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-store luci-app-run"

# Argon
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-argon luci-app-argon-config luci-i18n-argon-config-zh-cn"

# The following kernel packages are NOT third-party APKs.
# They are supplied by the OpenWrt 25.12.x package feed and are
# therefore intentionally NOT placed in this list:
#   kmod-nft-tproxy
#   kmod-nft-socket
#
# If a selected third-party package needs them, add them to the
# normal PACKAGES string in the workflow, not here.
