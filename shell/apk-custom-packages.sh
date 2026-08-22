#!/bin/bash
# ============= OpenWrt 25.12.x 仓库外的第三方插件 APK ============
# ============= 若启用则打开注释 ==================================
# ============= 本文件也可以处理仓库内的软件去留，本质是 PACKAGES 拼接 =

# Run 安装器
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-run"
# 极光主题
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn"
# 分区扩容
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-partexp luci-i18n-partexp-zh-cn"
# Bandix 流量监控
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES bandix luci-app-bandix luci-i18n-bandix-zh-cn"
# SSR Plus
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-tproxy kmod-nft-socket xray-core naiveproxy luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn"
# PassWall2
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria kmod-nft-socket kmod-nft-tproxy luci-app-passwall2 luci-i18n-passwall2-zh-cn"
# DAE / DAED
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-dae-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-daed-zh-cn"
# OpenClash
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash luci-compat kmod-tun kmod-inet-diag kmod-nft-tproxy bash curl ip-full unzip"
# Nikki
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-nikki-zh-cn"
# HomeProxy
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-homeproxy-zh-cn"
# PassWall
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria luci-i18n-passwall-zh-cn"
# WireGuard
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-proto-wireguard"
# Tailscale
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-tailscale-community luci-i18n-tailscale-community-zh-cn"
# ZeroTier
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-zerotier-zh-cn"
# FRP
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-frpc-zh-cn"
# FRPS
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-frps-zh-cn"
# DDNS-Go
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ddns-go-zh-cn"
# OpenList
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-openlist-zh-cn"
# FileBrowser-Go
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-filebrowser-go-zh-cn"
# FileManager
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-filemanager-zh-cn"
# TimeWOL
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-timewol-zh-cn"
# Commands
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-commands-zh-cn"

# =============== OpenWrt 官方仓库内的 LuCI 中文包 ===============
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-3cat-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-acme-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-adblock-fast-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-adblock-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-advanced-reboot-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-aria2-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-banip-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-cloudflared-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-diskman-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ddns-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-filebrowser-go-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-mwan3-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-nlbwmon-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-openlist-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-pbr-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-qbittorrent-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-samba4-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-smartdns-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-sqm-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-statistics-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-syncthing-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-transmission-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ttyd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-upnp-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-vlmcsd-zh-cn"
