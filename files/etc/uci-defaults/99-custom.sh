#!/bin/sh
#
# OpenWrt first-boot network customization.
#
# __LAN_IP__ is replaced by the GitHub Actions workflow before ImageBuilder
# creates the firmware.
#

LOGFILE="/tmp/99-custom.log"

echo "99-custom.sh: start $(date)" >> "${LOGFILE}"

LAN_IP="__LAN_IP__"

# Basic validation.
case "${LAN_IP}" in
    ''|*[!0-9.]*)
        echo "Invalid LAN_IP: ${LAN_IP}" >> "${LOGFILE}"
        exit 1
        ;;
esac

# Set the requested LAN address.
if uci -q get network.lan >/dev/null 2>&1; then
    uci set network.lan.ipaddr="${LAN_IP}"
    uci set network.lan.netmask="255.255.255.0"
    uci commit network

    echo "LAN IP set to ${LAN_IP}" >> "${LOGFILE}"
else
    echo "network.lan does not exist" >> "${LOGFILE}"
fi

echo "99-custom.sh: done $(date)" >> "${LOGFILE}"

exit 0
