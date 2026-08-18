#!/bin/sh
#
# OpenWrt x86-64 ImageBuilder first-boot customization.
#
# The workflow replaces __LAN_IP__ before building.
#

LAN_IP="__LAN_IP__"

case "${LAN_IP}" in
  ""|*[!0-9.]*)
    exit 1
    ;;
esac

uci -q batch <<EOF
set network.lan.proto='static'
set network.lan.ipaddr='${LAN_IP}'
set network.lan.netmask='255.255.255.0'
EOF

uci commit network

exit 0
