# OpenWrt-ImageBuilder

基于 CI 的 ImageBuilder 工作流，用于自动化构建 **OpenWrt 官方 x86-64 固件**。

本项目的目录组织、第三方 APK 集成方式、首次启动网络初始化方式参考并保留 wukongdaily/ImmortalWrt-ImageBuilder 的 x86-64 方案；基础系统改为 OpenWrt 官方 ImageBuilder，当前固定版本为 **25.12.5**。

## 基本用法

1. 进入 GitHub Actions。
2. 运行 `Build 25.12.x x86-64`。
3. 选择固件空间大小、管理地址、Docker、Store 和 PPPoE。
4. 第三方 APK 在 `shell/apk-custom-packages.sh` 中按需取消注释。

## x86-64 网络逻辑

- 单网口：LAN 默认 DHCP，自动从上级网络获取地址。
- 多网口：第一个物理网口作为 WAN，其余物理网口加入 `br-lan`。
- WAN 默认 DHCP；可在工作流中启用 PPPoE。
- 多网口 LAN 默认管理地址为 `192.168.100.1`，可通过工作流参数修改。
- 首次启动由 `files/etc/uci-defaults/99-custom.sh` 完成网络初始化。

## 第三方 APK

构建脚本按需同步 `wukongdaily/apk` 的 `run/x86` 内容，并使用 `shell/apk-prepare-packages.sh` 整理 APK 后交给官方 ImageBuilder。

## 固件

当前构建目标仅为 OpenWrt 官方 x86-64，使用 UEFI EFI 镜像。
