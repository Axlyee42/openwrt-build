# OpenWrt x86-64 ImageBuilder

This project is a simplified OpenWrt adaptation of
wukongdaily/ImmortalWrt-ImageBuilder.

It intentionally keeps only x86-64 and uses the official OpenWrt
ImageBuilder rather than compiling the complete OpenWrt source tree.

## GitHub Actions inputs

- OpenWrt version (default: 25.12.5)
- LAN IP
- 1G / 2G / 3G / 4G image size
- UEFI
- Filesystem: ext4 / squashfs
- QCOW2

## Third-party packages

`script/apk-custom-packages.sh` downloads prebuilt x86 APKs and adds the
selected package names to the ImageBuilder package list. It does not compile
third-party source code.

## Important

The current default is OpenWrt 25.12.1. OpenWrt publishes an official
x86/64 ImageBuilder for this release.

The third-party APK repository must contain packages compatible with the
selected OpenWrt/APK ABI. If a package is unavailable, the build stops and
prints the available APK list.


## Current default

OpenWrt 25.12.5 is the current stable 25.12 release. The x86/64 target
provides an official ImageBuilder.

The workflow no longer exposes BIOS, RAW, or VMDK switches. The intended
outputs are UEFI images, with ext4 or squashfs filesystem selection, plus
optional QCOW2 conversion.
