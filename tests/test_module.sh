#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MOD="$ROOT/module"

# 1. Shell syntax check for every script
for f in "$MOD/feature_ctl.sh" "$MOD/apply_props.sh" "$MOD/post-fs-data.sh" "$MOD/late-load.sh" "$MOD/customize.sh" "$MOD/uninstall.sh" "$MOD/META-INF/com/google/android/update-binary"; do
  sh -n "$f"
done

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# 2. Check WebUI JavaScript syntax & verify every feature key in index.html matches ALL_KEYS and has loc
python3 - "$MOD/webroot/index.html" "$MOD/feature_ctl.sh" "$TMP/webui.js" <<'PY'
import sys, re
html = open(sys.argv[1]).read()
ctl = open(sys.argv[2]).read()
m = re.search(r"<script>(.*?)</script>", html, re.S)
assert m, "missing <script> block"
js = m.group(1)
open(sys.argv[3], "w").write(js)

m_keys = re.search(r'^ALL_KEYS="([^"]+)"', ctl, re.M)
assert m_keys, "missing ALL_KEYS"
ctl_keys = m_keys.group(1).split()
ui_keys = re.findall(r'\{\s*key:\s*"([^"]+)"', js)
ui_locs = re.findall(r'loc:\s*"([^"]+)"', js)
assert ctl_keys == ui_keys, f"Key mismatch! ctl={ctl_keys} ui={ui_keys}"
assert len(ui_keys) == 19, f"Expected 19 keys, got {len(ui_keys)}"
assert len(ui_locs) == 19, f"Expected 19 loc entries, got {len(ui_locs)}"
assert "Khóa nút gạt do cài module gamecube_z9(CN)" in js, "missing lock reason string"
PY
if command -v node >/dev/null 2>&1; then
  node --check "$TMP/webui.js"
fi

# 3. Mock environment for feature_ctl.sh
mkdir -p "$TMP/bin"
cat > "$TMP/bin/setprop" <<'EOF'
#!/bin/sh
echo "SETPROP $1=$2" >> "$MOCK_LOG"
EOF
cat > "$TMP/bin/getprop" <<'EOF'
#!/bin/sh
case "$1" in
  ro.product.model) echo "V2361A" ;;
  ro.vivo.os.build.display.id) echo "OriginOS 5" ;;
  persist.vivo.phone.fps_max) echo "144" ;;
  persist.vivo.charge_capacity_up_limit_support) echo "1" ;;
  persist.sys.dcdiming.en.vivo) echo "1" ;;
  *) echo "" ;;
esac
EOF
cat > "$TMP/bin/settings" <<'EOF'
#!/bin/sh
echo "SETTINGS $*" >> "$MOCK_LOG"
EOF
cat > "$TMP/mock_resetprop" <<'EOF'
#!/bin/sh
echo "RESETPROP $1=$2" >> "$MOCK_LOG"
EOF
chmod +x "$TMP/bin/setprop" "$TMP/bin/getprop" "$TMP/bin/settings" "$TMP/mock_resetprop"

run_ctl() {
  PATH="$TMP/bin:$PATH" O5_CONF_FILE="$TMP/o5.conf" O5_GC_MOD_DIR="$TMP/no_gc_mod" O5_GC_CONF_FILE="$TMP/no_gc.conf" O5_RESETPROP_BIN="$TMP/mock_resetprop" MOCK_LOG="$TMP/ctl.log" sh "$MOD/feature_ctl.sh" "$@"
}

# Test A: apply initializes 18 enabled and game_pic_stability OFF by default
: > "$TMP/ctl.log"
run_ctl apply | grep -q "OK:applied"
grep -q "SETPROP persist.vivo.phone.fps_max=144" "$TMP/ctl.log"
grep -q "RESETPROP ro.vivo.user_refresh_rate_mode=true" "$TMP/ctl.log"
grep -q "RESETPROP ro.vivo.touch.game_para_adjust=1" "$TMP/ctl.log"
grep -q "SETPROP persist.vivo.support.picture_stability_opt=$" "$TMP/ctl.log"
grep -q "SETPROP persist.vivo.support.five_level_screen_zoom=true" "$TMP/ctl.log"
grep -q "SETPROP persist.vivo.Lea.tws_recording.enable=true" "$TMP/ctl.log"
grep -q "SETPROP persist.vivo.camerap3.support=1" "$TMP/ctl.log"
grep -q "SETPROP persist.vivo.support.appshare=1" "$TMP/ctl.log"
grep -q "SETPROP persist.vivo.feature.super_performance_support=1" "$TMP/ctl.log"
grep -q "SETPROP persist.vivo.multiwindow_force=true" "$TMP/ctl.log"
grep -q "RESETPROP ro.vivo.support.airpods=true" "$TMP/ctl.log"
! grep -q "usb_wet_charge_limit_support" "$TMP/ctl.log"
! grep -q "gamecube.hifi.support" "$TMP/ctl.log"
grep -q "SETPROP persist.sys.dcdiming.en.vivo=1" "$TMP/ctl.log"

# Test B: status shows game_pic_stability=0 by default and GC_MOD_PRESENT=0
STATUS_DEF=$(run_ctl status)
echo "$STATUS_DEF" | grep -q "GC_MOD_PRESENT=0"
echo "$STATUS_DEF" | grep -q "FEAT_game_pic_stability=0"
echo "$STATUS_DEF" | grep -q "FEAT_game_touch_pro=1"

# Test C: toggling one feature in a former pair leaves its sibling untouched
: > "$TMP/ctl.log"
run_ctl set airpods_support 0 | grep -q "OK:airpods_support=0"
grep -q "RESETPROP ro.vivo.support.airpods=false" "$TMP/ctl.log"
! grep -q "uselowlatency" "$TMP/ctl.log"

# Test D: disabling fps_144 restores fps_max=120 without touching per_app_hz
: > "$TMP/ctl.log"
run_ctl set fps_144 0 | grep -q "OK:fps_144=0"
grep -q "SETPROP persist.vivo.phone.fps_max=120" "$TMP/ctl.log"
! grep -q "ro.vivo.user_refresh_rate_mode" "$TMP/ctl.log"

# Test E: when gamecube_z9_cn module is active, lock game_touch_pro & game_pic_stability and mirror its config
mkdir -p "$TMP/gc_mod"
cat > "$TMP/gc.conf" <<'EOF'
ENABLE_TOUCH_PRO=1
ENABLE_PIC_STABILITY=0
EOF
run_ctl_gc() {
  PATH="$TMP/bin:$PATH" O5_CONF_FILE="$TMP/o5_gc.conf" O5_GC_MOD_DIR="$TMP/gc_mod" O5_GC_CONF_FILE="$TMP/gc.conf" O5_RESETPROP_BIN="$TMP/mock_resetprop" MOCK_LOG="$TMP/gc_ctl.log" sh "$MOD/feature_ctl.sh" "$@"
}
GC_ST=$(run_ctl_gc status)
echo "$GC_ST" | grep -q "GC_MOD_PRESENT=1"
echo "$GC_ST" | grep -q "FEAT_game_touch_pro=1"
echo "$GC_ST" | grep -q "FEAT_game_pic_stability=0"
# Mirror flip in gamecube_z9.conf
printf 'ENABLE_TOUCH_PRO=0\nENABLE_PIC_STABILITY=1\n' > "$TMP/gc.conf"
GC_ST2=$(run_ctl_gc status)
echo "$GC_ST2" | grep -q "FEAT_game_touch_pro=0"
echo "$GC_ST2" | grep -q "FEAT_game_pic_stability=1"
# Reject manual set on locked keys
if run_ctl_gc set game_pic_stability 0 >/dev/null 2>&1; then
  echo "FAIL: locked game_pic_stability accepted"; exit 1
fi
if run_ctl_gc set game_touch_pro 1 >/dev/null 2>&1; then
  echo "FAIL: locked game_touch_pro accepted"; exit 1
fi
# apply & enable_all must NOT touch locked props
: > "$TMP/gc_ctl.log"
run_ctl_gc apply | grep -q "OK:applied"
run_ctl_gc enable_all | grep -q "OK:all_enabled"
! grep -q "picture_stability_opt" "$TMP/gc_ctl.log"
! grep -q "game_para_adjust" "$TMP/gc_ctl.log"
# Disabling gamecube_z9_cn unlocks controls cleanly
touch "$TMP/gc_mod/disable"
run_ctl_gc status | grep -q "GC_MOD_PRESENT=0"
run_ctl_gc set game_pic_stability 1 | grep -q "OK:game_pic_stability=1"

# Test F: migration from v2.0.1 grouped config preserves 0 values and keeps game_pic_stability default 0
cat > "$TMP/mig.conf" <<'EOF'
charge_limit=1
bypass_charge=0
refresh_144_custom=0
full_aod=1
camera_pro=0
usb_wet_guard=1
EOF
MIG_OUT=$(PATH="$TMP/bin:$PATH" O5_CONF_FILE="$TMP/mig.conf" O5_GC_MOD_DIR="$TMP/no_gc_mod" O5_RESETPROP_BIN="$TMP/mock_resetprop" MOCK_LOG="$TMP/mig.log" sh "$MOD/feature_ctl.sh" status)
echo "$MIG_OUT" | grep -q "FEAT_fps_144=0"
echo "$MIG_OUT" | grep -q "FEAT_per_app_hz=0"
echo "$MIG_OUT" | grep -q "FEAT_disable_charge=0"
echo "$MIG_OUT" | grep -q "FEAT_camera_tws_mic=0"
echo "$MIG_OUT" | grep -q "FEAT_camera_p3=0"
echo "$MIG_OUT" | grep -q "FEAT_aod_music=1"
echo "$MIG_OUT" | grep -q "FEAT_game_pic_stability=0"
! grep -q "refresh_144_custom=" "$TMP/mig.conf"
! grep -q "usb_wet_guard=" "$TMP/mig.conf"

# Test G: reset reverts all
: > "$TMP/ctl.log"
run_ctl reset | grep -q "OK:reset"
grep -q "SETPROP persist.vivo.Lea.tws_recording.enable=false" "$TMP/ctl.log"
grep -q "SETPROP persist.sys.dcdiming.en.vivo=0" "$TMP/ctl.log"
grep -q "SETTINGS put secure vivo_integration_aod_enable 0" "$TMP/ctl.log"
grep -q "SETTINGS put secure aod_show_music_switch 0" "$TMP/ctl.log"

# Test H: invalid key rejected
if run_ctl set bad_key 1 >/dev/null 2>&1; then
  echo "FAIL: invalid key accepted"; exit 1
fi

# 4. Verify build.sh produces valid flashable ZIP with webroot/index.html
bash "$ROOT/build.sh" >/dev/null
ZIP="$ROOT/dist/OriginOS5_Hidden_Features_v2.2.0.zip"
[ -f "$ZIP" ]
unzip -l "$ZIP" | grep -q "META-INF/com/google/android/update-binary"
unzip -l "$ZIP" | grep -q "webroot/index.html"
unzip -l "$ZIP" | grep -q "feature_ctl.sh"
unzip -l "$ZIP" | grep -q "late-load.sh"

echo "ALL 10 MODULE, GC-SYNC, MIGRATION & WEBUI TESTS PASSED"
