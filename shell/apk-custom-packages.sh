#!/usr/bin/env bash

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
xray-core
sing-box
hysteria
geoview

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
luci-i18n-filebrowser-go-zh-cn

luci-app-vlmcsd
luci-i18n-vlmcsd-zh-cn

luci-app-timewol
luci-i18n-timewol-zh-cn

luci-app-autoreboot
luci-i18n-autoreboot-zh-cn
EOF
)"

export CUSTOM_PACKAGES
