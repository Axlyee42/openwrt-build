#!/usr/bin/env bash

# Third-party APKs supplied by the current x86 wukongdaily APK repository.
# Only packages actually present in that repository belong here.
CUSTOM_PACKAGES="luci-app-run luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn bandix luci-app-bandix luci-i18n-bandix-zh-cn luci-app-passwall luci-i18n-passwall-zh-cn chinadns-ng dns2socks tcping geoview xray-core sing-box hysteria"

# Packages supplied by the OpenWrt/ImmortalWrt package feeds.
# These must NOT be looked up in wukongdaily/apk.
OFFICIAL_PACKAGES="luci-compat kmod-tun kmod-inet-diag kmod-nft-tproxy bash curl ip-full unzip luci-i18n-timewol-zh-cn luci-i18n-autoreboot-zh-cn luci-i18n-ttyd-zh-cn luci-i18n-vlmcsd-zh-cn luci-i18n-upnp-zh-cn"

PACKAGES="$CUSTOM_PACKAGES $OFFICIAL_PACKAGES luci-app-openclash"

export CUSTOM_PACKAGES OFFICIAL_PACKAGES PACKAGES

# Persist the complete package list for later GitHub Actions steps.
if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "PACKAGES=$PACKAGES" >> "$GITHUB_ENV"
fi

# OpenWrt 25.12 ImageBuilder uses APK indexes for local packages. The
# workflow copies custom APKs into $IMAGEBUILDER_DIR/packages during the
# preparation step, and sources this file again immediately before make
# image. Rebuild packages.adb at that point so dependencies such as
# chinadns-ng, dns2socks and tcping are visible to the APK resolver.
if [[ -n "${IMAGEBUILDER_DIR:-}" && -x "$IMAGEBUILDER_DIR/staging_dir/host/bin/apk" ]]; then
  if compgen -G "$IMAGEBUILDER_DIR/packages/*.apk" >/dev/null 2>&1; then
    (
      cd "$IMAGEBUILDER_DIR/packages"
      "$IMAGEBUILDER_DIR/staging_dir/host/bin/apk" mkndx \
        --root "$IMAGEBUILDER_DIR" \
        --keys-dir "$IMAGEBUILDER_DIR" \
        --allow-untrusted \
        --output packages.adb \
        *.apk
    )
    test -s "$IMAGEBUILDER_DIR/packages/packages.adb"
    echo "[APK] rebuilt ImageBuilder packages.adb"
  fi
fi
