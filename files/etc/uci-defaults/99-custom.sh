#!/bin/sh
# OpenWrt first-boot network initialization.
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

# Fixed six-port x86-64 layout:
# eth1 = WAN
# eth0/eth2/eth3/eth4/eth5 = LAN
WAN_IF="eth1"
LAN_PORTS="eth0 eth2 eth3 eth4 eth5"

IP_VALUE_FILE="/etc/config/custom_router_ip.txt"
if [ -f "$IP_VALUE_FILE" ]; then
    CUSTOM_IP=$(cat "$IP_VALUE_FILE")
else
    CUSTOM_IP='192.168.1.2'
fi

# Explicitly configure the six physical ports instead of relying on interface discovery.
uci -q set network.br_lan=device
uci -q set network.br_lan.name='br-lan'
uci -q set network.br_lan.type='bridge'
uci -q delete network.br_lan.ports
for port in $LAN_PORTS; do
    uci add_list network.br_lan.ports="$port"
done

uci set network.lan=device 2>/dev/null || true
uci set network.lan.device='br-lan'
uci set network.lan.proto='static'
uci set network.lan.ipaddr="$CUSTOM_IP"
uci set network.lan.netmask='255.255.255.0'

uci set network.wan=interface
uci set network.wan.device="$WAN_IF"

uci set network.wan6=interface
uci set network.wan6.device="$WAN_IF"

if [ "$enable_pppoe" = "yes" ]; then
    uci set network.wan.proto='pppoe'
    uci set network.wan.username="$pppoe_account"
    uci set network.wan.password="$pppoe_password"
    uci set network.wan.peerdns='1'
    uci set network.wan.auto='1'
    uci set network.wan6.proto='none'
else
    uci set network.wan.proto='dhcp'
    uci set network.wan6.proto='dhcpv6'
fi

uci commit network
echo "Using fixed network layout: WAN=$WAN_IF LAN=$LAN_PORTS LAN_IP=$CUSTOM_IP PPPoE=$enable_pppoe" >> "$LOGFILE"

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
