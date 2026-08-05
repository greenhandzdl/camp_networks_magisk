# Dr.COM 校园网认证 Magisk 模块

本项目提供一个 Magisk 模块，用于在 Android 设备上自动登录 Dr.COM 校园网（无线版）。  
**特点**：
- 不含开机自启，用户通过 Magisk Manager 按钮或终端手动启动
- 通过 WebUI 配置账号信息，界面友好
- 服务端口使用 **38080**，避免与常见应用冲突
- 支持 IPv6 自动获取

---

## 📁 目录结构

```
camp_networks_magisk/
├── LICENSE
├── README.md
└── drcom-wlan-login/                # Magisk 模块根目录
    ├── module.prop                  # 模块元信息
    ├── action.sh                    # Magisk Manager 操作按钮入口
    ├── start_webui.sh               # 启动 WebUI 服务（含进程管理）
    ├── uninstall.sh                 # 卸载时清理配置文件
    └── system/
        └── bin/                     # 子模块：camp_networks 仓库
            └── python_vers/
                ├── wlan_login.py    # 认证核心脚本
                ├── webui.py         # WebUI 服务（端口 38080）
                └── requirements.txt # Python 依赖
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

1. 将本仓库的 `drcom-wlan-login` 文件夹压缩为 `.zip`。
2. 在 Magisk Manager 中选择“从本地安装”，刷入该 `.zip` 文件。
3. 重启手机（非必须，但推荐）。

### 启动 WebUI

模块刷入后，有两种方式启动 WebUI 服务：

#### 方式一（推荐）：通过 Magisk Manager 按钮
在 Magisk Manager 中找到 **“Dr.COM WLAN WebUI”** 模块，点击进入详情页，点击 **“执行”** 按钮，服务将自动启动并打开浏览器。

#### 方式二：手动终端执行
在终端（需 root）执行：
```bash
sh /data/adb/modules/drcom-wlan-login/start_webui.sh
```

> **注意**：重复执行启动脚本会自动杀掉旧进程并重启服务，避免端口冲突。

### 配置与认证

1. **连接校园 Wi-Fi**，确保已获取 IP 地址。
2. **访问 WebUI**：手机浏览器打开 `http://127.0.0.1:38080`（启动脚本会自动尝试打开）。
3. **填写配置**：
   - 账号（不含后缀，如 `your_username`）
   - 密码
   - 运营商后缀（通常为 `@cmcc`、`@telecom` 或 `@unicom`）
   - 调试模式（可选）
   点击 **“保存配置”**。
4. **触发认证**：点击 **“立即运行认证脚本”**，页面将显示执行输出。若成功，将看到 `🎉 登录成功！`。
5. **关闭 WebUI**（可选）：
   ```bash
   pkill -f webui.py
   ```

---

## ⚙️ 配置文件说明

- 配置文件 `config.env` 位于模块根目录：`/data/adb/modules/drcom-wlan-login/config.env`。
- 内容格式（由 WebUI 自动生成）：
  ```ini
  USERNAME=your_username
  PASSWORD=your_password
  ACCOUNT_SUFFIX=@cmcc
  DEBUG=false
  ```
- 若需手动编辑，可直接修改此文件（需 root 权限）。

---

## 🔌 端口说明

- 默认端口：**38080**
- 为什么使用 38080？
  - 避开常见服务端口（如 8080、8000、80 等）
  - 38080 属于高位端口，较少被占用，降低冲突风险
- 如需修改端口，请编辑 `webui.py` 中的 `PORT` 变量。

---

## 🧹 卸载模块

在 Magisk Manager 中移除模块即可。模块自带的 `uninstall.sh` 会删除 `config.env` 配置文件。

---

## 🛠 调试与排错

- **WebUI 日志**：`/data/local/tmp/drcom_webui.log`
- **认证脚本输出**：在 WebUI 页面点击“运行”后直接显示。
- **检查端口是否被占用**：
  ```bash
  netstat -tuln | grep 38080
  ```
- **手动测试认证脚本**：
  ```bash
  cd /data/adb/modules/drcom-wlan-login/system/bin/python_vers
  DRCOM_CONFIG_DIR=/data/adb/modules/drcom-wlan-login python3 wlan_login.py
  ```
- **常见问题**：
  - *“网关不可达”*：请检查是否已连接校园 Wi-Fi 并获取到 IP。
  - *“认证失败”*：检查账号、密码、后缀是否正确。
  - *WebUI 无法访问*：确保服务已启动，端口 `38080` 未被占用。
  - *自动打开浏览器失败*：手动在浏览器输入 `http://127.0.0.1:38080`。

---

## 📦 项目源码

- **Magisk 模块仓库**：[camp_networks_magisk](https://github.com/greenhandzdl/camp_networks_magisk)
- **认证脚本子模块**：[camp_networks](https://github.com/greenhandzdl/camp_networks)（包含有线/无线通用认证逻辑）

---

## 📜 许可证

本项目采用 [MIT License](LICENSE)，详见根目录 `LICENSE` 文件。

---

## 🤝 贡献

欢迎提交 Issue 或 Pull Request。若需适配其他校园网认证协议，可参考 `camp_networks` 项目进行扩展。

> **注意**：本工具仅供学习与研究，请勿用于非法用途。使用前请确保已获得网络管理方的授权。
