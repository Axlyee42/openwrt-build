#!/usr/bin/env bash
# OpenWrt 25.12.x third-party APK package list.
#
# All third-party APKs are OPT-IN. Uncomment a package line below to include it.
# Packages from wukongdaily/apk are only staged when at least one option is enabled.
#
# PassWall2 is intentionally not offered here because it is not needed.

CUSTOM_PACKAGES="
  # luci-theme-aurora
  # luci-app-aurora-config
  # luci-i18n-aurora-config-zh-cn

  # bandix
  # luci-app-bandix
  # luci-i18n-bandix-zh-cn

  # luci-app-run

  # luci-app-filebrowser-go
  # luci-i18n-filebrowser-go-zh-cn

  # luci-app-timewol
  # luci-i18n-timewol-zh-cn

  # luci-app-vlmcsd
  # luci-i18n-vlmcsd-zh-cn

  # luci-app-autoreboot
  # luci-i18n-autoreboot-zh-cn

  # luci-app-passwall
  # luci-i18n-passwall-zh-cn
  # geoview
  # xray-core
  # sing-box
  # hysteria

  # luci-app-openclash

  # HomeProxy (szwjp fork, sing-box 1.14 compatible)
  # luci-app-homeproxy
  # luci-i18n-homeproxy-zh-cn
"

# Strip commented/blank lines so only uncommented entries become active.
CUSTOM_PACKAGES="$(printf '%s\n' "$CUSTOM_PACKAGES" | sed 's/#.*//' | xargs)"
export CUSTOM_PACKAGES
