#!/usr/bin/env bash

set -euo pipefail


# ============================================================
# OpenWrt 25.12.x x86-64
#
# 第三方 / 自定义软件包清单
#
# 注意：
#
# 1. 官方 OpenWrt 包由官方 feeds 提供
# 2. PassWall 核心由 PassWall packages feed 提供
# 3. PassWall LuCI 由 PassWall LuCI feed 提供
# 4. Bandix 由 Bandix feeds 提供
# 5. Aurora / OpenClash / luci-app-run 由 package/custom 提供
#
# 本文件只负责提供 CUSTOM_PACKAGES。
# ============================================================


CUSTOM_PACKAGES="
luci
luci-i18n-base-zh-cn

luci-app-package-manager
luci-i18n-package-manager-zh-cn

ppp
ppp-mod-pppoe
kmod-pppoe

luci-proto-ppp
luci-proto-ipv6

ipv6
kmod-ipv6

odhcp6c
odhcpd-ipv6only

mwan3
luci-app-mwan3
luci-i18n-mwan3-zh-cn

luci-app-upnp
luci-i18n-upnp-zh-cn

luci-app-ttyd
luci-i18n-ttyd-zh-cn


# ============================================================
# PassWall
# ============================================================

luci-app-passwall
luci-i18n-passwall-zh-cn

geoview
xray-core
sing-box
hysteria


# ============================================================
# OpenClash
# ============================================================

luci-app-openclash


# ============================================================
# nftables TProxy
# ============================================================

kmod-nft-socket
kmod-nft-tproxy


# ============================================================
# Aurora
# ============================================================

luci-theme-aurora
luci-app-aurora-config
luci-i18n-aurora-config-zh-cn


# ============================================================
# Bandix
# ============================================================

bandix
luci-app-bandix
luci-i18n-bandix-zh-cn


# ============================================================
# luci-app-run
# ============================================================

luci-app-run


# ============================================================
# FileBrowser Go
# ============================================================

luci-app-filebrowser-go
luci-i18n-filebrowser-go-zh-cn


# ============================================================
# VLMCSd
# ============================================================

luci-app-vlmcsd
luci-i18n-vlmcsd-zh-cn


# ============================================================
# TimeWOL
# ============================================================

luci-app-timewol
luci-i18n-timewol-zh-cn


# ============================================================
# AutoReboot
# ============================================================

luci-app-autoreboot
luci-i18n-autoreboot-zh-cn
"


# ============================================================
# 清理空白 / 注释
#
# CUSTOM_PACKAGES 最终保持：
#
# 每行一个 package
# ============================================================

CUSTOM_PACKAGES="$(
  printf '%s\n' "${CUSTOM_PACKAGES}" |
  sed \
    -e '/^[[:space:]]*$/d' \
    -e '/^[[:space:]]*#/d'
)"


# ============================================================
# 去重
# ============================================================

CUSTOM_PACKAGES="$(
  printf '%s\n' "${CUSTOM_PACKAGES}" |
  sort -u
)"


# ============================================================
# 输出
# ============================================================

echo
echo "=========================================="
echo "CUSTOM_PACKAGES"
echo "=========================================="

printf '%s\n' "${CUSTOM_PACKAGES}"

echo
echo "Package count:"

printf '%s\n' "${CUSTOM_PACKAGES}" | wc -l
