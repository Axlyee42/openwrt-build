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
  luci-app-passwall
  luci-i18n-passwall-zh-cn
  luci-app-openclash
  geoview
  xray-core
  hysteria
  luci-app-lucky
  luci-app-ddns-go
  luci-app-homeproxy
  luci-i18n-homeproxy-zh-cn
"

export CUSTOM_PACKAGES
