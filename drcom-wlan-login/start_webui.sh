#!/system/bin/sh

MODDIR=${0%/*}
export DRCOM_CONFIG_DIR="$MODDIR"
cd "$MODDIR/system/bin/python_vers" || exit 1

# ---------- 读取端口配置 ----------
WEBUI_PORT=38080
if [ -f "$MODDIR/config.env" ]; then
    PORT_LINE=$(grep -i '^PORT=' "$MODDIR/config.env" 2>/dev/null)
    if [ -n "$PORT_LINE" ]; then
        PORT_VAL=$(echo "$PORT_LINE" | cut -d= -f2 | tr -d '[:space:]')
        if [ -n "$PORT_VAL" ] && [ "$PORT_VAL" -gt 0 ] 2>/dev/null && [ "$PORT_VAL" -le 65535 ]; then
            WEBUI_PORT=$PORT_VAL
        fi
    fi
fi

# ---------- 彻底清理端口占用 ----------
# 1. 按进程名杀
pkill -f "python3 webui.py" 2>/dev/null
pkill -f "python3.*webui" 2>/dev/null
sleep 0.5

# 2. 按端口杀（兜底，防止残留进程占用）
if command -v fuser >/dev/null 2>&1; then
    fuser -k ${WEBUI_PORT}/tcp >/dev/null 2>&1
fi
sleep 0.5

# 3. 最终确认
if pgrep -f "webui.py" >/dev/null 2>&1; then
    pkill -9 -f "webui.py" 2>/dev/null
    sleep 0.5
fi

# ---------- 启动新服务 ----------
nohup python3 webui.py > /data/local/tmp/drcom_webui.log 2>&1 &
NEW_PID=$!
echo "WebUI 已启动，PID: $NEW_PID，端口: $WEBUI_PORT"

# 等待服务就绪
sleep 2

# 检查是否启动成功
if kill -0 $NEW_PID 2>/dev/null; then
    am start -a android.intent.action.VIEW -d "http://127.0.0.1:${WEBUI_PORT}" 2>/dev/null \
      || echo "无法自动打开浏览器，请手动访问 http://127.0.0.1:${WEBUI_PORT}"
else
    echo "启动失败，查看日志: cat /data/local/tmp/drcom_webui.log"
    cat /data/local/tmp/drcom_webui.log 2>/dev/null
fi