#!/usr/bin/env bash
# OpenWrt 25.12.x third-party APK package list.
#
# All third-party APKs are OPT-IN. Uncomment a package below to include it.
# Keep this list intentionally small: packages pulled from wukongdaily/apk are
# otherwise only staged/signed and are not installed into the firmware.
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
"

# Remove comments/blank lines so only uncommented entries become active.
CUSTOM_PACKAGES="$(printf '%s\n' "$CUSTOM_PACKAGES" | sed 's/#.*//' | xargs)"
export CUSTOM_PACKAGES
