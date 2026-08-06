#!/system/bin/sh
# Magisk late_start 脚本：开机后自动启动 WebUI 并打开浏览器
# 仅在 config.env 中 AUTO_OPEN_WEBUI=true 时执行

MODDIR=${0%/*}
DATA_DIR=/data/adb/drcom-wlan-login
CONFIG_FILE="$DATA_DIR/config.env"

# 读取配置
read_cfg() {
    [ -f "$CONFIG_FILE" ] || return
    grep -i "^$1=" "$CONFIG_FILE" 2>/dev/null | head -1 | cut -d= -f2- | tr -d '[:space:]'
}

AUTO_OPEN=$(read_cfg AUTO_OPEN_WEBUI)

if [ "$AUTO_OPEN" = "true" ] || [ "$AUTO_OPEN" = "1" ]; then
    # 等待系统完全启动（网络、am 命令就绪）
    sleep 15
    sh "$MODDIR/start_webui.sh"
fi
