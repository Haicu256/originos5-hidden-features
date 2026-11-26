#!/system/bin/sh
# Shared ro.* resetprop applier for KernelSU (late-load & post-fs-data), SukiSU, APatch, and Magisk.

run_resetprop() {
  if [ -n "${O5_RESETPROP_BIN:-}" ] && [ -x "$O5_RESETPROP_BIN" ]; then
    "$O5_RESETPROP_BIN" "$@"
    return $?
  fi
  for k in /data/adb/ksu/bin/ksud /data/adb/ksud; do
    if [ -x "$k" ]; then
      "$k" resetprop "$@"
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

run_resetprop ro.vivo.keyguard_full_aod.enable 1
run_resetprop ro.surface_flinger.game_default_frame_rate_override 144
exit 0
