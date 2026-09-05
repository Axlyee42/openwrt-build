#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IMAGEBUILDER_DIR="${IMAGEBUILDER_DIR:-$(pwd)}"
FILES_DIR="$IMAGEBUILDER_DIR/files"
PACKAGES_DIR="$IMAGEBUILDER_DIR/packages"
EXTRA_DIR="$IMAGEBUILDER_DIR/extra-packages"
KEY_DIR="$IMAGEBUILDER_DIR/keys"

source "$REPO_ROOT/shell/apk-custom-packages.sh"
ENABLE_HOMEPROXY="${ENABLE_HOMEPROXY:-false}"
ENABLE_MWAN3="${ENABLE_MWAN3:-false}"
if [ "$ENABLE_HOMEPROXY" = "true" ] || [ "$ENABLE_HOMEPROXY" = "yes" ]; then
    CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-homeproxy luci-i18n-homeproxy-zh-cn"
fi
export CUSTOM_PACKAGES

mkdir -p "$FILES_DIR/etc/apk/keys" "$FILES_DIR/etc/apk/repositories.d" "$FILES_DIR/etc/config" "$PACKAGES_DIR" "$EXTRA_DIR" "$KEY_DIR"

LAN_IP="${LAN_IP:-192.168.100.1}"
ENABLE_PPPOE="${ENABLE_PPPOE:-no}"
PPPOE_ACCOUNT="${PPPOE_ACCOUNT:-}"
PPPOE_PASSWORD="${PPPOE_PASSWORD:-}"
printf '%s\n' "$LAN_IP" > "$FILES_DIR/etc/config/custom_router_ip.txt"
{
    printf 'enable_pppoe=%q\n' "$ENABLE_PPPOE"
    printf 'pppoe_account=%q\n' "$PPPOE_ACCOUNT"
    printf 'pppoe_password=%q\n' "$PPPOE_PASSWORD"
} > "$FILES_DIR/etc/config/pppoe-settings"
chmod 0600 "$FILES_DIR/etc/config/pppoe-settings"

echo "Network settings prepared: LAN=$LAN_IP PPPoE=$ENABLE_PPPOE"
echo "HomeProxy enabled: $ENABLE_HOMEPROXY"
echo "MWAN3 enabled: $ENABLE_MWAN3"

echo "Required defaults: geoview xray-core sing-box hysteria luci-compat kmod-tun kmod-inet-diag kmod-nft-tproxy bash curl ip-full unzip luci-i18n-upnp-zh-cn"

APK_BIN="${APK_BIN:-$IMAGEBUILDER_DIR/staging_dir/host/bin/apk}"
OPENSSL_BIN="${OPENSSL_BIN:-$IMAGEBUILDER_DIR/staging_dir/host/bin/openssl}"
[ -x "$APK_BIN" ] || APK_BIN="$(find "$IMAGEBUILDER_DIR" -type f -path '*/staging_dir/host/bin/apk' -perm -111 -print -quit 2>/dev/null || true)"
[ -x "$OPENSSL_BIN" ] || OPENSSL_BIN="$(find "$IMAGEBUILDER_DIR" -type f -path '*/staging_dir/host/bin/openssl' -perm -111 -print -quit 2>/dev/null || true)"
[ -x "$APK_BIN" ] || { echo "ERROR: official ImageBuilder apk binary not found."; exit 1; }
[ -x "$OPENSSL_BIN" ] || OPENSSL_BIN="$(command -v openssl || true)"
[ -x "$OPENSSL_BIN" ] || { echo "ERROR: openssl not found."; exit 1; }
[ -f "$IMAGEBUILDER_DIR/Makefile" ] || { echo "ERROR: official OpenWrt ImageBuilder Makefile not found."; exit 1; }

LOCAL_PRIVATE_KEY="$KEY_DIR/local-private-key.pem"
LOCAL_PUBLIC_KEY="$KEY_DIR/local-public-key.pem"
if [ ! -s "$LOCAL_PRIVATE_KEY" ]; then
    umask 077
    "$OPENSSL_BIN" ecparam -name prime256v1 -genkey -noout -out "$LOCAL_PRIVATE_KEY"
    umask 022
fi
if [ ! -s "$LOCAL_PUBLIC_KEY" ]; then
    "$OPENSSL_BIN" ec -in "$LOCAL_PRIVATE_KEY" -pubout -out "$LOCAL_PUBLIC_KEY"
fi
install -m 0644 "$LOCAL_PUBLIC_KEY" "$FILES_DIR/etc/apk/keys/local-public-key.pem"

rm -rf /tmp/wukongdaily-apk
if [ -n "${CUSTOM_PACKAGES:-}" ]; then
    git clone --depth=1 https://github.com/wukongdaily/apk.git /tmp/wukongdaily-apk
    test -d /tmp/wukongdaily-apk/run/x86
    rm -rf "$EXTRA_DIR" "$PACKAGES_DIR"
    mkdir -p "$EXTRA_DIR" "$PACKAGES_DIR"
    cp -a /tmp/wukongdaily-apk/run/x86/. "$EXTRA_DIR/"
    for run_file in "$EXTRA_DIR"/*.run; do
        [ -f "$run_file" ] || continue
        chmod +x "$run_file"
        tmp_run_dir="$(mktemp -d)"
        if ! sh "$run_file" --target "$tmp_run_dir" --noexec; then
            rm -rf "$tmp_run_dir"
            echo "ERROR: failed to extract $(basename "$run_file")"
            exit 1
        fi
        find "$tmp_run_dir" -type f -name '*.apk' -exec cp -f {} "$PACKAGES_DIR/" \;
        rm -rf "$tmp_run_dir"
    done
    find "$EXTRA_DIR" -type f -name '*.apk' -exec cp -f {} "$PACKAGES_DIR/" \;
    rm -f "$PACKAGES_DIR"/clashoo-*.apk "$PACKAGES_DIR"/luci-app-clashoo-*.apk "$PACKAGES_DIR"/luci-i18n-clashoo-*.apk \
          "$PACKAGES_DIR"/nikki-*.apk "$PACKAGES_DIR"/luci-app-nikki-*.apk "$PACKAGES_DIR"/luci-i18n-nikki-*.apk
    if find "$PACKAGES_DIR" -maxdepth 1 -type f \( -name 'clashoo-*.apk' -o -name 'luci-app-clashoo-*.apk' -o -name 'luci-i18n-clashoo-*.apk' -o -name 'nikki-*.apk' -o -name 'luci-app-nikki-*.apk' -o -name 'luci-i18n-nikki-*.apk' \) -print -quit | grep -q .; then
        echo "ERROR: conflicting clashoo/nikki APKs were not removed."
        exit 1
    fi
fi

# Optional OpenClash remains opt-in if it is ever added to CUSTOM_PACKAGES.
if printf '%s\n' "$CUSTOM_PACKAGES" | grep -qw 'luci-app-openclash'; then
    OPENCLASH_API="https://api.github.com/repos/vernesong/OpenClash/releases/latest"
    OPENCLASH_URL="$(curl -fsSL "$OPENCLASH_API" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next((a["browser_download_url"] for a in d.get("assets",[]) if a.get("name","").endswith(".apk") and a.get("name","").startswith("luci-app-openclash-")), ""))')"
    [ -n "$OPENCLASH_URL" ] || { echo "ERROR: could not find latest OpenClash APK."; exit 1; }
    curl -fL "$OPENCLASH_URL" -o "$PACKAGES_DIR/$(basename "$OPENCLASH_URL")"
fi

# HomeProxy is optional; sing-box is NOT optional and always follows the latest stable release.
if printf '%s\n' "$CUSTOM_PACKAGES" | grep -qw 'luci-app-homeproxy'; then
    HOMEProxy_JSON="$(curl -fsSL 'https://api.github.com/repos/szwjp/homeproxy/releases/tags/luci-app-homeproxy')"
    HOMEProxy_URL="$(printf '%s' "$HOMEProxy_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next((a["browser_download_url"] for a in d.get("assets",[]) if a.get("name","").startswith("luci-app-homeproxy-") and a.get("name","").endswith(".apk")), ""))')"
    HOMEProxy_I18N_URL="$(printf '%s' "$HOMEProxy_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next((a["browser_download_url"] for a in d.get("assets",[]) if a.get("name","").startswith("luci-i18n-homeproxy-zh-cn-") and a.get("name","").endswith(".apk")), ""))')"
    [ -n "$HOMEProxy_URL" ] && [ -n "$HOMEProxy_I18N_URL" ] || { echo "ERROR: could not find szwjp/homeproxy APK assets."; exit 1; }
    curl -fL "$HOMEProxy_URL" -o "$PACKAGES_DIR/$(basename "$HOMEProxy_URL")"
    curl -fL "$HOMEProxy_I18N_URL" -o "$PACKAGES_DIR/$(basename "$HOMEProxy_I18N_URL")"
fi

# Always pull the newest stable SagerNet sing-box and package it locally.
SINGBOX_JSON="$(curl -fsSL 'https://api.github.com/repos/SagerNet/sing-box/releases/latest')"
SINGBOX_VERSION="$(printf '%s' "$SINGBOX_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tag_name", "").lstrip("v"))')"
[ -n "$SINGBOX_VERSION" ] || { echo "ERROR: could not determine latest stable sing-box version."; exit 1; }
SINGBOX_URL="$(printf '%s' "$SINGBOX_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); v=d.get("tag_name", "").lstrip("v"); print(next((a["browser_download_url"] for a in d.get("assets",[]) if a.get("name") == f"sing-box-{v}-linux-amd64.tar.gz"), ""))')"
[ -n "$SINGBOX_URL" ] || { echo "ERROR: latest sing-box release has no linux-amd64 archive."; exit 1; }
SINGBOX_TARBALL="/tmp/sing-box-${SINGBOX_VERSION}-linux-amd64.tar.gz"
curl -fL "$SINGBOX_URL" -o "$SINGBOX_TARBALL"
SINGBOX_TMP="$(mktemp -d)"
tar -xzf "$SINGBOX_TARBALL" -C "$SINGBOX_TMP"
SINGBOX_BIN="$(find "$SINGBOX_TMP" -type f -name sing-box -print -quit)"
[ -n "$SINGBOX_BIN" ] || { echo "ERROR: latest sing-box binary not found."; exit 1; }
chmod 0755 "$SINGBOX_BIN"
"$SINGBOX_BIN" version
SINGBOX_PKG_DIR="$(mktemp -d)"
mkdir -p "$SINGBOX_PKG_DIR/usr/bin"
install -m 0755 "$SINGBOX_BIN" "$SINGBOX_PKG_DIR/usr/bin/sing-box"
"$APK_BIN" mkpkg \
    --info "name:sing-box" \
    --info "version:${SINGBOX_VERSION}-r1" \
    --info "description:sing-box ${SINGBOX_VERSION} runtime" \
    --info "arch:x86_64" \
    --files "$SINGBOX_PKG_DIR" \
    --output "$PACKAGES_DIR/sing-box-${SINGBOX_VERSION}-r1.apk"
rm -rf "$SINGBOX_TMP" "$SINGBOX_PKG_DIR"

after_packages() {
    local base="$1"; shift
    local wanted index_html filename
    for wanted in "$@"; do
        index_html="$(curl -fsSL "$base/")"
        filename="$(printf '%s\n' "$index_html" | grep -oE 'href="[^"]+\.apk"' | sed 's/^href="//; s/"$//' | grep -E "^${wanted}-.*\.apk$" | tail -n1 || true)"
        [ -n "$filename" ] || { echo "ERROR: requested package not found: $wanted"; exit 1; }
        curl -fL "$base/$filename" -o "$PACKAGES_DIR/$filename"
        test -s "$PACKAGES_DIR/$filename"
        echo "Compatibility APK: $filename"
    done
}

IMMORTAL_LUCI_BASE="https://downloads.immortalwrt.org/releases/packages-25.12/x86_64/luci"
for wanted in luci-app-autoreboot luci-i18n-autoreboot-zh-cn luci-app-filebrowser-go luci-i18n-filebrowser-go-zh-cn luci-app-timewol luci-i18n-timewol-zh-cn luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn luci-app-ddns-go; do
    if printf '%s\n' "$CUSTOM_PACKAGES" | grep -qw "$wanted"; then after_packages "$IMMORTAL_LUCI_BASE" "$wanted"; fi
done

IMMORTAL_PACKAGES_BASE="https://downloads.immortalwrt.org/releases/packages-25.12/x86_64/packages"
for wanted in filebrowser vlmcsd ddns-go; do
    if [ "$wanted" = "filebrowser" ] && ! printf '%s\n' "$CUSTOM_PACKAGES" | grep -qw 'luci-app-filebrowser-go'; then continue; fi
    if [ "$wanted" = "vlmcsd" ] && ! printf '%s\n' "$CUSTOM_PACKAGES" | grep -qw 'luci-app-vlmcsd'; then continue; fi
    if [ "$wanted" = "ddns-go" ] && ! printf '%s\n' "$CUSTOM_PACKAGES" | grep -qw 'luci-app-ddns-go'; then continue; fi
    after_packages "$IMMORTAL_PACKAGES_BASE" "$wanted"
done

# Hard requirements: fail early if a requested runtime APK is missing.
for required_pkg in geoview xray-core sing-box hysteria; do
    find "$PACKAGES_DIR" -maxdepth 1 -type f -name "${required_pkg}-*.apk" -print -quit | grep -q . || {
        echo "ERROR: required default APK is missing: $required_pkg"; exit 1;
    }
done

APK_COUNT="$(find "$PACKAGES_DIR" -maxdepth 1 -type f -name '*.apk' | wc -l)"
echo "Third-party APK files: $APK_COUNT"
[ "$APK_COUNT" -gt 0 ] || { echo "ERROR: no third-party APK was produced."; exit 1; }

while IFS= read -r -d '' apk_file; do
    "$APK_BIN" adbsign --allow-untrusted --sign-key "$LOCAL_PRIVATE_KEY" "$apk_file"
done < <(find "$PACKAGES_DIR" -maxdepth 1 -type f -name '*.apk' -print0)
rm -f "$PACKAGES_DIR/packages.adb"
( cd "$PACKAGES_DIR" && "$APK_BIN" mkndx --allow-untrusted --sign-key "$LOCAL_PRIVATE_KEY" --output packages.adb ./*.apk )
test -s "$PACKAGES_DIR/packages.adb"
"$APK_BIN" verify --keys-dir "$KEY_DIR" "$PACKAGES_DIR/packages.adb"

LOCAL_APK_NAMES=""
for pkg in $CUSTOM_PACKAGES; do
    if find "$PACKAGES_DIR" -maxdepth 1 -type f -name "${pkg}-*.apk" -print -quit | grep -q .; then LOCAL_APK_NAMES="$LOCAL_APK_NAMES $pkg"; fi
done
if find "$PACKAGES_DIR" -maxdepth 1 -type f -name 'sing-box-*.apk' -print -quit | grep -q .; then LOCAL_APK_NAMES="$LOCAL_APK_NAMES sing-box"; fi
if find "$PACKAGES_DIR" -maxdepth 1 -type f -name 'ddns-go-*.apk' -print -quit | grep -q .; then LOCAL_APK_NAMES="$LOCAL_APK_NAMES ddns-go"; fi
LOCAL_APK_NAMES="$(printf '%s\n' "$LOCAL_APK_NAMES" | xargs)"
[ -n "$LOCAL_APK_NAMES" ] || { echo "ERROR: no local APK package maps to the requested package list."; exit 1; }
echo "Local APK packages: $LOCAL_APK_NAMES"

python3 - "$IMAGEBUILDER_DIR/Makefile" "$LOCAL_APK_NAMES" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
local_names = sys.argv[2].split()
text = path.read_text()
needle = "\t$(APK) add --arch $(ARCH_PACKAGES) --no-scripts $(BUILD_PACKAGES)"
if needle not in text:
    raise SystemExit("ERROR: ImageBuilder package_install command not found")
if "OPENWRT_BUILD_LOCAL_APK_WORKAROUND" not in text:
    filtered = "$(filter-out " + " ".join(local_names) + ",$(BUILD_PACKAGES))"
    local_apks = "$(foreach p," + " ".join(local_names) + ",$(wildcard $(PACKAGE_DIR)/$(p)-*.apk))"
    replacement = "\t# OPENWRT_BUILD_LOCAL_APK_WORKAROUND\n\t$(APK) add --arch $(ARCH_PACKAGES) --no-scripts " + filtered + " " + local_apks
    path.write_text(text.replace(needle, replacement, 1))
PY

PACKAGES=""
PACKAGES="$PACKAGES luci luci-ssl luci-base uhttpd uhttpd-mod-ubus"
PACKAGES="$PACKAGES luci-theme-bootstrap luci-i18n-base-zh-cn"
PACKAGES="$PACKAGES luci-app-package-manager luci-i18n-package-manager-zh-cn"
if [ "$ENABLE_MWAN3" = "true" ] || [ "$ENABLE_MWAN3" = "yes" ]; then
    PACKAGES="$PACKAGES luci-app-mwan3 luci-i18n-mwan3-zh-cn"
fi
PACKAGES="$PACKAGES luci-app-upnp luci-i18n-upnp-zh-cn"
PACKAGES="$PACKAGES luci-app-ttyd luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES luci-app-filemanager luci-i18n-filemanager-zh-cn"
PACKAGES="$PACKAGES ppp ppp-mod-pppoe kmod-pppoe luci-proto-ppp"
PACKAGES="$PACKAGES luci-proto-ipv6 odhcp6c odhcpd-ipv6only"
PACKAGES="$PACKAGES luci-compat kmod-tun kmod-inet-diag kmod-nft-socket kmod-nft-tproxy"
PACKAGES="$PACKAGES ethtool"
PACKAGES="$PACKAGES bash curl ca-bundle ip-full unzip openssh-sftp-server"
PACKAGES="$PACKAGES ${CUSTOM_PACKAGES:-}"
if printf '%s\n' "$CUSTOM_PACKAGES" | grep -qw 'luci-app-homeproxy'; then PACKAGES="$PACKAGES firewall4 ucode-mod-digest kmod-nft-tproxy"; fi
PACKAGES="$(printf '%s\n' $PACKAGES | awk '!seen[$0]++' | tr '\n' ' ' | xargs)"

# Explicit hard assertions for the packages that must never disappear from the default build.
for required in geoview xray-core sing-box hysteria luci-compat kmod-tun kmod-inet-diag kmod-nft-tproxy bash curl ip-full unzip luci-i18n-upnp-zh-cn; do
    printf '%s\n' "$PACKAGES" | grep -qw "$required" || { echo "ERROR: required default package missing from PACKAGES: $required"; exit 1; }
done

if printf '%s\n' "$PACKAGES" | grep -qw 'luci-app-openclash'; then
    mkdir -p "$FILES_DIR/etc/openclash/core"
    META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz"
    if curl -fL "$META_URL" -o /tmp/clash-meta.tar.gz; then
        tar -xzf /tmp/clash-meta.tar.gz -C /tmp
        META_BIN="$(find /tmp -maxdepth 2 -type f -name clash_meta -print -quit 2>/dev/null || true)"
        [ -z "$META_BIN" ] || install -m 0755 "$META_BIN" "$FILES_DIR/etc/openclash/core/clash_meta"
    else echo "WARNING: OpenClash core download failed."; fi
    curl -fL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -o "$FILES_DIR/etc/openclash/GeoIP.dat" || true
    curl -fL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o "$FILES_DIR/etc/openclash/GeoSite.dat" || true
fi

mkdir -p "$FILES_DIR/etc/uci-defaults"
cat > "$FILES_DIR/etc/uci-defaults/99-custom-build" <<EOF
#!/bin/sh
uci -q set luci.main.lang='zh_cn'
uci -q commit luci
exit 0
EOF
chmod 0755 "$FILES_DIR/etc/uci-defaults/99-custom-build"

make image PROFILE="generic" PACKAGES="$PACKAGES" FILES="$FILES_DIR" ROOTFS_PARTSIZE="${PROFILE:-4096}" ADD_LOCAL_KEY=1 CONFIG_SIGNATURE_CHECK=1 V=s

echo "$(date '+%Y-%m-%d %H:%M:%S') - ImageBuilder build completed successfully."
