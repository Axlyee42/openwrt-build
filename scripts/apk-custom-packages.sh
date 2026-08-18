#!/usr/bin/env bash

# Third-party APKs supplied by the current x86 wukongdaily APK repository.
# Only packages actually present in that repository belong here.
CUSTOM_PACKAGES="luci-app-run luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn bandix luci-app-bandix luci-i18n-bandix-zh-cn luci-app-passwall luci-i18n-passwall-zh-cn chinadns-ng dns2socks tcping geoview xray-core sing-box hysteria"

# Packages supplied by the OpenWrt/ImmortalWrt package feeds.
# These must NOT be looked up in wukongdaily/apk.
OFFICIAL_PACKAGES="luci-compat kmod-tun kmod-inet-diag kmod-nft-tproxy bash curl ip-full unzip luci-i18n-timewol-zh-cn luci-i18n-autoreboot-zh-cn luci-i18n-ttyd-zh-cn luci-i18n-vlmcsd-zh-cn luci-i18n-upnp-zh-cn"

PACKAGES="$CUSTOM_PACKAGES $OFFICIAL_PACKAGES luci-app-openclash"

export CUSTOM_PACKAGES OFFICIAL_PACKAGES PACKAGES

# Persist the complete package list for later GitHub Actions steps.
if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "PACKAGES=$PACKAGES" >> "$GITHUB_ENV"
fi

# Do not build a local packages.adb here. OpenWrt 25.12 ImageBuilder
# generates its own local APK index during `make image`, after it has
# generated its local signing key. That index is signed when signature
# checking is enabled. Generating an unsigned index here causes the
# ImageBuilder APK resolver to reject it as UNTRUSTED and report every
# custom package as "no such package".
