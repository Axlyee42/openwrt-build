#!/usr/bin/env bash

# OpenWrt 25.12.x THIRD-PARTY APK manifest only.
#
# These are the third-party APKs actually present in the current x86
# wukongdaily APK repository.  The ImageBuilder step copies the complete
# prepared APK set so apk can resolve their transitive dependencies.
#
# Do not list packages that are absent from the repository: apk will fail the
# whole image build when a requested package cannot be selected.

CUSTOM_PACKAGES="luci-theme-argon luci-app-argon-config luci-i18n-argon-config-zh-cn hysteria rtp2httpd dns2tcp ipt2socks lua-neturl shadowsocksr-libev-ssr-local shadowsocksr-libev-ssr-redir luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn bandix luci-app-bandix luci-i18n-bandix-zh-cn luci-app-passwall luci-i18n-passwall-zh-cn luci-app-passwall2 luci-i18n-passwall2-zh-cn chinadns-ng dns2socks tcping geoview luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn clashoo luci-app-clashoo luci-i18n-clashoo-zh-cn luci-app-lucky lucky luci-i18n-lucky-zh-cn luci-app-rtp2httpd luci-i18n-rtp2httpd-zh-cn luci-app-partexp luci-i18n-partexp-zh-cn"

export CUSTOM_PACKAGES
