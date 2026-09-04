#!/usr/bin/env bash
# OpenWrt 25.12.x third-party APK package list.
#
# Packages listed below are included by default. Other third-party APKs remain
# OPT-IN by uncommenting them here.
#
# PassWall2 is intentionally not offered here because it is not needed.

CUSTOM_PACKAGES="
   luci-theme-aurora
   luci-app-aurora-config
   luci-i18n-aurora-config-zh-cn

  # bandix
   luci-app-bandix
   luci-i18n-bandix-zh-cn

   luci-app-run

   luci-app-filebrowser-go
   luci-i18n-filebrowser-go-zh-cn

   luci-app-timewol
   luci-i18n-timewol-zh-cn

   luci-app-vlmcsd
   luci-i18n-vlmcsd-zh-cn

   luci-app-autoreboot
   luci-i18n-autoreboot-zh-cn

   # Network port status
   luci-app-port-status

  # luci-app-passwall
  # luci-i18n-passwall-zh-cn

  # OpenClash remains optional.
  # luci-app-openclash

  # Default proxy/network packages.
  geoview
  xray-core
  hysteria

  # Lucky
  luci-app-lucky

  # DDNS-Go
  luci-app-ddns-go

  # HomeProxy (szwjp fork, sing-box 1.14 compatible)
  luci-app-homeproxy
  luci-i18n-homeproxy-zh-cn
"

# Strip commented/blank lines so only uncommented entries become active.
CUSTOM_PACKAGES="$(printf '%s\n' "$CUSTOM_PACKAGES" | sed 's/#.*//' | xargs)"
export CUSTOM_PACKAGES
