# Dr.COM 校园网认证 Magisk 模块

本项目提供一个 Magisk 模块，用于在 Android 设备上自动登录 Dr.COM 校园网（无线版）。

**特点**：
- 全新移动端 WebUI，暗色主题，触控友好
- 通过 WebUI 配置账号信息，支持 AJAX 无刷新操作
- 多账户管理：保存/切换多个账号
- 自动认证：接入目标 WiFi 后自动触发认证并按间隔重跑
- 登出功能：一键断开校园网认证
- 开机自动打开面板（可配置）
- 自定义渠道后缀管理
- 内置更新检测（GitHub / jsDelivr CDN 双渠道）
- IPv6 自动获取（三级策略：接口 → socket 探测 → 全接口扫描）
- GitHub Actions 自动构建 Release

---

## 📁 目录结构

```
camp_networks_magisk/
├── .github/workflows/
│   └── release.yml                # GitHub Actions 自动构建 Release
├── scripts/
│   └── bump_version.sh            # 版本管理脚本
├── LICENSE
├── README.md
└── drcom-wlan-login/              # Magisk 模块根目录
    ├── module.prop                # 模块元信息
    ├── action.sh                  # Magisk Manager 操作按钮 → 启动 WebUI
    ├── service.sh                 # 开机自启脚本（读取 AUTO_OPEN_WEBUI 配置）
    ├── start_webui.sh             # 启动 WebUI 服务（含端口冲突检测）
    ├── uninstall.sh               # 卸载时清理数据目录
    └── system/
        └── bin/                   # 子模块：camp_networks 仓库
            └── python_vers/
                ├── webui.py       # WebUI HTTP 服务主程序
                ├── wlan_login.py  # 认证核心脚本
                ├── wlan_logout.py # 登出脚本
                ├── webui_utils/
                │   ├── auth.py    # 任务执行器 + 自动认证循环
                │   ├── config.py  # 配置读写 + 账号/渠道管理
                │   ├── constants.py # 全局常量定义
                │   ├── html.py    # WebUI HTML 模板
                │   ├── network.py # 网络信息获取
                │   └── update.py  # 更新检测与下载
                └── requirements.txt
```

---

## 🚀 安装与使用

### 前提条件

1. **Magisk 已安装**并具有 root 权限。
2. **Python 运行环境**：推荐刷入 [Py2Droid](https://github.com/Mrakorez/py2droid) Magisk 模块，提供 `python3` 命令。
3. **安装 Python 依赖**（在手机终端或 ADB shell 中执行）：
   ```bash
   pip3 install requests python-dotenv
   ```
   若 `pip3` 不可用，可尝试 `python3 -m pip install ...`。

### 安装模块

**方式一**：从 [GitHub Releases](https://github.com/greenhandzdl/camp_networks_magisk/releases) 下载最新 `.zip`，在 Magisk Manager 中「从本地安装」刷入。

**方式二**：手动将 `drcom-wlan-login` 文件夹压缩为 `.zip` 后刷入。

### 启动 WebUI

模块刷入后，有两种方式启动 WebUI 服务：

#### 方式一（推荐）：通过 Magisk Manager 按钮
在 Magisk Manager 中找到模块，点击进入详情页，点击 **「执行」** 按钮，服务将自动启动并打开浏览器。

#### 方式二：手动终端执行
```bash
sh /data/adb/modules/drcom-wlan-login/start_webui.sh
```

> 如果 WebUI 已在运行，重复执行启动脚本会直接打开浏览器，不会重启服务。

#### 开机自动启动
在 WebUI 设置页开启「开机自动打开面板」后，手机重启时会自动启动 WebUI 并打开浏览器。

### 配置与认证

1. **连接校园 Wi-Fi**，确保已获取 IP 地址。
2. **访问 WebUI**：手机浏览器打开 `http://127.0.0.1:38080`
3. **填写配置**：账号、密码、运营商后缀（如 `@cmcc`），点击 **「保存配置」**。
4. **触发认证**：点击 **「立即认证」**，页面将实时显示执行结果。

### 多账户管理

- 在设置页的「多账户设置」卡片中，可保存/删除/还原多个账号
- 从下拉列表选择已保存账号，自动填充到认证配置

### 登出

- 在认证页点击 **「登出」** 按钮，一键断开校园网认证

### 自动认证

- 在「自动」页启用自动认证，配置目标 WiFi 名称
- 接入目标 WiFi 后自动触发认证，按设定间隔重跑，断开 WiFi 自动停止

---

## 📦 自动更新

WebUI 内置了更新检测功能，支持两个渠道：

| 渠道 | 说明 |
|------|------|
| **GitHub** | 实时更新最快，但国内连接可能不稳定 |
| **CDN (jsDelivr)** | 国内访问快速稳定，但缓存可能导致更新延迟数小时 |

可在设置页切换更新渠道。

---

## 🛠 开发者工具

### 版本管理脚本

使用 `scripts/bump_version.sh` 自动管理版本：

```bash
# 递增补丁版本 (v2.0 → v2.0.1)
./scripts/bump_version.sh patch

# 递增次版本 (v2.0 → v2.1)
./scripts/bump_version.sh minor

# 递增主版本 (v2.0 → v3.0)
./scripts/bump_version.sh major

# 指定版本号
./scripts/bump_version.sh v2.1.0
```

脚本会自动：
- 更新 `module.prop` 中的 `version` 和 `versionCode`
- 同步更新 `update.json`
- 提交变更并创建带注释的 Git 标签
- 可选推送到远程

### GitHub Actions 自动构建

推送 `v*` 格式的标签后，GitHub Actions 会自动：
1. 检出代码（含子模块）
2. 打包 `drcom-wlan-login` 为 `.zip`
3. 创建 GitHub Release 并上传 `.zip`

---

## ⚙️ 配置文件说明

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

## 🔌 端口说明

- 默认端口：**38080**
- 可通过 WebUI 设置页修改端口号（修改后需通过 Magisk Manager 重启服务）

---

## 📦 项目源码

- **Magisk 模块仓库**：[camp_networks_magisk](https://github.com/greenhandzdl/camp_networks_magisk)
- **认证脚本子模块**：[camp_networks](https://github.com/greenhandzdl/camp_networks)

---

## 📜 许可证

本项目采用 [MIT License](LICENSE)，详见根目录 `LICENSE` 文件。

> **注意**：本工具仅供学习与研究，请勿用于非法用途。使用前请确保已获得网络管理方的授权。
