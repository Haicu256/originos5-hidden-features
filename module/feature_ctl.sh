#!/system/bin/sh
# OriginOS 5 Hidden Features Unlock — Single-source-of-truth feature controller (v2.2.0)
# 19 independent hardware-verified toggles. Auto-defers touch/picture-stability to gamecube_z9_cn when installed.

CONF="${O5_CONF_FILE:-/data/adb/originos5_hidden_features.conf}"
GC_MOD_DIR="${O5_GC_MOD_DIR:-/data/adb/modules/gamecube_z9_cn}"
GC_CONF_FILE="${O5_GC_CONF_FILE:-/data/adb/gamecube_z9.conf}"
ALL_KEYS="charge_limit bypass_charge disable_charge fps_144 per_app_hz full_aod aod_music dc_dimming five_level_zoom game_touch_pro game_pic_stability camera_tws_mic camera_p3 low_latency_audio airpods_support multiwindow_force multiwindow_anim app_share extreme_perf"
RO_KEYS="fps_144 per_app_hz full_aod game_touch_pro airpods_support"

run_resetprop() {
  if [ -n "${O5_RESETPROP_BIN:-}" ] && [ -x "$O5_RESETPROP_BIN" ]; then
    "$O5_RESETPROP_BIN" "$@"
    return $?
  fi
  for _rk in /data/adb/ksu/bin/ksud /data/adb/ksud; do
    if [ -x "$_rk" ]; then
      "$_rk" resetprop "$@"
      return $?
    fi
  done
  if command -v ksud >/dev/null 2>&1; then
    ksud resetprop "$@"
    return $?
  fi
  if command -v resetprop >/dev/null 2>&1; then
    resetprop "$@"
    return $?
  fi
  return 0
}

run_setprop() {
  setprop "$1" "$2" 2>/dev/null || run_resetprop "$1" "$2" 2>/dev/null || true
}

run_settings() {
  settings put "$@" 2>/dev/null || true
}

gc_mod_active() {
  [ -d "$GC_MOD_DIR" ] && [ ! -f "$GC_MOD_DIR/disable" ] && [ ! -f "$GC_MOD_DIR/remove" ]
}

gc_get_val() {
  _gk="$1"
  _gdef="$2"
  if [ -f "$GC_CONF_FILE" ]; then
    _gv2=$(grep "^${_gk}=" "$GC_CONF_FILE" 2>/dev/null | tail -n 1 | cut -d= -f2)
    if [ "$_gv2" = "0" ] || [ "$_gv2" = "1" ]; then
      echo "$_gv2"
      return 0
    fi
  fi
  echo "$_gdef"
}

is_gc_locked_key() {
  gc_mod_active || return 1
  case "$1" in
    game_touch_pro|game_pic_stability) return 0 ;;
    *) return 1 ;;
  esac
}

default_val_of() {
  case "$1" in
    game_pic_stability) echo "0" ;;
    *) echo "1" ;;
  esac
}

legacy_parent_of() {
  case "$1" in
    disable_charge) echo "bypass_charge" ;;
    fps_144|per_app_hz) echo "refresh_144_custom" ;;
    aod_music) echo "full_aod" ;;
    game_touch_pro) echo "game_pro" ;;
    camera_tws_mic|camera_p3) echo "camera_pro" ;;
    airpods_support) echo "low_latency_audio" ;;
    multiwindow_force|multiwindow_anim) echo "multiwindow_pro" ;;
    app_share|extreme_perf) echo "app_share_extreme" ;;
    *) echo "" ;;
  esac
}

ensure_conf() {
  if [ ! -f "$CONF" ]; then
    mkdir -p "$(dirname "$CONF")" 2>/dev/null || true
    : > "$CONF"
    for _ek in $ALL_KEYS; do
      echo "${_ek}=$(default_val_of "$_ek")" >> "$CONF"
    done
  else
    _migrated=0
    for _ek in $ALL_KEYS; do
      if ! grep -q "^${_ek}=" "$CONF" 2>/dev/null; then
        _def=$(default_val_of "$_ek")
        _lp=$(legacy_parent_of "$_ek")
        if [ -n "$_lp" ]; then
          _lv=$(grep "^${_lp}=" "$CONF" 2>/dev/null | tail -n 1 | cut -d= -f2)
          [ "$_lv" = "0" ] && _def="0"
        fi
        echo "${_ek}=${_def}" >> "$CONF"
        _migrated=1
      fi
    done
    # Remove obsolete v2.0 grouped keys after migration
    if [ "$_migrated" = "1" ] || grep -Eq '^(refresh_144_custom|game_pro|camera_pro|multiwindow_pro|app_share_extreme|usb_wet_guard)=' "$CONF" 2>/dev/null; then
      _mtmp="${CONF}.mig.$$"
      grep -Ev '^(refresh_144_custom|game_pro|camera_pro|multiwindow_pro|app_share_extreme|usb_wet_guard)=' "$CONF" 2>/dev/null > "$_mtmp" || true
      mv "$_mtmp" "$CONF"
    fi
  fi
}

get_conf() {
  ensure_conf
  if gc_mod_active; then
    case "$1" in
      game_touch_pro)
        gc_get_val ENABLE_TOUCH_PRO 1
        return 0
        ;;
      game_pic_stability)
        gc_get_val ENABLE_PIC_STABILITY 0
        return 0
        ;;
    esac
  fi
  _gv=$(grep "^${1}=" "$CONF" 2>/dev/null | tail -n 1 | cut -d= -f2)
  if [ "$_gv" = "0" ]; then
    echo "0"
  elif [ "$_gv" = "1" ]; then
    echo "1"
  else
    default_val_of "$1"
  fi
}

set_conf() {
  _sk="$1"
  _sv="$2"
  ensure_conf
  _tmp="${CONF}.tmp.$$"
  grep -v "^${_sk}=" "$CONF" 2>/dev/null > "$_tmp" || true
  echo "${_sk}=${_sv}" >> "$_tmp"
  mv "$_tmp" "$CONF"
}

is_valid_key() {
  for _vk in $ALL_KEYS; do
    [ "$_vk" = "$1" ] && return 0
  done
  return 1
}

apply_one_ro() {
  key="$1"
  val="$2"
  is_gc_locked_key "$key" && return 0
  case "$key" in
    fps_144)
      if [ "$val" = "1" ]; then
        run_resetprop ro.surface_flinger.game_default_frame_rate_override 144
      else
        run_resetprop ro.surface_flinger.game_default_frame_rate_override 60
      fi
      ;;
    per_app_hz)
      if [ "$val" = "1" ]; then
        run_resetprop ro.vivo.user_refresh_rate_mode true
      else
        run_resetprop ro.vivo.user_refresh_rate_mode false
      fi
      ;;
    full_aod)
      if [ "$val" = "1" ]; then
        run_resetprop ro.vivo.keyguard_full_aod.enable 1
      else
        run_resetprop ro.vivo.keyguard_full_aod.enable 0
      fi
      ;;
    game_touch_pro)
      if [ "$val" = "1" ]; then
        run_resetprop ro.vivo.touch.game_para_adjust 1
      else
        run_resetprop ro.vivo.touch.game_para_adjust 0
      fi
      ;;
    airpods_support)
      if [ "$val" = "1" ]; then
        run_resetprop ro.vivo.support.airpods true
      else
        run_resetprop ro.vivo.support.airpods false
      fi
      ;;
  esac
}

apply_one() {
  key="$1"
  val="$2"
  is_gc_locked_key "$key" && return 0
  case "$key" in
    charge_limit)
      if [ "$val" = "1" ]; then
        run_setprop persist.vivo.charge_capacity_up_limit_support 1
        run_setprop persist.vivo.battery_charge_limit 1
      else
        run_setprop persist.vivo.charge_capacity_up_limit_support ""
      fi
      ;;
    bypass_charge)
      if [ "$val" = "1" ]; then
        run_setprop persist.vivo.all_bypass_charge_support 1
      else
        run_setprop persist.vivo.all_bypass_charge_support ""
      fi
      ;;
    disable_charge)
      if [ "$val" = "1" ]; then
        run_setprop persist.vivo.disable_charge_support 1
      else
        run_setprop persist.vivo.disable_charge_support ""
      fi
      ;;
    fps_144)
      if [ "$val" = "1" ]; then
        run_setprop persist.vivo.phone.fps_max 144
        run_setprop persist.graphics.game_default_frame_rate.disabled true
      else
        run_setprop persist.vivo.phone.fps_max 120
        run_setprop persist.graphics.game_default_frame_rate.disabled ""
      fi
      apply_one_ro "$key" "$val"
      ;;
    per_app_hz)
      apply_one_ro "$key" "$val"
      ;;
    full_aod)
      if [ "$val" = "1" ]; then
        run_setprop persist.vivo.phone.smart_aod 1
        run_settings secure vivo_integration_aod_enable 1
      else
        run_setprop persist.vivo.phone.smart_aod ""
        run_settings secure vivo_integration_aod_enable 0
      fi
      apply_one_ro "$key" "$val"
      ;;
    aod_music)
      if [ "$val" = "1" ]; then
        run_settings secure aod_show_music_switch 1
      else
        run_settings secure aod_show_music_switch 0
      fi
      ;;
    dc_dimming)
      if [ "$val" = "1" ]; then
        run_setprop persist.sys.dcdiming.en.vivo 1
      else
        run_setprop persist.sys.dcdiming.en.vivo 0
        run_settings secure vivo_dc_dimming_pwm_saved_state 0
      fi
      ;;
    five_level_zoom)
      if [ "$val" = "1" ]; then
        run_setprop persist.vivo.support.five_level_screen_zoom true
      else
        run_setprop persist.vivo.support.five_level_screen_zoom ""
      fi
      ;;
    game_touch_pro)
      apply_one_ro "$key" "$val"
      ;;
    game_pic_stability)
      if [ "$val" = "1" ]; then
        run_setprop persist.vivo.support.picture_stability_opt true
      else
        run_setprop persist.vivo.support.picture_stability_opt ""
      fi
      ;;
    camera_tws_mic)
      if [ "$val" = "1" ]; then
        run_setprop persist.vivo.Lea.tws_recording.enable true
      else
        run_setprop persist.vivo.Lea.tws_recording.enable false
      fi
      ;;
    camera_p3)
      if [ "$val" = "1" ]; then
        run_setprop persist.vivo.camerap3.support 1
      else
        run_setprop persist.vivo.camerap3.support ""
      fi
      ;;
    low_latency_audio)
      if [ "$val" = "1" ]; then
        run_setprop persist.vivo.audio.feature.uselowlatency.enable true
      else
        run_setprop persist.vivo.audio.feature.uselowlatency.enable false
      fi
      ;;
    airpods_support)
      apply_one_ro "$key" "$val"
      ;;
    multiwindow_force)
      if [ "$val" = "1" ]; then
        run_setprop persist.vivo.multiwindow_force true
        run_setprop persist.vivo.multiwindow_rotatevalid true
      else
        run_setprop persist.vivo.multiwindow_force ""
        run_setprop persist.vivo.multiwindow_rotatevalid ""
      fi
      ;;
    multiwindow_anim)
      if [ "$val" = "1" ]; then
        run_setprop persist.vivo.multiwindow_split_switch_anim 1
        run_setprop persist.vivo.multiwindow_splittofull_anim 1
      else
        run_setprop persist.vivo.multiwindow_split_switch_anim ""
        run_setprop persist.vivo.multiwindow_splittofull_anim ""
      fi
      ;;
    app_share)
      if [ "$val" = "1" ]; then
        run_setprop persist.vivo.support.appshare 1
      else
        run_setprop persist.vivo.support.appshare ""
      fi
      ;;
    extreme_perf)
      if [ "$val" = "1" ]; then
        run_setprop persist.vivo.feature.super_performance_support 1
      else
        run_setprop persist.vivo.feature.super_performance_support ""
      fi
      ;;
  esac
}

cmd="${1:-status}"
case "$cmd" in
  status)
    ensure_conf
    echo "DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null || echo unknown)"
    echo "OS_DISPLAY=$(getprop ro.vivo.os.build.display.id 2>/dev/null || echo OriginOS)"
    echo "LIVE_FPS_MAX=$(getprop persist.vivo.phone.fps_max 2>/dev/null || echo '')"
    echo "LIVE_CHARGE_LIMIT=$(getprop persist.vivo.charge_capacity_up_limit_support 2>/dev/null || echo '')"
    echo "LIVE_DC_DIM=$(getprop persist.sys.dcdiming.en.vivo 2>/dev/null || echo '')"
    if gc_mod_active; then
      echo "GC_MOD_PRESENT=1"
    else
      echo "GC_MOD_PRESENT=0"
    fi
    for k in $ALL_KEYS; do
      echo "FEAT_${k}=$(get_conf "$k")"
    done
    ;;
  set)
    key="${2:-}"
    val="${3:-}"
    is_valid_key "$key" || { echo "ERR: invalid key $key" >&2; exit 2; }
    [ "$val" = "0" ] || [ "$val" = "1" ] || { echo "ERR: invalid value $val" >&2; exit 2; }
    if is_gc_locked_key "$key"; then
      echo "ERR: locked by gamecube_z9(CN)" >&2
      exit 3
    fi
    set_conf "$key" "$val"
    apply_one "$key" "$val"
    echo "OK:${key}=${val}"
    ;;
  apply)
    ensure_conf
    for k in $ALL_KEYS; do
      is_gc_locked_key "$k" && continue
      v=$(get_conf "$k")
      apply_one "$k" "$v"
    done
    echo "OK:applied"
    ;;
  apply_ro)
    ensure_conf
    for k in $RO_KEYS; do
      is_gc_locked_key "$k" && continue
      v=$(get_conf "$k")
      if [ "$v" = "1" ]; then
        apply_one_ro "$k" 1
      fi
    done
    ;;
  enable_all)
    for k in $ALL_KEYS; do
      is_gc_locked_key "$k" && continue
      set_conf "$k" 1
      apply_one "$k" 1
    done
    echo "OK:all_enabled"
    ;;
  reset)
    for k in $ALL_KEYS; do
      is_gc_locked_key "$k" && continue
      set_conf "$k" 0
      apply_one "$k" 0
    done
    echo "OK:reset"
    ;;
  *)
    echo "Usage: $0 {status|set <key> <0|1>|apply|apply_ro|enable_all|reset}" >&2
    exit 1
    ;;
esac
exit 0
