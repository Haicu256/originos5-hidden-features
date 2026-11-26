#!/system/bin/sh
# OriginOS 5 Hidden Features Unlock v2.0 — Installer script

ui_print "- OriginOS 5 Hidden Features Unlock (v2.0 + WebUI)"
chmod 0755 "$MODPATH/feature_ctl.sh" "$MODPATH/apply_props.sh" "$MODPATH/post-fs-data.sh" "$MODPATH/late-load.sh" "$MODPATH/uninstall.sh" 2>/dev/null || true

ui_print "- Applying configured features (defaults: all 12 enabled)..."
sh "$MODPATH/feature_ctl.sh" apply

ui_print "- WebUI ready: tap Open in KernelSU / SukiSU / APatch / MMRL to toggle features."
ui_print "- Done! Soft Reboot (Temp Root) or Reboot to apply all changes."
