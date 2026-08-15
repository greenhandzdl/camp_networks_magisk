# Dr.COM 校园网认证 Magisk 模块 + APK

本项目提供 **Magisk 模块**（root 设备，完整体验）和**独立 APK**（无 root 可用），用于在 Android 设备上登录/登出 Dr.COM 校园网。

## 双路径方案

| 特性 | Magisk 模块（root） | 独立 APK（无 root） |
|------|---------------------|---------------------|
| 认证/登出 | 完整 | 完整（复用同一套认证核心） |
| WebUI 管理 | 浏览器访问 127.0.0.1:38080 | - |
| 多账户/渠道管理 | 完整 | 单账户 |
| 自动认证 | 接入目标 WiFi 自动触发 | - |
| 开机自启 | 可选自动打开面板 | - |
| 更新检测 | WebUI 内置 | APK 内置 |
| 安装方式 | Magisk Manager 刷入 zip | 直接安装 apk |

> APK 在 root 设备上检测到模块已安装时，会自动切换到"模块模式"，通过 WebUI API 操作，功能与 WebUI 对齐。

---

## 功能列表

- 全新移动端 WebUI，暗色主题，触控友好
- 通过 WebUI 配置账号信息，支持 AJAX 无刷新操作
- 多账户管理：保存/切换多个账号
- 自动认证：接入目标 WiFi 后自动触发认证并按间隔重跑
- 登出功能：一键断开校园网认证
- 开机自动打开面板（可配置）
- 自定义渠道后缀管理
- **Kivy APK**：自包含跨平台客户端，无 root 可用，root 时推荐安装模块获取完整体验
- 内置更新检测（GitHub / jsDelivr CDN 双渠道）
- IPv6 自动获取（三级策略：接口 → socket 探测 → 全接口扫描）
- GitHub Actions 自动构建 Release（模块 zip + 独立 APK）

---

## 目录结构

```
camp_networks_magisk/
├── .github/workflows/
│   └── release.yml                # CI: 构建 APK + 模块 zip + 发布 Release
├── scripts/
│   └── bump_version.sh            # 版本管理脚本
├── LICENSE
├── README.md
└── drcom-wlan-login/              # Magisk 模块根目录
    ├── module.prop                # 模块元信息
    ├── action.sh                  # Magisk action 按钮 → 安装 APK + 启动 WebUI
    ├── customize.sh               # 安装时自动安装 APK + 迁移配置
    ├── service.sh                 # 开机自启（读取 AUTO_OPEN_WEBUI 配置）
    ├── start_webui.sh             # 启动 WebUI 服务（含端口冲突检测）
    ├── uninstall.sh               # 卸载时清理数据目录
    ├── apk/                       # 内嵌 APK（CI 构建时注入 DrCom.apk）
    └── system/
        └── bin/                   # 子模块：camp_networks 仓库
            ├── python_vers/
            │   ├── webui.py       # WebUI HTTP 服务主程序
            │   ├── drcom_core.py  # 平台无关认证核心库（模块 + APK 共用）
            │   ├── wlan_login.py  # 认证 CLI（薄封装 drcom_core）
            │   ├── wlan_logout.py # 登出 CLI（薄封装 drcom_core）
            │   ├── webui_utils/
            │   │   ├── auth.py    # ScriptTask 类 + 自动认证循环
            │   │   ├── config.py  # 配置读写 + 账号/渠道管理
            │   │   ├── constants.py # 全局常量定义
            │   │   ├── html.py    # WebUI HTML 模板
            │   │   ├── network.py # 网络信息获取（shell 命令）
            │   │   └── update.py  # 更新检测与下载
            │   ├── tests/         # 单元测试（drcom_core）
            │   └── requirements.txt
            └── android_app/       # Kivy APK 工程
                ├── buildozer.spec # buildozer 配置
                ├── build_apk.sh   # 构建脚本（拷贝 drcom_core + 注入版本）
                └── app/
                    ├── main.py    # Kivy App（ScreenManager：状态/配置/关于）
                    ├── backend.py # backend 抽象（LocalBackend / ModuleBackend）
                    └── native_net.py # pyjnius WifiManager（Android 网络信息）
```

---

## 安装与使用

### 方式一：Magisk 模块（推荐，需 root）

1. 从 [GitHub Releases](https://github.com/greenhandzdl/camp_networks_magisk/releases) 下载最新 `drcom-wlan-login.zip`
2. 在 Magisk Manager 中选择「从本地安装」刷入
3. 重启后，模块会自动安装内嵌的 APK（也可在 Magisk 模块页点击 action 手动安装）

**前提条件**：
- Magisk 已安装并具有 root 权限
- Python 运行环境：推荐刷入 [Py2Droid](https://github.com/Mrakorez/py2droid) Magisk 模块
- 安装 Python 依赖：`pip3 install requests python-dotenv`

### 方式二：独立 APK（无 root）

1. 从 [GitHub Releases](https://github.com/greenhandzdl/camp_networks_magisk/releases) 下载最新 `DrCOM-WLAN-*.apk`
2. 直接安装使用（本地模式，复用认证核心代码）

> APK 在 root 设备上检测到模块已安装时，会自动切换到"模块模式"，通过 WebUI API 操作。

### 启动 WebUI（模块用户）

#### 方式一（推荐）：通过 Magisk Manager 按钮
在 Magisk Manager 中找到模块，点击进入详情页，点击 **「执行」** 按钮，将自动安装/更新 APK 并打开浏览器。

#### 方式二：手动终端执行
```bash
sh /data/adb/modules/drcom-wlan-login/start_webui.sh
```

> 如果 WebUI 已在运行，重复执行启动脚本会直接打开浏览器，不会重启服务。

#### 开机自动启动
在 WebUI 设置页开启「开机自动打开面板」后，手机重启时会自动启动 WebUI 并打开浏览器。

### 配置与认证

1. **连接校园 Wi-Fi**，确保已获取 IP 地址
2. **访问 WebUI**：手机浏览器打开 `http://127.0.0.1:38080`
3. **填写配置**：账号、密码、运营商后缀（如 `@cmcc`），点击 **「保存配置」**
4. **触发认证**：点击 **「立即认证」**，页面将实时显示执行结果

### 多账户管理
- 在设置页的「多账户设置」卡片中，可保存/删除/还原多个账号
- 从下拉列表选择已保存账号，自动填充到认证配置

### 登出
- 在认证页点击 **「登出」** 按钮，一键断开校园网认证

### 自动认证
- 在「自动」页启用自动认证，配置目标 WiFi 名称
- 接入目标 WiFi 后自动触发认证，按设定间隔重跑，断开 WiFi 自动停止

---

## 自动更新

### WebUI 更新（模块用户）
WebUI 内置了更新检测功能，支持两个渠道：

| 渠道 | 说明 |
|------|------|
| **GitHub** | 实时更新最快，但国内连接可能不稳定 |
| **CDN (jsDelivr)** | 国内访问快速稳定，但缓存可能导致更新延迟数小时 |

可在设置页切换更新渠道。

### APK 更新（独立 APK 用户）
APK 关于页内置「检查更新」按钮，从 GitHub update.json 检测新版本。

---

## 开发者工具

### 版本管理脚本

使用 `scripts/bump_version.sh` 自动管理版本：

```bash
./scripts/bump_version.sh patch    # 递增补丁版本
./scripts/bump_version.sh minor    # 递增次版本
./scripts/bump_version.sh major    # 递增主版本
./scripts/bump_version.sh v2.1.0   # 指定版本号
```

脚本会自动：
- 更新 `module.prop` 中的 `version` 和 `versionCode`
- 同步更新 `update.json`
- 提交变更并创建带注释的 Git 标签
- 可选推送到远程

### GitHub Actions 自动构建

推送 `v*` 格式的标签后，GitHub Actions 会自动：
1. **build-apk job**：构建 Kivy APK（buildozer + 缓存加速）
2. **build job**：下载 APK 并嵌入模块 zip，创建 Release 上传 zip + apk 双资产
3. 同步 zip 和 apk 到 releases 分支（jsDelivr CDN 加速）
4. 刷新 CDN 缓存

### 本地构建 APK

```bash
cd drcom-wlan-login/system/bin/android_app
pip install buildozer
bash build_apk.sh
```

产物在 `bin/` 目录下。

---

## 配置文件说明

- 配置文件 `config.env` 位于独立数据目录：`/data/adb/drcom-wlan-login/config.env`
- 刷入新版模块不会丢失配置（数据目录与模块目录分离）
- 由 WebUI 自动生成，也可手动编辑（需 root 权限）：
  ```ini
  USERNAME=your_username
  PASSWORD=your_password
  SUFFIX=@cmcc
  DEBUG=false
  PORT=38080
  AUTO_RUN=false
  TARGET_ESSID=
  AUTO_OPEN_WEBUI=false
  AUTH_SERVER=10.0.1.5
  REDIRECT_SERVER=1.2.3.4
  ```

---

## 端口说明

- 默认端口：**38080**
- 可通过 WebUI 设置页修改端口号（修改后需通过 Magisk Manager 重启服务）

---

## 项目源码

- **Magisk 模块仓库**：[camp_networks_magisk](https://github.com/greenhandzdl/camp_networks_magisk)
- **认证脚本子模块**：[camp_networks](https://github.com/greenhandzdl/camp_networks)

---

## 许可证

本项目采用 [MIT License](LICENSE)，详见根目录 `LICENSE` 文件。

> **注意**：本工具仅供学习与研究，请勿用于非法用途。使用前请确保已获得网络管理方的授权。
