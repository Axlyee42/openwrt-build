#!/bin/bash

# ==========================================================
# OpenWrt 25.12.x
#
# Third-party APK packages
#
# 这里只放第三方 APK。
#
# 官方 OpenWrt 软件包不要放这里，
# 由 build-x86-64.yml 的 PACKAGES 处理。
# ==========================================================


CUSTOM_PACKAGES=""


# ==========================================================
# Aurora 极光主题
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-aurora-config"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-aurora-config-zh-cn"


# ==========================================================
# Bandix 流量监控
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES bandix"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-bandix"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-bandix-zh-cn"


# ==========================================================
# luci-app-run
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-run"


# ==========================================================
# PassWall 相关第三方组件
#
# 注意：
#
# luci-app-passwall 本体是否存在于当前第三方 APK 仓库，
# 由第三方 APK 仓库实际提供情况决定。
#
# 这里按照目前 25.12.x 支持清单加入。
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES xray-core"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES sing-box"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES hysteria"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-passwall-zh-cn"


# ==========================================================
# OpenClash
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash"


# ==========================================================
# OpenClash / 代理相关依赖
# ==========================================================

CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-compat"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-tun"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-inet-diag"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-tproxy"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES bash"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES curl"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES ip-full"

CUSTOM_PACKAGES="$CUSTOM_PACKAGES unzip"


# ==========================================================
# 输出
# ==========================================================

CUSTOM_PACKAGES="$(
    echo "${CUSTOM_PACKAGES}" |
    xargs
)


echo
echo "=========================================="
echo "Third-party APK packages"
echo "=========================================="
echo


printf '%s\n' ${CUSTOM_PACKAGES} |
sort


echo
