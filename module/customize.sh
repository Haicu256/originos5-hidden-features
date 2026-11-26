#!/system/bin/sh
# OriginOS 5 Hidden Features Unlock v2.0 — Installer script

ui_print "- OriginOS 5 Hidden Features Unlock (v2.0.1 + WebUI)"
chmod 0755 "$MODPATH/feature_ctl.sh" "$MODPATH/apply_props.sh" "$MODPATH/post-fs-data.sh" "$MODPATH/late-load.sh" "$MODPATH/uninstall.sh" 2>/dev/null || true

# Clean up any legacy non-hardware props from v2.0
setprop persist.vivo.usb_wet_charge_limit_support "" 2>/dev/null || true
setprop persist.vivo.gamecube.hifi.support "" 2>/dev/null || true
if [ -f /data/adb/originos5_hidden_features.conf ]; then
  grep -v '^usb_wet_guard=' /data/adb/originos5_hidden_features.conf > /data/adb/originos5_hidden_features.conf.tmp 2>/dev/null && \
    mv /data/adb/originos5_hidden_features.conf.tmp /data/adb/originos5_hidden_features.conf 2>/dev/null || true
fi

ui_print "- Applying configured features (defaults: all 11 verified enabled)..."
sh "$MODPATH/feature_ctl.sh" apply

ui_print "- WebUI ready: tap Open in KernelSU / SukiSU / APatch / MMRL to toggle features."
ui_print "- Done! Soft Reboot (Temp Root) or Reboot to apply all changes."
