#!/usr/bin/env bash

# Third-party APKs supplied by the current x86 wukongdaily APK repository.
# Official OpenWrt packages are added separately by the workflow.

CUSTOM_PACKAGES="luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn bandix luci-app-bandix luci-i18n-bandix-zh-cn luci-app-passwall luci-i18n-passwall-zh-cn luci-app-passwall2 luci-i18n-passwall2-zh-cn chinadns-ng dns2socks tcping geoview xray-core sing-box hysteria"

export CUSTOM_PACKAGES
