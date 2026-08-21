#!/usr/bin/env bash

# Third-party APKs supplied by the current x86 wukongdaily APK repository.
# PassWall is no longer bundled here. It will be installed from the official
# OpenWrt APK feed after the router has WAN connectivity.
CUSTOM_PACKAGES="luci-app-run luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn bandix luci-app-bandix luci-i18n-bandix-zh-cn geoview xray-core sing-box hysteria naiveproxy"

# Packages supplied by OpenWrt feeds.
OFFICIAL_PACKAGES="luci-compat kmod-tun kmod-inet-diag kmod-nft-tproxy kmod-nft-socket bash curl ip-full unzip luci-i18n-timewol-zh-cn luci-i18n-autoreboot-zh-cn luci-i18n-ttyd-zh-cn luci-i18n-vlmcsd-zh-cn luci-i18n-upnp-zh-cn"

PACKAGES="$CUSTOM_PACKAGES $OFFICIAL_PACKAGES luci-app-openclash"

export CUSTOM_PACKAGES OFFICIAL_PACKAGES PACKAGES

if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "PACKAGES=$PACKAGES" >> "$GITHUB_ENV"
fi
