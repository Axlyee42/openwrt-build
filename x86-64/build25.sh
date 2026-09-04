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

mkdir -p "$FILES_DIR/etc/apk/keys" "$FILES_DIR/etc/apk/repositories.d" "$PACKAGES_DIR" "$EXTRA_DIR" "$KEY_DIR"

APK_BIN="${APK_BIN:-$IMAGEBUILDER_DIR/staging_dir/host/bin/apk}"
OPENSSL_BIN="${OPENSSL_BIN:-$IMAGEBUILDER_DIR/staging_dir/host/bin/openssl}"

if [ ! -x "$APK_BIN" ]; then
    APK_BIN="$(find "$IMAGEBUILDER_DIR" -type f -path '*/staging_dir/host/bin/apk' -perm -111 -print -quit 2>/dev/null || true)"
fi
if [ ! -x "$OPENSSL_BIN" ]; then
    OPENSSL_BIN="$(find "$IMAGEBUILDER_DIR" -type f -path '*/staging_dir/host/bin/openssl' -perm -111 -print -quit 2>/dev/null || true)"
fi

if [ ! -x "$APK_BIN" ]; then
    echo "ERROR: official ImageBuilder apk binary not found."
    exit 1
fi
if [ ! -x "$OPENSSL_BIN" ]; then
    OPENSSL_BIN="$(command -v openssl || true)"
fi
if [ -z "$OPENSSL_BIN" ] || [ ! -x "$OPENSSL_BIN" ]; then
    echo "ERROR: openssl not found."
    exit 1
fi
if [ ! -f "$IMAGEBUILDER_DIR/Makefile" ]; then
    echo "ERROR: official OpenWrt ImageBuilder Makefile not found."
    exit 1
fi

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

    # The wukongdaily repository contains independent proxy stacks that
    # conflict with each other. Neither clashoo nor nikki is requested here.
    find "$PACKAGES_DIR" -maxdepth 1 -type f \( \
        -name 'clashoo-*.apk' -o -name 'luci-app-clashoo-*.apk' -o -name 'luci-i18n-clashoo-*.apk' -o \
        -name 'nikki-*.apk' -o -name 'luci-app-nikki-*.apk' -o -name 'luci-i18n-nikki-*.apk' \
    \) -print -delete
fi

# OpenClash is not part of the official OpenWrt feeds. Its current APK is
# published directly by the upstream project, so fetch it into the local
# package directory and sign it together with the other third-party APKs.
if printf '%s\n' "$CUSTOM_PACKAGES" | grep -qw 'luci-app-openclash'; then
    OPENCLASH_API="https://api.github.com/repos/vernesong/OpenClash/releases/latest"
    OPENCLASH_URL="$(curl -fsSL "$OPENCLASH_API" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next((a["browser_download_url"] for a in d.get("assets",[]) if a.get("name","").endswith(".apk") and a.get("name","").startswith("luci-app-openclash-")), "") )')"
    if [ -z "$OPENCLASH_URL" ]; then
        echo "ERROR: could not find the latest OpenClash APK release asset."
        exit 1
    fi
    OPENCLASH_FILE="$PACKAGES_DIR/$(basename "$OPENCLASH_URL")"
    curl -fL "$OPENCLASH_URL" -o "$OPENCLASH_FILE"
    test -s "$OPENCLASH_FILE"
    echo "OpenClash APK: $(basename "$OPENCLASH_FILE")"
fi

# These four requested LuCI applications are not shipped by the official
# OpenWrt 25.12.5 x86_64 feed. ImmortalWrt publishes matching 25.12 x86_64
# APKv3 builds, so fetch only these requested packages and re-sign them with
# our local EC key. Their dependencies are still resolved against OpenWrt.
IMMORTAL_LUCI_BASE="https://downloads.immortalwrt.org/releases/packages-25.12/x86_64/luci"
for wanted in \
    luci-app-autoreboot \
    luci-i18n-autoreboot-zh-cn \
    luci-app-filebrowser-go \
    luci-i18n-filebrowser-go-zh-cn \
    luci-app-timewol \
    luci-i18n-timewol-zh-cn \
    luci-app-vlmcsd \
    luci-i18n-vlmcsd-zh-cn
 do
    if printf '%s\n' "$CUSTOM_PACKAGES" | grep -qw "$wanted"; then
        index_html="$(curl -fsSL "$IMMORTAL_LUCI_BASE/")"
        filename="$(printf '%s\n' "$index_html" | grep -oE 'href="[^"]+\.apk"' | sed 's/^href="//; s/"$//' | grep -E "^${wanted}-.*\\.apk$" | tail -n1 || true)"
        if [ -z "$filename" ]; then
            echo "ERROR: requested package not found in ImmortalWrt 25.12 x86_64 feed: $wanted"
            exit 1
        fi
        curl -fL "$IMMORTAL_LUCI_BASE/$filename" -o "$PACKAGES_DIR/$filename"
        test -s "$PACKAGES_DIR/$filename"
        echo "Compatibility LuCI APK: $filename"
    fi
done

APK_COUNT="$(find "$PACKAGES_DIR" -maxdepth 1 -type f -name '*.apk' | wc -l)"
echo "Third-party APK files: $APK_COUNT"
if [ "$APK_COUNT" -eq 0 ] && [ -n "${CUSTOM_PACKAGES:-}" ]; then
    echo "ERROR: third-party package list is not empty, but no APK was found."
    exit 1
fi

if [ "$APK_COUNT" -gt 0 ]; then
    while IFS= read -r -d '' apk_file; do
        "$APK_BIN" adbsign --allow-untrusted --sign-key "$LOCAL_PRIVATE_KEY" "$apk_file"
    done < <(find "$PACKAGES_DIR" -maxdepth 1 -type f -name '*.apk' -print0)

    rm -f "$PACKAGES_DIR/packages.adb"
    (
        cd "$PACKAGES_DIR"
        "$APK_BIN" mkndx --allow-untrusted --sign-key "$LOCAL_PRIVATE_KEY" --output packages.adb ./*.apk
    )
    test -s "$PACKAGES_DIR/packages.adb"
    "$APK_BIN" verify --keys-dir "$KEY_DIR" "$PACKAGES_DIR/packages.adb"

    # OpenWrt 25.12.x ImageBuilder has a regression with local APK entries:
    # the signed packages.adb is valid, but apk may fail to resolve a local
    # package by name with "package mentioned in index not found". Install
    # actual local APK files directly while keeping the signed index for
    # repository metadata and dependency resolution.
    LOCAL_APK_NAMES=""
    for pkg in $CUSTOM_PACKAGES; do
        if find "$PACKAGES_DIR" -maxdepth 1 -type f -name "${pkg}-*.apk" -print -quit | grep -q .; then
            LOCAL_APK_NAMES="$LOCAL_APK_NAMES $pkg"
        fi
    done
    LOCAL_APK_NAMES="$(printf '%s\n' "$LOCAL_APK_NAMES" | xargs)"
    if [ -z "$LOCAL_APK_NAMES" ]; then
        echo "ERROR: no CUSTOM_PACKAGES entry maps to a local APK."
        echo "Available local APKs:"
        find "$PACKAGES_DIR" -maxdepth 1 -type f -name '*.apk' -printf '%f\n' | sort
        exit 1
    fi
    echo "Local APK packages: $LOCAL_APK_NAMES"

    export OPENWRT_BUILD_LOCAL_APK_WORKAROUND=1
    python3 - "$IMAGEBUILDER_DIR/Makefile" "$LOCAL_APK_NAMES" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
local_names = sys.argv[2].split()
text = path.read_text()
needle = "\t$(APK) add --arch $(ARCH_PACKAGES) --no-scripts $(BUILD_PACKAGES)"
if needle not in text:
    raise SystemExit("ERROR: ImageBuilder package_install command not found")
if "OPENWRT_BUILD_LOCAL_APK_WORKAROUND" in text:
    raise SystemExit(0)
filtered = "$(filter-out " + " ".join(local_names) + ",$(BUILD_PACKAGES))"
replacement = (
    "\t# OPENWRT_BUILD_LOCAL_APK_WORKAROUND\n"
    "\t$(APK) add --arch $(ARCH_PACKAGES) --no-scripts " + filtered + " $(wildcard $(PACKAGE_DIR)/*.apk)"
)
path.write_text(text.replace(needle, replacement, 1))
PY
fi

PACKAGES=""
PACKAGES="$PACKAGES luci luci-ssl luci-base uhttpd uhttpd-mod-ubus"
PACKAGES="$PACKAGES luci-theme-bootstrap luci-i18n-base-zh-cn"
PACKAGES="$PACKAGES luci-app-package-manager luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-app-mwan3 luci-i18n-mwan3-zh-cn"
PACKAGES="$PACKAGES luci-app-upnp luci-i18n-upnp-zh-cn"
PACKAGES="$PACKAGES luci-app-ttyd luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES luci-app-filemanager luci-i18n-filemanager-zh-cn"
PACKAGES="$PACKAGES ppp ppp-mod-pppoe kmod-pppoe luci-proto-ppp"
PACKAGES="$PACKAGES luci-proto-ipv6 odhcp6c odhcpd-ipv6only"
PACKAGES="$PACKAGES luci-compat kmod-tun kmod-inet-diag kmod-nft-socket kmod-nft-tproxy"
PACKAGES="$PACKAGES bash curl ca-bundle ip-full unzip openssh-sftp-server"
PACKAGES="$PACKAGES ${CUSTOM_PACKAGES:-}"
PACKAGES="$(printf '%s\n' $PACKAGES | awk '!seen[$0]++' | tr '\n' ' ' | xargs)"

if printf '%s\n' "$PACKAGES" | grep -qw 'luci-app-openclash'; then
    mkdir -p "$FILES_DIR/etc/openclash/core"
    META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz"
    if curl -fL "$META_URL" -o /tmp/clash-meta.tar.gz; then
        tar -xzf /tmp/clash-meta.tar.gz -C /tmp
        META_BIN="$(find /tmp -maxdepth 2 -type f -name clash_meta -print -quit 2>/dev/null || true)"
        [ -z "$META_BIN" ] || install -m 0755 "$META_BIN" "$FILES_DIR/etc/openclash/core/clash_meta"
    else
        echo "WARNING: OpenClash core download failed."
    fi
    curl -fL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -o "$FILES_DIR/etc/openclash/GeoIP.dat" || true
    curl -fL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o "$FILES_DIR/etc/openclash/GeoSite.dat" || true
fi

LAN_IP="${LAN_IP:-192.168.1.2}"
mkdir -p "$FILES_DIR/etc/uci-defaults"
cat > "$FILES_DIR/etc/uci-defaults/99-custom-build" <<EOF
#!/bin/sh
uci -q set luci.main.lang='zh_cn'
uci -q commit luci
uci -q set network.lan.ipaddr='${LAN_IP}'
uci -q commit network
exit 0
EOF
chmod 0755 "$FILES_DIR/etc/uci-defaults/99-custom-build"

make image \
    PROFILE="generic" \
    PACKAGES="$PACKAGES" \
    FILES="$FILES_DIR" \
    ROOTFS_PARTSIZE="${PROFILE:-4096}" \
    ADD_LOCAL_KEY=1 \
    CONFIG_SIGNATURE_CHECK=1 \
    V=s

echo "$(date '+%Y-%m-%d %H:%M:%S') - ImageBuilder build completed successfully."
