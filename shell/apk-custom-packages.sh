#!/usr/bin/env bash
# OpenWrt 25.12.x third-party APK package list.
#
# Always enabled: GeoView, Xray-core, sing-box, Hysteria 2.
# HomeProxy is deliberately controlled by the workflow's manual selection.
# PassWall2 is intentionally not included.

CUSTOM_PACKAGES="
  geoview
  xray-core
  sing-box
  hysteria
  luci-app-lucky
  luci-app-ddns-go
"

export CUSTOM_PACKAGES
