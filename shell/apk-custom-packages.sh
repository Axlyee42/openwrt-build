#!/usr/bin/env bash
# OpenWrt 25.12.x third-party APK package list.
# Only packages supplied by the third-party APK repository belong here.
# Official OpenWrt packages are intentionally kept in build25.sh.

CUSTOM_PACKAGES="
  luci-theme-aurora
  luci-app-aurora-config
  luci-i18n-aurora-config-zh-cn

  bandix
  luci-app-bandix
  luci-i18n-bandix-zh-cn

  luci-app-run

  luci-app-filemanager
  luci-i18n-filemanager-zh-cn

  luci-app-filebrowser-go
  luci-i18n-filebrowser-go-zh-cn

  luci-app-timewol
  luci-i18n-timewol-zh-cn

  luci-app-vlmcsd
  luci-i18n-vlmcsd-zh-cn

  luci-app-autoreboot
  luci-i18n-autoreboot-zh-cn

  luci-app-passwall
  luci-i18n-passwall-zh-cn
  geoview
  xray-core
  sing-box
  hysteria

  luci-app-openclash
"

CUSTOM_PACKAGES="$(printf '%s\n' "$CUSTOM_PACKAGES" | xargs)"
export CUSTOM_PACKAGES
