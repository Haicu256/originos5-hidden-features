#!/system/bin/sh
MODDIR="${0%/*}"
sh "$MODDIR/feature_ctl.sh" apply_ro
exit 0
