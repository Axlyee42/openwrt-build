#!/bin/sh

# Third-party APK/package selection list.
# Uncomment a line to include that package group in the image.
# Keep this file focused on third-party/custom packages.

CUSTOM_PACKAGES=""

# OpenClash
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash"

# PassWall / PassWall2 and common proxy cores
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-passwall2 luci-i18n-passwall2-zh-cn xray-core sing-box hysteria naiveproxy kmod-nft-tproxy kmod-nft-socket"

# Aurora
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn"

# Bandix
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES bandix luci-app-bandix luci-i18n-bandix-zh-cn"

# Run
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-run"

# Filebrowser
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-filebrowser-go luci-i18n-filebrowser-go-zh-cn"

# ttyd
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-ttyd luci-i18n-ttyd-zh-cn"

# vlmcsd
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn"

# UPnP
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-upnp luci-i18n-upnp-zh-cn"

# Timewol
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-timewol luci-i18n-timewol-zh-cn"

# Autoreboot
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-autoreboot luci-i18n-autoreboot-zh-cn"

export CUSTOM_PACKAGES
printf '%s\n' "$CUSTOM_PACKAGES"
