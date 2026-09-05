# OpenWrt-ImageBuilder

基于 GitHub Actions + 官方 ImageBuilder 构建 **OpenWrt 25.12.x x86-64 固件**。

本项目保持现有目录结构，x86-64 构建流程参考并保留 wukongdaily/ImmortalWrt-ImageBuilder 的组织方式；基础系统改为 OpenWrt 官方 ImageBuilder。第三方 APK 统一通过 `shell/apk-custom-packages.sh` 管理。

## 当前构建方式

工作流：`.github/workflows/build-x86-64-25.12.x.yml`

仅支持 **手动触发（workflow_dispatch）**，不会因为提交代码自动编译。

进入 **GitHub Actions → Build 25.12.x x86-64 → Run workflow** 后，可以选择：

| 参数 | 说明 | 默认值 |
|---|---|---|
| OpenWrt 25.12.x | 留空自动使用 25.12.x 最新版本，也可以指定具体版本 | 最新版 |
| 管理地址 | 多网口设备的 LAN 管理地址 | `192.168.1.2` |
| 软件包空间 | 1G / 2G / 3G / 4G | `4G` |
| PPPoE | 是否启用 PPPoE | `no` |
| PPPoE 账号/密码 | 仅在启用 PPPoE 时填写 | 空 |
| BIOS EXT4 | 是否生成 BIOS 镜像 | 关闭 |
| UEFI EXT4 | 是否生成 UEFI 镜像 | 开启 |
| QCOW2 | 是否生成 QCOW2 | 开启 |
| VMDK | 是否生成 VMDK | 关闭 |
| RAW | 是否生成 RAW | 关闭 |

PPPoE 密码只用于当前构建过程，不写入 Release 信息；日志中会进行脱敏。

## x86-64 网络逻辑

- **单网口**：LAN 默认通过 DHCP 从上级网络获取地址。
- **多网口**：第一个物理网口作为 WAN，其余物理网口加入 `br-lan`。
- **WAN**：默认 DHCP，也可以在手动构建时启用 PPPoE。
- **LAN 管理地址**：默认 `192.168.1.2`，通过 `custom_router_ip` 修改。
- 首次启动网络初始化由 `files/etc/uci-defaults/99-custom.sh` 完成。

> 如果修改了 LAN 地址，请以本次构建时填写的地址为准；Release 页面和 `build-info.txt` 会记录实际构建使用的管理地址。

## 第三方 APK 管理

第三方软件不再通过 workflow 输入框逐项选择，而是统一在：

```text
shell/apk-custom-packages.sh
```

中按需取消对应行的注释。

### 默认包含

以下代理核心默认加入每次构建：

```text
geoview
xray-core
sing-box
hysteria
```

### 可选 LuCI 应用

当前脚本保留 wukongdaily 原版的菜单结构，并针对本项目需要做最小调整。选择 LuCI 应用时，应同时加入对应的中文包；需要额外运行时依赖的应用，其依赖也绑定在同一行。

例如：

```bash
# OpenClash
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash luci-i18n-openclash-zh-cn luci-compat kmod-tun kmod-inet-diag kmod-nft-tproxy bash curl ip-full unzip"

# PassWall
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-passwall luci-i18n-passwall-zh-cn geoview xray-core sing-box hysteria"

# HomeProxy
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-homeproxy luci-i18n-homeproxy-zh-cn"

# MWAN3
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-mwan3 luci-i18n-mwan3-zh-cn"
```

`luci-app-run`、QuickFile、Aurora、Bandix、Lucky、DDNS-Go 以及官方仓库中的大量 `luci-i18n-*` 选项仍保留在脚本中，可按需启用。

**注意：** `luci-app-run` 与 QuickFile 存在 nginx 配置冲突，请勿同时启用。

### 明确不会加入

- PassWall2
- `luci-i18n-3ginfo-lite-zh-cn`
- `luci-app-gpon-status`
- `luci-app-port-status`

## 固件格式

工作流使用 OpenWrt 官方 x86/64 ImageBuilder，支持生成：

- BIOS EXT4
- UEFI EXT4
- QCOW2
- VMDK
- RAW

实际生成哪些格式由本次 `Run workflow` 的选项决定。

## GitHub Release

每次成功构建都会自动创建 GitHub Release，并上传本次构建生成的固件及校验文件。

Release 中会同时提供 `build-info.txt`，记录本次固件的基本信息，包括：

- OpenWrt 具体版本
- 构建时间
- x86-64 target
- EXT4 / 分区空间大小
- **实际 LAN 管理 IP**
- PPPoE 是否启用
- **本次实际包含的第三方 APK 列表**
- 本次生成的 BIOS / UEFI / QCOW2 / VMDK / RAW 格式
- SHA256 校验信息

Release 固件文件名包含：

```text
OpenWrt-版本-x86-64-软件包空间-时间-格式
```

例如：

```text
OpenWrt-25.12.5-x86-64-4G-20260905-120000-UEFI-ext4.img.gz
```

## 构建流程

1. 检查指定或最新的 OpenWrt 25.12.x 版本。
2. 下载 OpenWrt 官方 x86-64 ImageBuilder。
3. 校验 ImageBuilder SHA256。
4. 校验 `shell/apk-custom-packages.sh`。
5. 按脚本准备第三方 APK。
6. 写入 LAN / PPPoE 网络配置。
7. 使用 `x86-64/build25.sh` 调用官方 ImageBuilder 构建。
8. 根据选择转换 BIOS / UEFI / QCOW2 / VMDK / RAW。
9. 生成 `build-info.txt` 和 `sha256sums`。
10. 自动发布 GitHub Release。
11. 更新仓库中的 `openwrt-version`。

## 目录说明

```text
.github/workflows/
└── build-x86-64-25.12.x.yml   # GitHub Actions 主工作流

x86-64/
└── build25.sh                  # x86-64 ImageBuilder 构建脚本

shell/
├── apk-custom-packages.sh      # 第三方 APK / LuCI 应用选择
└── apk-prepare-packages.sh     # APK 准备与整理

files/
└── etc/uci-defaults/99-custom.sh  # 首次启动网络初始化

openwrt-version                 # 最近一次成功构建的 OpenWrt 版本
```

## 设计原则

- 保持现有目录结构，不随意重构。
- 以 wukongdaily 原版 `apk-custom-packages.sh` 结构为基础，只做必要增量。
- 编译失败时只针对实际报错点修改，不大面积重写已经验证正常的部分。
- 第三方 LuCI 应用与中文包、必要依赖尽量绑定管理。
- 不加入 PassWall2。
