# Dr.COM 校园网认证 Magisk 模块

本项目提供一个 Magisk 模块，用于在 Android 设备上自动登录 Dr.COM 校园网（无线版）。

**特点**：
- 全新移动端 WebUI，暗色主题，触控友好
- 通过 WebUI 配置账号信息，支持 AJAX 无刷新操作
- 内置上游自动检测更新，一键下载最新 Release
- 支持 IPv6 自动获取
- GitHub Actions 自动构建 Release

---

## 📁 目录结构

```
camp_networks_magisk/
├── .github/workflows/
│   └── release.yml                # GitHub Actions 自动构建 Release
├── scripts/
│   └── bump_version.sh            # 版本管理脚本（自动更新 module.prop + 打标签）
├── LICENSE
├── README.md
└── drcom-wlan-login/              # Magisk 模块根目录
    ├── module.prop                # 模块元信息
    ├── action.sh                  # Magisk Manager 操作按钮入口
    ├── start_webui.sh             # 启动 WebUI 服务（含进程管理）
    ├── uninstall.sh               # 卸载时清理配置文件
    └── system/
        └── bin/                   # 子模块：camp_networks 仓库
            └── python_vers/
                ├── wlan_login.py  # 认证核心脚本
                ├── webui.py       # WebUI 服务（端口 38080）
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

> 重复执行启动脚本会自动杀掉旧进程并重启服务。

### 配置与认证

1. **连接校园 Wi-Fi**，确保已获取 IP 地址。
2. **访问 WebUI**：手机浏览器打开 `http://127.0.0.1:38080`
3. **填写配置**：账号、密码、运营商后缀（如 `@cmcc`），点击 **「保存配置」**。
4. **触发认证**：点击 **「立即认证」**，页面将实时显示执行结果。

---

## 📦 自动更新

WebUI 内置了更新检测功能：

1. 在 WebUI 页面点击 **「检查更新」**
2. 自动查询 GitHub Releases 获取最新版本
3. 如有新版本，点击 **「下载并安装更新」** 自动下载 `.zip` 文件
4. 在 Magisk Manager 中从本地安装下载的 `.zip` 完成更新

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
- 提交变更
- 创建带注释的 Git 标签（包含自上一标签以来的提交信息）
- 可选推送到远程

### GitHub Actions 自动构建

推送 `v*` 格式的标签后，GitHub Actions 会自动：
1. 检出代码（含子模块）
2. 打包 `drcom-wlan-login` 为 `.zip`
3. 创建 GitHub Release 并上传 `.zip`

---

## ⚙️ 配置文件说明

- 配置文件 `config.env` 位于模块根目录：`/data/adb/modules/drcom-wlan-login/config.env`
- 由 WebUI 自动生成，也可手动编辑（需 root 权限）：
  ```ini
  USERNAME=your_username
  PASSWORD=your_password
  ACCOUNT_SUFFIX=@cmcc
  DEBUG=false
  ```

---

## 🔌 端口说明

- 默认端口：**38080**
- 如需修改，编辑 `webui.py` 中的 `PORT` 变量

---

## 📦 项目源码

- **Magisk 模块仓库**：[camp_networks_magisk](https://github.com/greenhandzdl/camp_networks_magisk)
- **认证脚本子模块**：[camp_networks](https://github.com/greenhandzdl/camp_networks)

---

## 📜 许可证

本项目采用 [MIT License](LICENSE)，详见根目录 `LICENSE` 文件。

> **注意**：本工具仅供学习与研究，请勿用于非法用途。使用前请确保已获得网络管理方的授权。
