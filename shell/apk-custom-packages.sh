#!/usr/bin/env bash
# OpenWrt 25.12.x third-party APK package list.
#
# Packages listed below are enabled by default. Other third-party APKs remain
# optional and can be added here when needed.
#
# PassWall2 is intentionally not included.

CUSTOM_PACKAGES="
  geoview
  xray-core
  hysteria
  luci-app-lucky
  luci-app-ddns-go
  luci-app-homeproxy
  luci-i18n-homeproxy-zh-cn
"

export CUSTOM_PACKAGES
