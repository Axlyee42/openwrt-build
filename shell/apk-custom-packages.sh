#!/usr/bin/env bash

# ============================================================
# OpenWrt 25.12 x86-64 custom packages
#
# 注意：
# 本文件只负责定义 CUSTOM_PACKAGES。
# 不执行下载、编译、make、apk 等操作。
# ============================================================

CUSTOM_PACKAGES="$(cat <<'EOF'
luci
luci-i18n-base-zh-cn
luci-app-package-manager
luci-i18n-package-manager-zh-cn

ppp
ppp-mod-pppoe
kmod-pppoe
luci-proto-ppp
luci-proto-ipv6
odhcp6c
odhcpd-ipv6only

mwan3
luci-app-mwan3
luci-i18n-mwan3-zh-cn

luci-app-upnp
luci-i18n-upnp-zh-cn

luci-app-ttyd
luci-i18n-ttyd-zh-cn

kmod-nft-socket
kmod-nft-tproxy

luci-app-passwall
luci-i18n-passwall-zh-cn

geoview
xray-core
sing-box
hysteria

luci-app-openclash

luci-theme-aurora
luci-app-aurora-config
luci-i18n-aurora-config-zh-cn

luci-theme-shadcn

bandix
luci-app-bandix
luci-i18n-bandix-zh-cn

luci-app-run

luci-app-filebrowser-go
luci-app-vlmcsd
luci-app-timewol
luci-app-autoreboot
EOF
)"

export CUSTOM_PACKAGES
