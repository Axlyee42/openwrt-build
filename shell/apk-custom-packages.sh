#!/bin/bash

# ============================================================
# OpenWrt 25.12.x custom APK packages
# Target: x86_64
#
# Based on:
#   Axlyee42/ImmortalWrt-ImageBuilder
#   wukongdaily/ImmortalWrt-ImageBuilder
#
# Purpose:
#   Centralized package selection for the custom OpenWrt build.
#
# IMPORTANT:
#   This file only builds the CUSTOM_PACKAGES variable.
#   The GitHub Actions workflow must source this file before
#   running make defconfig / make.
# ============================================================

set -e

CUSTOM_PACKAGES=""

# ============================================================
# 1. LuCI base
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-ssl"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-base-zh-cn"

# ============================================================
# 2. Default language / LuCI essentials
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-lib-base"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-base"

# ============================================================
# 3. Aurora theme
#    github.com/eamonxg/luci-theme-aurora
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-aurora-config"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-aurora-config-zh-cn"

# ============================================================
# 4. FileBrowser Go
#
# QuickFile intentionally removed because it conflicts with
# luci-app-run's nginx configuration.
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-filebrowser-go"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-filebrowser-go-zh-cn"

# ============================================================
# 5. Bandix
#    github.com/timsaya/luci-app-bandix
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES bandix"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-bandix"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-bandix-zh-cn"

# ============================================================
# 6. luci-app-run
#    github.com/wukongdaily/luci-app-run
#
# OpenWrt 25.12+ uses APK.
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-run"

# ============================================================
# 7. PassWall
#
# PassWall itself comes from the PassWall feed.
# The packages below are runtime dependencies used by the
# current PassWall build configuration.
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES xray-core"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES sing-box"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES hysteria"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-socket"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-tproxy"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-passwall"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-passwall-zh-cn"

# ============================================================
# 8. OpenClash
#    github.com/vernesong/OpenClash
#
# OpenClash official dependencies for current OpenWrt.
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-compat"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES dnsmasq-full"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES bash"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES curl"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES ca-bundle"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES ip-full"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES unzip"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES ipset"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES ruby"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES ruby-yaml"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES iptables"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-ipt-nat"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES iptables-mod-tproxy"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES iptables-mod-extra"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES ip6tables-mod-nat"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-tun"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-inet-diag"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-tproxy"

# ============================================================
# 9. Multi-WAN / mwan3
#
# Required for the planned:
#   WAN1 -> PPPoE
#   WAN2 -> PPPoE
#   Load balancing
#   Failover
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES mwan3"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-mwan3"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-mwan3-zh-cn"

# ============================================================
# 10. Network / PPPoE
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES ppp"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES ppp-mod-pppoe"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-pppoe"

# ============================================================
# 11. Time Wake-on-LAN
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-timewol-zh-cn"

# ============================================================
# 12. Automatic reboot
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-autoreboot-zh-cn"

# ============================================================
# 13. TTYD
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ttyd-zh-cn"

# ============================================================
# 14. UPnP
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-upnp-zh-cn"

# ============================================================
# 15. VLMCSd
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-vlmcsd-zh-cn"

# ============================================================
# 16. Useful network tools
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES iproute2"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES iproute2-ss"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES ethtool"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES tcpdump"

# ============================================================
# 17. DNS / DHCP
#
# OpenClash requires dnsmasq-full.
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES dnsmasq-full"

# ============================================================
# 18. IPv6 / firewall helpers
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES ip6tables"

# ============================================================
# 19. Output
# ============================================================

echo "============================================================"
echo "Custom OpenWrt APK packages"
echo "============================================================"
echo "$CUSTOM_PACKAGES"
echo "============================================================"

export CUSTOM_PACKAGES
