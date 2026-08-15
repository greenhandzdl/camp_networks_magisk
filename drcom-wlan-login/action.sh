#!/system/bin/sh

# 获取当前模块的根目录
MODDIR=${0%/*}

# ---------- 安装/更新内嵌 APK（幂等操作，版本相同几乎无耗时）----------
APK_PATH="$MODDIR/apk/DrCom.apk"
if [ -f "$APK_PATH" ]; then
    pm install -r "$APK_PATH" >/dev/null 2>&1 || true
fi

# 执行启动 WebUI 的脚本
sh $MODDIR/start_webui.sh
