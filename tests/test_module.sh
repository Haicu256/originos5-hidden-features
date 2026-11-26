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

# 2. Check WebUI JavaScript syntax (if node is available)
if command -v node >/dev/null 2>&1; then
  python3 - "$MOD/webroot/index.html" "$TMP/webui.js" <<'PY'
import sys, re
html = open(sys.argv[1]).read()
m = re.search(r"<script>(.*?)</script>", html, re.S)
assert m, "missing <script> block"
open(sys.argv[2], "w").write(m.group(1))
PY
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
  PATH="$TMP/bin:$PATH" O5_CONF_FILE="$TMP/o5.conf" O5_RESETPROP_BIN="$TMP/mock_resetprop" MOCK_LOG="$TMP/ctl.log" sh "$MOD/feature_ctl.sh" "$@"
}

# Test A: apply initializes all 12 enabled and applies key props
: > "$TMP/ctl.log"
run_ctl apply | grep -q "OK:applied"
grep -q "SETPROP persist.vivo.phone.fps_max=144" "$TMP/ctl.log"
grep -q "RESETPROP ro.vivo.user_refresh_rate_mode=true" "$TMP/ctl.log"
grep -q "RESETPROP ro.vivo.touch.game_para_adjust=1" "$TMP/ctl.log"
grep -q "SETPROP persist.vivo.support.five_level_screen_zoom=true" "$TMP/ctl.log"
grep -q "SETPROP persist.vivo.Lea.tws_recording.enable=true" "$TMP/ctl.log"
grep -q "SETPROP persist.vivo.camerap3.support=1" "$TMP/ctl.log"
grep -q "SETPROP persist.vivo.support.appshare=1" "$TMP/ctl.log"
grep -q "SETPROP persist.vivo.feature.super_performance_support=1" "$TMP/ctl.log"
grep -q "SETPROP persist.vivo.multiwindow_force=true" "$TMP/ctl.log"
! grep -q "usb_wet_charge_limit_support" "$TMP/ctl.log"
! grep -q "gamecube.hifi.support" "$TMP/ctl.log"
grep -q "SETPROP persist.sys.dcdiming.en.vivo=1" "$TMP/ctl.log"

# Test B: disabling refresh_144_custom safely restores fps_max=120 (not empty)
: > "$TMP/ctl.log"
run_ctl set refresh_144_custom 0 | grep -q "OK:refresh_144_custom=0"
grep -q "SETPROP persist.vivo.phone.fps_max=120" "$TMP/ctl.log"
grep -q "RESETPROP ro.vivo.user_refresh_rate_mode=false" "$TMP/ctl.log"

# Test C: status reflects toggled state accurately
STATUS_OUT=$(run_ctl status)
echo "$STATUS_OUT" | grep -q "FEAT_refresh_144_custom=0"
echo "$STATUS_OUT" | grep -q "FEAT_charge_limit=1"
echo "$STATUS_OUT" | grep -q "DEVICE_MODEL=V2361A"

# Test D: apply_ro respects disabled refresh_144_custom and only applies enabled ro.*
: > "$TMP/ctl.log"
run_ctl apply_ro
! grep -q "ro.vivo.user_refresh_rate_mode=true" "$TMP/ctl.log"
grep -q "RESETPROP ro.vivo.keyguard_full_aod.enable=1" "$TMP/ctl.log"

# Test E: reset reverts all
: > "$TMP/ctl.log"
run_ctl reset | grep -q "OK:reset"
grep -q "SETPROP persist.vivo.Lea.tws_recording.enable=false" "$TMP/ctl.log"
grep -q "SETPROP persist.sys.dcdiming.en.vivo=0" "$TMP/ctl.log"
grep -q "SETTINGS put secure vivo_integration_aod_enable 0" "$TMP/ctl.log"

# Test F: invalid key rejected
if run_ctl set bad_key 1 >/dev/null 2>&1; then
  echo "FAIL: invalid key accepted"; exit 1
fi

# 4. Verify build.sh produces valid flashable ZIP with webroot/index.html
bash "$ROOT/build.sh" >/dev/null
ZIP="$ROOT/dist/OriginOS5_Hidden_Features_v2.0.1.zip"
[ -f "$ZIP" ]
unzip -l "$ZIP" | grep -q "META-INF/com/google/android/update-binary"
unzip -l "$ZIP" | grep -q "webroot/index.html"
unzip -l "$ZIP" | grep -q "feature_ctl.sh"
unzip -l "$ZIP" | grep -q "late-load.sh"

echo "ALL 6 MODULE & WEBUI TESTS PASSED"
