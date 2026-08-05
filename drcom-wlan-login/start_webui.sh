#!/system/bin/sh

MODDIR=${0%/*}

# ---------- 配置目录（独立数据目录，刷入新版模块不会丢失） ----------
DATA_DIR=/data/adb/drcom-wlan-login
mkdir -p "$DATA_DIR"
# 迁移旧版配置（旧版存放在模块目录，刷模块会被清空）
if [ -f "$MODDIR/config.env" ] && [ ! -f "$DATA_DIR/config.env" ]; then
    cp "$MODDIR/config.env" "$DATA_DIR/config.env"
    rm -f "$MODDIR/config.env"
fi
export DRCOM_CONFIG_DIR="$DATA_DIR"
CONFIG_FILE="$DATA_DIR/config.env"

cd "$MODDIR/system/bin/python_vers" || exit 1

read_cfg() {
    [ -f "$CONFIG_FILE" ] || return
    grep -i "^$1=" "$CONFIG_FILE" 2>/dev/null | head -1 | cut -d= -f2- | tr -d '[:space:]'
}

# ---------- 读取端口与日志路径 ----------
WEBUI_PORT=$(read_cfg PORT)
case "$WEBUI_PORT" in ''|*[!0-9]*) WEBUI_PORT=38080 ;; esac
if [ "$WEBUI_PORT" -lt 1 ] || [ "$WEBUI_PORT" -gt 65535 ]; then
    WEBUI_PORT=38080
fi

LOG_FILE=$(read_cfg LOG_FILE)
[ -n "$LOG_FILE" ] || LOG_FILE=/data/local/tmp/drcom_webui.log

# ---------- 彻底清理端口占用 ----------
pkill -f "python3 webui.py" 2>/dev/null
pkill -f "python3.*webui" 2>/dev/null
sleep 0.5
if command -v fuser >/dev/null 2>&1; then
    fuser -k ${WEBUI_PORT}/tcp >/dev/null 2>&1
fi
sleep 0.5
if pgrep -f "webui.py" >/dev/null 2>&1; then
    pkill -9 -f "webui.py" 2>/dev/null
    sleep 0.5
fi

# ---------- 启动新服务 ----------
nohup python3 webui.py > "$LOG_FILE" 2>&1 &
NEW_PID=$!
echo "WebUI 已启动，PID: $NEW_PID，端口: $WEBUI_PORT，日志: $LOG_FILE"

# 等待服务就绪
sleep 2

# 检查是否启动成功
if kill -0 $NEW_PID 2>/dev/null; then
    am start -a android.intent.action.VIEW -d "http://127.0.0.1:${WEBUI_PORT}" 2>/dev/null \
      || echo "无法自动打开浏览器，请手动访问 http://127.0.0.1:${WEBUI_PORT}"
else
    echo "启动失败，查看日志: cat $LOG_FILE"
    cat "$LOG_FILE" 2>/dev/null
fi
