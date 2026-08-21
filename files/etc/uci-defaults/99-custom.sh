#!/bin/sh
# x86-64 网络初始化，参考 wukongdaily ImageBuilder 的 99-custom.sh。
# 多网口：第一个物理网口作为 WAN，其余物理网口全部加入 br-lan；
# WAN 默认 DHCP，LAN 默认静态 IP；lan_ip 由构建流程写入 custom_router_ip.txt。

LOGFILE="/etc/config/uci-defaults-log.txt"
LAN_IP_FILE="/etc/config/custom_router_ip.txt"

log() {
    echo "[$(date)] $*" >> "$LOGFILE"
}

log "Starting x86 network initialization"

# wukongdaily 风格：首次启动允许 WAN 入站，方便单网口/多网口首次访问 WebUI。
# 用户完成配置后可在 LuCI 防火墙中自行改回拒绝。
uci -q set firewall.@zone[1].input='ACCEPT'

# 获取所有物理以太网接口，x86-64 默认按 eth*/en* 处理。
ifnames=""
for iface in /sys/class/net/*; do
    iface_name="$(basename "$iface")"
    if [ -e "$iface/device" ] && echo "$iface_name" | grep -Eq '^eth|^en'; then
        ifnames="$ifnames $iface_name"
    fi
done
ifnames="$(echo "$ifnames" | awk '{$1=$1};1')"
count="$(echo "$ifnames" | wc -w)"
log "Detected physical interfaces: $ifnames"
log "Interface count: $count"

# 清理旧的 WAN/WAN6 配置，避免与 ImageBuilder 默认配置冲突。
uci -q delete network.wan
uci -q delete network.wan6

if [ "$count" -eq 0 ]; then
    log "No physical Ethernet interface detected; keeping base network configuration"
elif [ "$count" -eq 1 ]; then
    # 单网口：按照 wukongdaily 方案，LAN 使用 DHCP，方便首次接入网络。
    uci set network.lan.proto='dhcp'
    uci -q delete network.lan.ipaddr
    uci -q delete network.lan.netmask
    uci -q delete network.lan.gateway
    uci -q delete network.lan.dns
    uci commit network
    log "Single-NIC mode: LAN DHCP on $ifnames"
else
    # 多网口：第一个接口 WAN，其余全部作为 LAN bridge 成员。
    wan_ifname="$(echo "$ifnames" | awk '{print $1}')"
    lan_ifnames="$(echo "$ifnames" | cut -d ' ' -f2-)"

    log "Multi-NIC mapping: WAN=$wan_ifname LAN=$lan_ifnames"

    uci set network.wan='interface'
    uci set network.wan.device="$wan_ifname"
    uci set network.wan.proto='dhcp'

    uci set network.wan6='interface'
    uci set network.wan6.device="$wan_ifname"
    uci set network.wan6.proto='dhcpv6'

    # 确保 br-lan 存在。
    section="$(uci show network 2>/dev/null | awk -F '[.=]' '/\.@?device\[[0-9]+\]\.name=.br-lan.$/ {print $2; exit}')"
    if [ -z "$section" ]; then
        uci set network.br_lan='device'
        uci set network.br_lan.name='br-lan'
        uci set network.br_lan.type='bridge'
        section='br_lan'
    fi

    uci -q delete "network.$section.ports"
    for port in $lan_ifnames; do
        uci add_list "network.$section.ports"="$port"
    done

    uci set network.lan.device='br-lan'
    uci set network.lan.proto='static'
    uci set network.lan.netmask='255.255.255.0'

    if [ -s "$LAN_IP_FILE" ]; then
        CUSTOM_IP="$(tr -d '[:space:]' < "$LAN_IP_FILE")"
        uci set network.lan.ipaddr="$CUSTOM_IP"
        log "Custom LAN IP: $CUSTOM_IP"
    else
        uci set network.lan.ipaddr='192.168.1.2'
        log "Default LAN IP: 192.168.1.2"
    fi

    uci commit network
fi

# 让 ttyd/SSH 不绑定到单一接口，保持 wukongdaily 的首次配置体验。
uci -q delete ttyd.@ttyd[0].interface
uci -q set dropbear.@dropbear[0].Interface=''
uci commit

log "x86 network initialization completed"
exit 0
