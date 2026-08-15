# APK 目录

此目录存放内嵌 APK，由 GitHub Actions 构建时自动注入 `DrCom.apk`。

- **CI 构建**：`build-apk` job 构建 APK → `build` job 下载并放入此目录 → 打包进模块 zip
- **本地构建**：手动运行 `android_app/build_apk.sh`，然后将产物拷贝到此目录
- **运行时**：`customize.sh` 在模块安装时自动 `pm install -r`；`action.sh` 每次点击 action 时幂等更新
