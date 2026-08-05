#!/system/bin/sh

MODDIR=${0%/*}
export DRCOM_CONFIG_DIR="$MODDIR"
cd "$MODDIR/system/bin/python_vers" || exit 1

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
echo "WebUI 已启动，新 PID: $NEW_PID"

# 等待服务就绪
sleep 2

# 尝试自动打开浏览器
am start -a android.intent.action.VIEW -d http://127.0.0.1:38080 2>/dev/null || echo "无法自动打开浏览器，请手动访问 http://127.0.0.1:38080"