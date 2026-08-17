#!/usr/bin/env bash

# ============================================================
# OpenWrt 25.12.x
#
# 第三方 APK 软件清单
#
# 说明：
#   OpenWrt 25.12 使用 APK
#
#   本文件只负责定义 CUSTOM_PACKAGES
#
#   build-x86-64.yml 会：
#
#   1. 下载官方 OpenWrt ImageBuilder
#   2. 下载 wukongdaily/apk
#   3. 把第三方 APK 放入 ImageBuilder/packages/
#   4. 使用 ImageBuilder 构建
#
# ============================================================

CUSTOM_PACKAGES=""


# ============================================================
# LuCI
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-ssl"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-base-zh-cn"


# ============================================================
# IPv6
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-proto-ipv6"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} odhcp6c"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} odhcpd-ipv6only"


# ============================================================
# PPPoE
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} ppp"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} ppp-mod-pppoe"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} kmod-pppoe"


# ============================================================
# 双 WAN / 负载均衡
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} mwan3"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-mwan3"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-mwan3-zh-cn"


# ============================================================
# UPnP
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-upnp"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-upnp-zh-cn"


# ============================================================
# ttyd
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-ttyd"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-ttyd-zh-cn"


# ============================================================
# VLMCSd
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-vlmcsd"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-vlmcsd-zh-cn"


# ============================================================
# 自动重启
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-autoreboot"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-autoreboot-zh-cn"


# ============================================================
# Timewol
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-timewol-zh-cn"


# ============================================================
# FileBrowser Go
#
# 之前已经取消 quickfile
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-filebrowser-go"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-filebrowser-go-zh-cn"


# ============================================================
# PassWall
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-passwall"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-passwall-zh-cn"

# PassWall 常用核心
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} xray-core"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} sing-box"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} hysteria"


# ============================================================
# OpenClash
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-openclash"


# ============================================================
# Aurora
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-theme-aurora"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-aurora-config"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-aurora-config-zh-cn"


# ============================================================
# Bandix
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} bandix"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-bandix"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-i18n-bandix-zh-cn"


# ============================================================
# luci-app-run
# ============================================================

CUSTOM_PACKAGES="${CUSTOM_PACKAGES} luci-app-run"


# ============================================================
# 清理前后空格
# ============================================================

CUSTOM_PACKAGES="$(printf '%s' "${CUSTOM_PACKAGES}" | xargs)"


echo
echo "=========================================="
echo "OpenWrt 25.12 custom packages"
echo "=========================================="

printf '%s\n' "${CUSTOM_PACKAGES}"

echo
echo "Package count:"
printf '%s\n' "${CUSTOM_PACKAGES}" | wc -w
