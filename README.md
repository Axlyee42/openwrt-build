# OpenWrt x86-64 ImageBuilder

本项目采用 **wukongdaily/ImmortalWrt-ImageBuilder 的 ImageBuilder 思路**，但基础系统改为 **OpenWrt 官方 25.12+ ImageBuilder**。

## 当前范围

只保留：

- x86-64
- UEFI
- EXT4
- QCOW2

不再维护其他硬件型号。

## 基础配置

固件默认：

- LuCI
- LuCI 简体中文
- 软件包管理器
- 软件包管理器中文包
- 中国时区 `Asia/Shanghai`
- LuCI 默认语言 `zh_cn`

## 软件选择

所有可选软件统一在：

```text
shell/apk-custom-packages.sh
```

采用注释/取消注释方式选择 APK，保持 wukongdaily ImageBuilder 的使用习惯。

workflow 不再维护重复的软件包列表。

## 第三方 APK 源

### PassWall

固件写入：

```text
/etc/apk/repositories.d/customfeeds.list
```

包含：

- `passwall_luci`
- `passwall_packages`
- `passwall2`

并安装 PassWall 官方教程使用的 APK 公钥。

### DAE / DAED

加入 kenzok8/openwrt-daede 对应的 25.12 x86_64 APK 源。

可选：

```text
dae
daed
luci-app-daede
vmlinux-btf
```

注意：daed 使用 CO-RE eBPF，官方 OpenWrt 内核可能没有 BTF。选择 daed 时应同时选择匹配的 `vmlinux-btf` 包。

## OpenWrt 版本自动更新

`.github/workflows/check-update.yml` 每天检查 OpenWrt 官方仓库的稳定版本标签。

只有当：

```text
latest OpenWrt version != latest-version.txt
```

时才会：

1. 更新 `latest-version.txt`
2. 自动触发 `build-x86-64.yml`
3. 使用新的 OpenWrt 官方 ImageBuilder 构建固件
4. 发布到 GitHub Release

普通代码提交不会自动构建固件。

## Release

每个 OpenWrt 版本发布：

- UEFI EXT4 压缩镜像
- EXT4 RAW 镜像
- QCOW2 镜像
- Release Notes
- 本次构建实际选择的软件包列表

## 目录结构

```text
.github/workflows/
├── build-x86-64.yml
└── check-update.yml

shell/
├── apk-custom-packages.sh
└── prepare-feeds.sh

latest-version.txt
README.md
```

## 许可证

ImageBuilder 的整体结构参考并改造自 wukongdaily/ImmortalWrt-ImageBuilder；相关上游项目及第三方组件的版权和许可证保持原样。
