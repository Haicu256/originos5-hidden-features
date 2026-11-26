#!/system/bin/sh
# OriginOS 5 Hidden Features Unlock — Installer script
# Applies verified persistent properties and secure settings without touching /system or /vendor.

ui_print "- OriginOS 5 Hidden Features Unlock (v1.0)"
ui_print "- Applying verified persistent properties..."

# 1. Native Charging Upper Limit (80/85/90/95/100%) + Global Bypass / Disable Charge
setprop persist.vivo.charge_capacity_up_limit_support 1
setprop persist.vivo.battery_charge_limit 1
setprop persist.vivo.all_bypass_charge_support 1
setprop persist.vivo.disable_charge_support 1

# 2. Full / Integration AOD & AOD Music Switch
setprop persist.vivo.phone.smart_aod 1
settings put secure vivo_integration_aod_enable 1 2>/dev/null || true
settings put secure aod_show_music_switch 1 2>/dev/null || true

# 3. Full DC Dimming & Low-Latency Audio
setprop persist.sys.dcdiming.en.vivo 1
setprop persist.vivo.audio.feature.uselowlatency.enable true

# 4. Android 15 Game FPS Override Unlock & Multiwindow Split Animations
setprop persist.graphics.game_default_frame_rate.disabled true
setprop persist.vivo.multiwindow_split_switch_anim 1
setprop persist.vivo.multiwindow_splittofull_anim 1

# Apply ro.* properties immediately if running in live root/late-load session
if [ -f "$MODPATH/apply_props.sh" ]; then
  chmod 0755 "$MODPATH/apply_props.sh" "$MODPATH/post-fs-data.sh" "$MODPATH/late-load.sh" "$MODPATH/uninstall.sh" 2>/dev/null || true
  sh "$MODPATH/apply_props.sh" 2>/dev/null || true
fi

ui_print "- Done! Soft Reboot (Temp Root) or Reboot to apply all changes."
