# 第三方 APK

第三方 APK 的选择入口为：

```text
shell/apk-custom-packages.sh
```

取消对应 `CUSTOM_PACKAGES` 行的注释即可按需集成。

构建时会同步：

```text
wukongdaily/apk/run/x86
```

并由 `shell/apk-prepare-packages.sh` 整理 APK。
