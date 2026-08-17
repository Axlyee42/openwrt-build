#!/bin/bash

# ============================================================
# OpenWrt 25.12.x Custom Package List
# ============================================================
#
# Target:
#   Official OpenWrt 25.12.x
#   x86_64
#
# This file ONLY builds the CUSTOM_PACKAGES variable.
#
# It does NOT:
#   - clone repositories
#   - modify .config
#   - run make
#   - install APK files
#
# The GitHub Actions workflow is responsible for:
#   1. Adding third-party source repositories
#   2. Updating feeds
#   3. Generating .config
#   4. Building OpenWrt
#
# ============================================================

#!/bin/bash

set -e

CUSTOM_PACKAGES=""


# ============================================================
# 01. LuCI
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-ssl"

# Simplified Chinese
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-base-zh-cn"


# ============================================================
# 02. Aurora Theme
#
# Project:
# https://github.com/eamonxg/luci-theme-aurora
#
# Config app:
# https://github.com/eamonxg/luci-app-aurora-config
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-aurora-config"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-aurora-config-zh-cn"


# ============================================================
# 03. FileBrowser Go
#
# QuickFile has been REMOVED because it conflicts with
# luci-app-run's nginx configuration.
#
# Keep FileBrowser Go Chinese translation.
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-filebrowser-go-zh-cn"


# ============================================================
# 04. Bandix
#
# Traffic monitoring
#
# Backend:
#   bandix
#
# LuCI:
#   luci-app-bandix
#
# Chinese:
#   luci-i18n-bandix-zh-cn
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES bandix"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-bandix"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-bandix-zh-cn"


# ============================================================
# 05. luci-app-run
#
# Project:
# https://github.com/wukongdaily/luci-app-run
#
# Used to install/run .run packages.
#
# IMPORTANT:
#   QuickFile is intentionally NOT included.
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-run"


# ============================================================
# 06. PassWall
#
# Project:
# https://github.com/Openwrt-Passwall/openwrt-passwall
#
# PassWall itself is provided by the third-party source tree.
#
# Runtime components:
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES xray-core"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES sing-box"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES hysteria"

# nftables transparent proxy support
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-tproxy"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-socket"

# PassWall LuCI
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-passwall"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-passwall-zh-cn"


# ============================================================
# 07. OpenClash
#
# Project:
# https://github.com/vernesong/OpenClash
#
# 25.12 / APK related dependencies
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-compat"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES bash"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES curl"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES ca-bundle"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES ip-full"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES unzip"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-tun"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-inet-diag"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-tproxy"


# ============================================================
# 08. mwan3
#
# Dual WAN:
#
#   eth0 -> WAN
#   eth1 -> WANB
#
# Used later for:
#   - load balancing
#   - failover
#   - policy routing
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES mwan3"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-mwan3"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-mwan3-zh-cn"


# ============================================================
# 09. PPPoE
#
# WAN1 / WAN2 use PPPoE.
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES ppp"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES ppp-mod-pppoe"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-pppoe"


# ============================================================
# 10. IPv6
#
# Required for:
#   - WAN1 IPv6
#   - WAN2 IPv6
#   - DHCPv6
#   - IPv6 Prefix Delegation
#   - LAN IPv6 RA
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-ipv6"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES odhcp6c"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES odhcpd-ipv6only"


# ============================================================
# 11. Timewol
#
# Wake-on-LAN scheduling
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-timewol-zh-cn"


# ============================================================
# 12. Auto Reboot
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-autoreboot-zh-cn"


# ============================================================
# 13. TTYD
#
# LuCI translation
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
#
# These are useful for diagnosing:
#   PPPoE
#   mwan3
#   IPv6
#   routing
#   network interfaces
# ============================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES iproute2"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES iproute2-ss"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES ethtool"


# ============================================================
# 17. Optional diagnostic tools
#
# Uncomment if needed.
# ============================================================

# CUSTOM_PACKAGES="$CUSTOM_PACKAGES tcpdump"


# ============================================================
# 18. Optional WireGuard
#
# Not enabled by default.
# ============================================================

# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-proto-wireguard"
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES wireguard-tools"


# ============================================================
# 19. Optional Tailscale
#
# Not enabled by default.
# ============================================================

# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-tailscale-community"
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-tailscale-community-zh-cn"


# ============================================================
# 20. Optional DDNS
#
# Not enabled by default.
# ============================================================

# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ddns-zh-cn"


# ============================================================
# 21. Optional SMB
#
# Not enabled by default.
# ============================================================

# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ksmbd-zh-cn"


# ============================================================
# 22. Optional Docker
#
# OpenWrt 25.12 x86_64 can run containers, but this is not
# included in the default build to keep the router focused.
# ============================================================

# CUSTOM_PACKAGES="$CUSTOM_PACKAGES dockerd"
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-dockerman"
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-dockerman-zh-cn"


# ============================================================
# 23. Optional File Manager alternatives
# ============================================================

# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-filemanager-zh-cn"


# ============================================================
# 24. Final package list
# ============================================================

echo
echo "============================================================"
echo " OpenWrt 25.12.x Custom Package List"
echo "============================================================"
echo
echo "$CUSTOM_PACKAGES"
echo
echo "============================================================"
echo " End of package list"
echo "============================================================"
echo


# Export for build-x86-64.yml
export CUSTOM_PACKAGES
