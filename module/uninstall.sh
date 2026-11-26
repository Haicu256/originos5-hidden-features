#!/system/bin/sh
MODDIR="${0%/*}"
sh "$MODDIR/feature_ctl.sh" reset
rm -f /data/adb/originos5_hidden_features.conf
exit 0
