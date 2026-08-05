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

# ---------- 检查并终止已有进程 ----------
OLD_PID=$(pgrep -f "python3 webui.py")
if [ -n "$OLD_PID" ]; then
    echo "检测到已有 WebUI 服务 (PID: $OLD_PID)，正在停止..."
    kill $OLD_PID
    sleep 1
    # 若未终止，强制杀死
    if pgrep -f "python3 webui.py" > /dev/null; then
        kill -9 $OLD_PID
        echo "强制停止旧服务。"
    else
        echo "旧服务已停止。"
    fi
fi

# ---------- 启动新服务 ----------
nohup python3 webui.py > /data/local/tmp/drcom_webui.log 2>&1 &
NEW_PID=$!
echo "WebUI 已启动，新 PID: $NEW_PID，端口: $WEBUI_PORT"

# 等待服务就绪
sleep 2

# 尝试自动打开浏览器
am start -a android.intent.action.VIEW -d "http://127.0.0.1:${WEBUI_PORT}" 2>/dev/null || echo "无法自动打开浏览器，请手动访问 http://127.0.0.1:${WEBUI_PORT}"