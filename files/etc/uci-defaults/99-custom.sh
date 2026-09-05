#!/bin/sh
# OpenWrt first-boot network initialization, aligned with wukongdaily/ImmortalWrt-ImageBuilder.
LOGFILE="/etc/config/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> "$LOGFILE"

# Allow first access to the WebUI on the WAN side for initial setup.
uci set firewall.@zone[1].input='ACCEPT'

# Android TV connectivity workaround.
uci add dhcp domain
uci set "dhcp.@domain[-1].name=time.android.com"
uci set "dhcp.@domain[-1].ip=203.107.6.88"

SETTINGS_FILE="/etc/config/pppoe-settings"
if [ -f "$SETTINGS_FILE" ]; then
    . "$SETTINGS_FILE"
else
    echo "PPPoE settings file not found. Skipping." >> "$LOGFILE"
    enable_pppoe='no'
fi

# Detect physical Ethernet interfaces. VirtIO interfaces in PVE appear here as ethX.
ifnames=""
for iface in /sys/class/net/*; do
    iface_name=$(basename "$iface")
    if [ -e "$iface/device" ] && echo "$iface_name" | grep -Eq '^eth|^en'; then
        ifnames="$ifnames $iface_name"
    fi
done
ifnames=$(echo "$ifnames" | awk '{$1=$1};1')
count=$(echo "$ifnames" | wc -w)
echo "Detected physical interfaces: $ifnames" >> "$LOGFILE"
echo "Interface count: $count" >> "$LOGFILE"

board_name=$(cat /tmp/sysinfo/board_name 2>/dev/null || echo "unknown")
echo "Board detected: $board_name" >> "$LOGFILE"

wan_ifname=""
lan_ifnames=""
case "$board_name" in
    "radxa,e20c"|"friendlyarm,nanopi-r5c")
        wan_ifname="eth1"
        lan_ifnames="eth0"
        ;;
    *)
        wan_ifname=$(echo "$ifnames" | awk '{print $1}')
        lan_ifnames=$(echo "$ifnames" | cut -d ' ' -f2-)
        ;;
esac

echo "Using WAN=$wan_ifname LAN=$lan_ifnames" >> "$LOGFILE"

if [ "$count" -eq 1 ]; then
    # Exactly one physical NIC: keep wukongdaily's DHCP management mode.
    uci set network.lan.proto='dhcp'
    uci delete network.lan.ipaddr 2>/dev/null || true
    uci delete network.lan.netmask 2>/dev/null || true
    uci delete network.lan.gateway 2>/dev/null || true
    uci delete network.lan.dns 2>/dev/null || true
    uci commit network
elif [ "$count" -gt 1 ]; then
    # Multi-NIC: first NIC is WAN, all remaining NICs are LAN.
    uci set network.wan=interface
    uci set network.wan.device="$wan_ifname"
    uci set network.wan.proto='dhcp'

    # Preserve IPv6 on WAN by using DHCPv6 when PPPoE is disabled.
    uci set network.wan6=interface
    uci set network.wan6.device="$wan_ifname"
    uci set network.wan6.proto='dhcpv6'

    section=$(uci show network | awk -F '[.=]' '/\.@?device\[[0-9]+\]\.name=.br-lan.$/ {print $2; exit}')
    if [ -z "$section" ]; then
        echo "error: cannot find device br-lan" >> "$LOGFILE"
    else
        uci -q delete "network.$section.ports"
        for port in $lan_ifnames; do
            uci add_list "network.$section.ports"="$port"
        done
    fi

    uci set network.lan.proto='static'
    uci set network.lan.netmask='255.255.255.0'
    IP_VALUE_FILE="/etc/config/custom_router_ip.txt"
    if [ -f "$IP_VALUE_FILE" ]; then
        CUSTOM_IP=$(cat "$IP_VALUE_FILE")
    else
        CUSTOM_IP='192.168.1.2'
    fi
    uci set network.lan.ipaddr="$CUSTOM_IP"
    echo "LAN IP=$CUSTOM_IP" >> "$LOGFILE"

    if [ "$enable_pppoe" = "yes" ]; then
        uci set network.wan.proto='pppoe'
        uci set network.wan.username="$pppoe_account"
        uci set network.wan.password="$pppoe_password"
        uci set network.wan.peerdns='1'
        uci set network.wan.auto='1'
        uci set network.wan6.proto='none'
    else
        # DHCP WAN: keep IPv6 enabled.
        uci set network.wan6.proto='dhcpv6'
        uci set network.wan6.device="$wan_ifname"
    fi

    uci commit network
fi

# Expose ttyd and SSH on all interfaces.
uci delete ttyd.@ttyd[0].interface 2>/dev/null || true
uci set dropbear.@dropbear[0].Interface=''
uci commit

FILE_PATH="/etc/openwrt_release"
if [ -f "$FILE_PATH" ]; then
    sed -i "s/DISTRIB_DESCRIPTION='[^']*'/DISTRIB_DESCRIPTION='Packaged by wukongdaily'/" "$FILE_PATH"
fi

# Optional compatibility fixes from the reference project.
if [ -f /usr/lib/lua/luci/controller/advancedplus.lua ]; then
    sed -i '/\/usr\/bin\/zsh/d' /etc/profile
    sed -i '/\/bin\/zsh/d' /etc/init.d/advancedplus
    sed -i '/\/usr\/bin\/zsh/d' /etc/init.d/advancedplus
fi

if [ -f /usr/bin/quickfile ]; then
    uci set nginx.global.uci_enable='true'
    uci del nginx._lan 2>/dev/null || true
    uci del nginx._redirect2ssl 2>/dev/null || true
    uci add nginx server
    uci rename nginx.@server[-1]='_lan'
    uci set nginx._lan.server_name='_lan'
    uci add_list nginx._lan.listen='80 default_server'
    uci add_list nginx._lan.listen='[::]:80 default_server'
    uci add_list nginx._lan.include='conf.d/*.locations'
    uci set nginx._lan.access_log='off; # logd openwrt'
    uci commit nginx
fi

if command -v dockerd >/dev/null 2>&1; then
    FW_FILE="/etc/config/firewall"
    uci delete firewall.docker 2>/dev/null || true
    for idx in $(uci show firewall | grep "=forwarding" | cut -d[ -f2 | cut -d] -f1 | sort -rn); do
        src=$(uci get firewall.@forwarding[$idx].src 2>/dev/null || true)
        dest=$(uci get firewall.@forwarding[$idx].dest 2>/dev/null || true)
        if [ "$src" = "docker" ] || [ "$dest" = "docker" ]; then
            uci delete firewall.@forwarding[$idx]
        fi
    done
    uci commit firewall
    cat <<EOF >> "$FW_FILE"

config zone 'docker'
  option input 'ACCEPT'
  option output 'ACCEPT'
  option forward 'ACCEPT'
  option name 'docker'
  list subnet '172.16.0.0/12'

config forwarding
  option src 'docker'
  option dest 'lan'

config forwarding
  option src 'docker'
  option dest 'wan'

config forwarding
  option src 'lan'
  option dest 'docker'
EOF
fi

exit 0
