#!/usr/bin/env bash

set -euo pipefail

CUSTOM_PACKAGES=""

# ==========================================================
# LuCI
# ==========================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-base-zh-cn"

# ==========================================================
# IPv6 / PPPoE / Multi-WAN
# ==========================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} ppp"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} ppp-mod-pppoe"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} kmod-pppoe"

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-proto-ipv6"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} odhcp6c"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} odhcpd-ipv6only"

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} mwan3"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-mwan3"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-mwan3-zh-cn"

# ==========================================================
# OpenClash
# ==========================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-openclash"

# ==========================================================
# PassWall
# ==========================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-passwall"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-passwall-zh-cn"

# ==========================================================
# Aurora
# ==========================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-theme-aurora"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-aurora-config"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-aurora-config-zh-cn"

# ==========================================================
# Bandix
# ==========================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} bandix"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-bandix"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-bandix-zh-cn"

# ==========================================================
# luci-app-run
# ==========================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-run"

# ==========================================================
# FileBrowser Go
# ==========================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-filebrowser-go"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-filebrowser-go-zh-cn"

# ==========================================================
# 系统 LuCI 应用
# ==========================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-ttyd"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-ttyd-zh-cn"

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-upnp"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-upnp-zh-cn"

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-vlmcsd"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-vlmcsd-zh-cn"

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-timewol-zh-cn"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-autoreboot-zh-cn"

# ==========================================================
# 输出
# ==========================================================

export CUSTOM_PACKAGES

echo
echo "=========================================="
echo "Custom package list"
echo "=========================================="

echo "${CUSTOM_PACKAGES}"
