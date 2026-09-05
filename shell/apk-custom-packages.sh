#!/usr/bin/env bash

# OpenWrt 25.12.x third-party APK selections.
#
# Each optional LuCI application is kept together with its Chinese language
# package and required runtime dependencies, following the wukongdaily style.
# Uncomment a line to enable that application.
#
# PassWall2 is intentionally not included.

CUSTOM_PACKAGES=""

# Default proxy components.
CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria"

# OpenClash + Chinese translation + required dependencies.
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash luci-i18n-openclash-zh-cn luci-compat kmod-tun kmod-inet-diag kmod-nft-tproxy bash curl ip-full unzip"

# PassWall + Chinese translation + proxy runtimes.
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-passwall luci-i18n-passwall-zh-cn geoview xray-core sing-box hysteria"

# HomeProxy + Chinese translation.
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-homeproxy luci-i18n-homeproxy-zh-cn"

# MWAN3 + Chinese translation.
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-mwan3 luci-i18n-mwan3-zh-cn"

# Lucky + Chinese translation + runtime.
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-lucky luci-i18n-lucky-zh-cn lucky"

# DDNS-Go + Chinese translation + runtime.
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-ddns-go luci-i18n-ddns-go-zh-cn ddns-go"

CUSTOM_PACKAGES="$(printf '%s\n' "$CUSTOM_PACKAGES" | xargs)"
export CUSTOM_PACKAGES
