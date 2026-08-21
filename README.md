# OpenWrt x86-64 ImageBuilder

这是一个基于官方 OpenWrt ImageBuilder 的 x86-64 镜像构建项目。

本项目使用官方 ImageBuilder 制作 OpenWrt 固件，不编译完整 OpenWrt 源代码树，主要面向 x86-64 软路由设备（例如 N100/N150/i226 多网口小主机）。

## 构建特性

GitHub Actions 支持自动构建：

- OpenWrt 25.12+（支持自动检测最新稳定版本）
- x86-64 UEFI 镜像
- ext4 / squashfs 文件系统
- 1G / 2G / 3G / 4G RootFS 容量
- QCOW2 虚拟机镜像
- GitHub Release 自动发布
- 构建信息自动生成
- SHA256 校验文件生成

## 默认网络规划（单 WAN 稳定版）

当前版本采用简单稳定的单 WAN 网络结构：

| 网口 | 用途 | 配置 |
|---|---|---|
| `eth0` | WAN | 未配置协议，用户自行设置 |
| `eth1` | LAN | 加入 LAN Bridge |
| `eth2` | LAN | 加入 LAN Bridge |
| `eth3` | LAN | 加入 LAN Bridge |
| `eth4` | LAN | 加入 LAN Bridge |
| `eth5` | LAN | 加入 LAN Bridge |

默认 LAN 地址：

```
192.168.1.2
```

WAN 口：

```
eth0
```

默认不写入：

- PPPoE 用户名
- PPPoE 密码
- 宽带账号信息

首次使用时，请通过 LuCI 页面手动配置 WAN。

## 已移除功能

当前版本为精简稳定版，不包含：

- 双 WAN
- WANB
- mwan3
- 多拨
- 负载均衡
- 多 WAN 分流策略

如果未来需要以上功能，可以在运行中的 OpenWrt 中自行安装相关软件包。

## 代理与网络组件

固件保留代理运行环境：

- OpenClash
- Mihomo
- xray-core
- sing-box
- hysteria
- naiveproxy
- geoview

内核及网络支持：

- kmod-tun
- kmod-nft-tproxy
- kmod-nft-socket
- kmod-inet-diag

适用于：

- OpenClash
- PassWall
- TProxy 透明代理
- 自定义代理规则

## PassWall 安装方式

OpenWrt 25.12+ 使用 APK 包管理方式。

本项目不直接把 PassWall LuCI 软件包固定写入固件，而是在镜像中预留官方 APK 源配置方式。

安装 PassWall 时使用官方 APK feed：

```bash
apk update
apk add luci-app-passwall luci-i18n-passwall-zh-cn
```

这样可以避免依赖不完整，并方便后续升级。

## 第三方 APK

第三方组件使用预编译 APK，不在本项目重新编译第三方源码。

构建时会检查软件包完整性，并将需要的软件加入 ImageBuilder。

Release 信息中会显示当前固件实际包含的软件包名称。

Release 不单独上传第三方 APK 文件。

## 镜像输出

正式 Release 包含：

- UEFI ext4 镜像
- UEFI squashfs 镜像（根据参数选择）
- QCOW2 虚拟机镜像
- manifest
- SHA256 校验文件
- BUILD-INFO.md

## PVE 使用

QCOW2 镜像适用于 Proxmox VE：

建议：

- BIOS：OVMF (UEFI)
- 网卡模型：VirtIO
- 网络通过 vmbr 桥接

推荐结构：

```
物理网口
  |
PVE vmbr
  |
OpenWrt VM
```

无需 PCI 直通即可满足千兆及多千兆软路由需求。

## 自动构建逻辑

工作流支持：

- 手动触发构建
- 自动检测 OpenWrt 新版本
- 新版本自动构建
- 自动生成 Release

如果对应版本已经存在 Release，则不会重复构建。

## 安全说明

建议将仓库设置为 Private。

不要把以下信息写入仓库：

- 宽带账号
- 宽带密码
- VPN 密钥
- 私人配置文件

敏感信息应通过：

```
GitHub Actions Repository Secrets
```

或首次启动后手动配置。

## 项目定位

这是一个面向个人 x86-64 软路由设备的 OpenWrt 固件构建项目。

目标：

- 简洁稳定
- 单 WAN
- 多 LAN
- PVE 虚拟化运行
- OpenClash / PassWall 支持
- 第三方 APK 扩展
- UEFI
- QCOW2
- GitHub Actions 自动化构建
