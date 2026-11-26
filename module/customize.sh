#!/system/bin/sh
# OriginOS 5 Hidden Features Unlock v2.1.0 — Installer script

ui_print "- OriginOS 5 Hidden Features Unlock (v2.1.0 + WebUI)"
chmod 0755 "$MODPATH/feature_ctl.sh" "$MODPATH/apply_props.sh" "$MODPATH/post-fs-data.sh" "$MODPATH/late-load.sh" "$MODPATH/uninstall.sh" 2>/dev/null || true

# Clean up any legacy non-hardware props from v2.0
setprop persist.vivo.usb_wet_charge_limit_support "" 2>/dev/null || true
setprop persist.vivo.gamecube.hifi.support "" 2>/dev/null || true

ui_print "- Applying configured features (19 independent toggles; migrates v2.0 config automatically)..."
sh "$MODPATH/feature_ctl.sh" apply

ui_print "- WebUI ready: tap Open in KernelSU / SukiSU / APatch / MMRL to toggle each feature."
ui_print "- Done! Soft Reboot (Temp Root) or Reboot to apply all changes."
