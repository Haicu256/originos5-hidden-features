#!/system/bin/sh
# Cleanly revert all persistent properties and secure settings on module uninstall.

setprop persist.vivo.charge_capacity_up_limit_support ""
setprop persist.vivo.all_bypass_charge_support ""
setprop persist.vivo.disable_charge_support ""
setprop persist.vivo.phone.smart_aod ""
setprop persist.sys.dcdiming.en.vivo 0
setprop persist.vivo.audio.feature.uselowlatency.enable false
setprop persist.graphics.game_default_frame_rate.disabled ""
setprop persist.vivo.multiwindow_split_switch_anim ""
setprop persist.vivo.multiwindow_splittofull_anim ""

settings put secure vivo_integration_aod_enable 0 2>/dev/null || true
settings put secure aod_show_music_switch 0 2>/dev/null || true
settings put secure vivo_dc_dimming_pwm_saved_state 0 2>/dev/null || true
exit 0
