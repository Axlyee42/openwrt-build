# OpenWrt x86-64 ImageBuilder

这是一个基于官方 OpenWrt ImageBuilder 的 x86-64 镜像构建项目，参考并简化了 `wukongdaily/ImmortalWrt-ImageBuilder` 的实现方式。

本项目只针对 **x86-64**，使用官方 ImageBuilder 制作镜像，不编译完整的 OpenWrt 源代码树。

## 构建功能

GitHub Actions 支持以下参数：

- OpenWrt 版本（默认：`25.12.5`，也支持自动检测最新稳定版）
- LAN IP（默认：`192.168.1.2`）
- RootFS 容量：`1G / 2G / 3G / 4G`
- 文件系统：`ext4 / squashfs`
- UEFI 镜像
- 可选 QCOW2 镜像
- GitHub Release 自动发布

## 网络接口规划

本项目的默认网络接口固定为：

| 网口 | 用途 | 协议 |
|---|---|---|
| `eth0` | WAN | PPPoE |
| `eth1` | WANB | PPPoE |
| `eth2` | LAN | 加入 LAN Bridge |
| `eth3` | LAN | 加入 LAN Bridge |
| `eth4` | LAN | 加入 LAN Bridge |
| `eth5` | LAN | 加入 LAN Bridge |

因此适用于具有 **6 个物理 2.5G 网口**的 x86-64 小主机：两个网口作为双 WAN，其余四个网口作为 LAN。

WAN 和 WANB 的 PPPoE 用户名、密码通过 GitHub Actions Repository Secrets 提供，不应写入仓库文件。

## 第三方 APK

第三方 APK 使用预编译的 x86 APK，不在本项目中重新编译第三方源码。

构建时会检查 APK 是否存在并将需要的软件包加入 OpenWrt ImageBuilder。

当前镜像包含的主要第三方/扩展组件包括：

- OpenClash
- Mihomo
- geoview
- xray-core
- sing-box
- hysteria
- luci-compat
- kmod-tun
- kmod-inet-diag
- kmod-nft-tproxy
- bash
- curl
- ip-full
- unzip

具体构建版本及完整 APK 清单会写入每次 GitHub Release 的构建信息中。

## 镜像输出

正式 Release 主要提供：

- UEFI `ext4` 镜像
- UEFI `squashfs` 镜像（按构建参数选择）
- QCOW2 镜像（启用 QCOW2 时）
- manifest
- SHA256 校验文件
- 构建信息及包含的 APK 清单

Release 页面只列出镜像实际包含的 APK 名称，不单独发布第三方 APK 文件。

## OpenWrt 版本自动检测

工作流支持自动检测 OpenWrt 最新稳定版本。

如果对应版本已经存在正式 Release，则不会重复构建；如果发现新的 OpenWrt 版本，则自动开始新的构建。

## 安全注意事项

**本仓库用于个人路由器/家庭网络镜像构建时，建议设置为 Private（私有仓库）。**

尤其不要把宽带 PPPoE 用户名、密码或其他敏感凭据直接写入代码、配置文件、Issue、Release 说明或日志中。

虽然 GitHub Actions Repository Secrets 不会直接显示给普通访问者，但如果构建过程把凭据写入最终固件，那么下载固件的人仍可能从固件配置中恢复凭据。因此，包含个人宽带配置的正式镜像不适合公开发布。

如果仓库或包含宽带凭据的镜像曾经公开过，建议更换宽带 PPPoE 密码，然后重新构建正式镜像。

## 项目定位

这是一个面向个人 x86-64 软路由设备的 OpenWrt ImageBuilder 项目，重点是：

- 双 WAN
- 多 LAN
- PPPoE
- OpenClash / Mihomo
- 第三方 APK
- UEFI
- 4G RootFS
- GitHub Actions 自动构建
- GitHub Release 自动发布
