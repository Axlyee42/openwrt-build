#!/bin/sh
#
# OpenWrt x86-64 ImageBuilder first-boot LAN configuration.
# The GitHub Actions workflow replaces __LAN_IP__ before building.
#

LAN_IP="__LAN_IP__"

[ -n "${LAN_IP}" ] || exit 0

uci -q set "network.lan.proto=static"
uci -q set "network.lan.ipaddr=${LAN_IP}"
uci -q set "network.lan.netmask=255.255.255.0"

uci -q commit network

exit 0
