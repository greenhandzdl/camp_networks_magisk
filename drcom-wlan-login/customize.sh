#!/sbin/sh
# ============================================================
# Magisk 模块安装自定义脚本（由 update-binary source 执行）
# 文档: https://topjohnwu.github.io/Magisk/guides.html
#
# 模块更新时模块目录会被整体替换，用户配置必须存放在
# 独立数据目录 /data/adb/<id> 中才不会丢失。
# 此处在安装时把旧版本配置（位于旧模块目录）迁移到数据目录。
# 可用变量: MODPATH / BOOTMODE / MAGISK_VER 等
# ============================================================

MODID=drcom-wlan-login
DATA_DIR=/data/adb/$MODID
OLD_MODDIR=/data/adb/modules/$MODID

ui_print "- 迁移用户配置..."

mkdir -p "$DATA_DIR"

# 数据目录尚无配置，且旧模块目录存在配置 → 迁移
if [ ! -f "$DATA_DIR/config.env" ] && [ -f "$OLD_MODDIR/config.env" ]; then
    cp -f "$OLD_MODDIR/config.env" "$DATA_DIR/config.env"
    ui_print "  已迁移旧配置到 $DATA_DIR/config.env"
fi

# 保护配置读写权限（含账号密码）
[ -f "$DATA_DIR/config.env" ] && chmod 600 "$DATA_DIR/config.env"

# 配置不随 zip 分发，清理可能残留的配置文件
rm -f "$MODPATH/config.env"
