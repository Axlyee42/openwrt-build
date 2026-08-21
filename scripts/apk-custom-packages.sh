#!/bin/bash
# ============= OpenWrt 25.12.x APK package selection ============
# ============= All packages are controlled here =================
# ============= Uncomment packages as required ===================
#
# This file is the single package selection entry.
# Third-party APK feeds are prepared separately.

CUSTOM_PACKAGES=""

# ==========================
# LuCI 基础环境
# ==========================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-base-zh-cn"

# 软件包管理器
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-package-manager"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-package-manager-zh-cn"


# ==========================
# 中文相关
# ==========================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-firewall-zh-cn"


# ==========================
# PassWall2
# ==========================

#CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria kmod-nft-socket kmod-nft-tproxy luci-app-passwall2 luci-i18n-passwall2-zh-cn"


# ==========================
# naiveproxy
# ==========================

#CUSTOM_PACKAGES="$CUSTOM_PACKAGES naiveproxy"


# ==========================
# DAE / DAED eBPF透明代理
# ==========================

#CUSTOM_PACKAGES="$CUSTOM_PACKAGES dae daed luci-app-daede"


# ==========================
# SSR Plus
# ==========================

#CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-tproxy kmod-nft-socket xray-core naiveproxy luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn"


# ==========================
# OpenClash
# ==========================

#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash luci-compat kmod-tun kmod-inet-diag kmod-nft-tproxy bash curl ip-full unzip"


# ==========================
# Themes
# ==========================

#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-shadcn"


# ==========================
# Other packages
# ==========================
# Add custom packages below:
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES package-name"


export CUSTOM_PACKAGES
printf '%s\n' "$CUSTOM_PACKAGES"
