#!/usr/bin/env bash
# OpenWrt 25.12.x third-party APK package list.
#
# Default packages are enabled here. HomeProxy is deliberately controlled by
# the workflow's manual selection and is appended by build25.sh when enabled.
# PassWall2 is intentionally not included.

CUSTOM_PACKAGES="
  geoview
  xray-core
  hysteria
  luci-app-lucky
  luci-app-ddns-go
"

export CUSTOM_PACKAGES
