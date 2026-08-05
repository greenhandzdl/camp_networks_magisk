#!/system/bin/sh

# 获取当前模块的根目录
MODDIR=${0%/*}

# 执行启动 WebUI 的脚本
sh $MODDIR/start_webui.sh