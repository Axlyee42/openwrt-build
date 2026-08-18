#!/usr/bin/env bash

# OpenWrt 25.12.x third-party APK package manifest.
#
# This file ONLY defines third-party packages.
# Official OpenWrt packages must NOT be added here.
#
# The workflow loads this file with:
#   source scripts/apk-custom-packages.sh
#
# Keep CUSTOM_PACKAGES as a single-line, space-separated value.
# This avoids corrupting GITHUB_ENV when the workflow exports it.

CUSTOM_PACKAGES="luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn bandix luci-app-bandix luci-i18n-bandix-zh-cn luci-app-run luci-app-filemanager luci-i18n-filemanager-zh-cn luci-app-filebrowser-go luci-i18n-filebrowser-go-zh-cn luci-app-timewol luci-i18n-timewol-zh-cn luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn luci-app-autoreboot luci-i18n-autoreboot-zh-cn luci-app-passwall luci-i18n-passwall-zh-cn geoview xray-core sing-box hysteria luci-app-openclash"

export CUSTOM_PACKAGES
