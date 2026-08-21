#!/bin/bash
# ============= OpenWrt 25.12.x APK package selection ============
# ============= Based on wukongdaily ImageBuilder style ==========
# ============= Uncomment package groups as required ==============
#
# This file is the single package selection entry.
# Third-party APK feeds are prepared separately.

CUSTOM_PACKAGES=""

# ==========================
# LuCI + 中文基础环境
# ==========================
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-base-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-package-manager"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-package-manager-zh-cn"


# ==========================
# wukongdaily 第三方 APK 选项
# ==========================

# 快速设置向导
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-quickstart-zh-cn"

# Run安装器
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-run"

# QuickFile 文件管理
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES bash quickfile luci-app-quickfile luci-i18n-quickfile-zh-cn"

# 极光主题
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn"

# shadcn主题
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-shadcn"

# 分区扩容
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-partexp luci-i18n-partexp-zh-cn"

# Bandix流量监控
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES bandix luci-app-bandix luci-i18n-bandix-zh-cn"


# ==========================
# PassWall / SSR Plus
# ==========================

# PassWall2
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria kmod-nft-socket kmod-nft-tproxy luci-app-passwall2 luci-i18n-passwall2-zh-cn"

# SSR Plus
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-tproxy kmod-nft-socket xray-core naiveproxy luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn"

# naiveproxy
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES naiveproxy"


# ==========================
# DAE / DAED eBPF透明代理
# ==========================

#CUSTOM_PACKAGES="$CUSTOM_PACKAGES dae daed luci-app-daede luci-i18n-dae-zh-cn luci-i18n-daed-zh-cn"


# ==========================
# OpenClash
# ==========================

#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash luci-compat kmod-tun kmod-inet-diag kmod-nft-tproxy bash curl ip-full unzip"


# ==========================
# 其它常用插件
# ==========================

# MosDNS
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-mosdns luci-i18n-mosdns-zh-cn"

# WireGuard
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-proto-wireguard"

# Tailscale
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-tailscale-community luci-i18n-tailscale-community-zh-cn"

# ZeroTier
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-zerotier-zh-cn"

# FRPC/FRPS
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-frpc-zh-cn luci-i18n-frps-zh-cn"

# OpenList
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-openlist-zh-cn"

# FileBrowser
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-filebrowser-go-zh-cn luci-i18n-filebrowser-zh-cn"

# Wake On LAN
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-timewol-zh-cn luci-i18n-wol-zh-cn"


# ==========================
# 用户自定义
# ==========================
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES package-name"

export CUSTOM_PACKAGES
printf '%s\n' "$CUSTOM_PACKAGES"
