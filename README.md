# OpenWrt x86-64 ImageBuilder

这是一个基于 **OpenWrt 官方 ImageBuilder** 的 GitHub Actions 云端构建项目。

项目只保留 x86-64 目标，并固定输出：

- UEFI
- EXT4
- QCOW2

不进行 OpenWrt 源码编译，使用官方 ImageBuilder 生成固件。

## 构建方式

进入 GitHub：

`Actions → Build OpenWrt x86-64 → Run workflow`

可设置：

- OpenWrt 版本
- rootfs 分区大小（MB）
- 默认 LAN IP
- 第三方 APK/软件包
- 是否发布 GitHub Release

## 第三方 APK/软件包

第三方包采用类似 wukongdaily/ImmortalWrt-ImageBuilder 的清单方式管理。

文件：

`scripts/apk-custom-packages.sh`

在该文件中取消对应行前面的 `#` 即可选择软件组。也可以在 Actions 的 `custom_packages` 输入框中临时追加以空格分隔的软件包。

请确认所选择的软件包存在于对应 OpenWrt 官方或配置的 APK/package feed 中。

## 固件输出

每次成功构建固定生成：

`openwrt-x86-64-uefi-ext4.qcow2`

同时生成 `build-info.txt`，记录：

- OpenWrt 版本
- x86-64 目标
- UEFI/EXT4/QCOW2 格式
- rootfs 大小
- LAN IP
- 构建时间
- 包含的软件包

成功构建后会上传 Actions Artifact，并在启用 Release 时自动发布 GitHub Release。

## PVE

QCOW2 文件可以直接用于 PVE。创建虚拟机后导入该磁盘即可。

## 说明

本项目的构建思路参考 wukongdaily/ImmortalWrt-ImageBuilder，但底层使用 OpenWrt 官方 ImageBuilder。
