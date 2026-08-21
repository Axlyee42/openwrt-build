#!/bin/bash
# ============= OpenWrt 25.12.x 第三方插件 APK ============
# ============= 若启用则打开注释 ==========================
# ============= 本文件本质是 CUSTOM_PACKAGES 字符串拼接 ====

# DAE / DAED eBPF透明代理
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES dae daed luci-app-daede"

# PassWall2
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria kmod-nft-socket kmod-nft-tproxy luci-app-passwall2 luci-i18n-passwall2-zh-cn"

# SSR Plus
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-tproxy kmod-nft-socket xray-core naiveproxy luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn"

# OpenClash
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash luci-compat kmod-tun kmod-inet-diag kmod-nft-tproxy bash curl ip-full unzip"

# 其它第三方包按需追加

export CUSTOM_PACKAGES
printf '%s\n' "$CUSTOM_PACKAGES"
