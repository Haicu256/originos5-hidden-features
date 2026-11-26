#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MOD="$ROOT/module"

# 1. Shell syntax check for every script
for f in "$MOD/apply_props.sh" "$MOD/post-fs-data.sh" "$MOD/late-load.sh" "$MOD/customize.sh" "$MOD/uninstall.sh" "$MOD/META-INF/com/google/android/update-binary"; do
  sh -n "$f"
done

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# 2. Test apply_props.sh with mock resetprop
cat > "$TMP/mock_resetprop" <<'EOF'
#!/bin/sh
echo "RESETPROP $*" >> "$MOCK_LOG"
EOF
chmod +x "$TMP/mock_resetprop"

MOCK_LOG="$TMP/apply.log" O5_RESETPROP_BIN="$TMP/mock_resetprop" sh "$MOD/apply_props.sh"
grep -q "RESETPROP ro.vivo.keyguard_full_aod.enable 1" "$TMP/apply.log"
grep -q "RESETPROP ro.surface_flinger.game_default_frame_rate_override 144" "$TMP/apply.log"

# 3. Test customize.sh & uninstall.sh with mock setprop/settings/ui_print
mkdir -p "$TMP/bin"
cat > "$TMP/bin/setprop" <<'EOF'
#!/bin/sh
echo "SETPROP $*" >> "$MOCK_LOG"
EOF
cat > "$TMP/bin/settings" <<'EOF'
#!/bin/sh
echo "SETTINGS $*" >> "$MOCK_LOG"
EOF
chmod +x "$TMP/bin/setprop" "$TMP/bin/settings"

PATH="$TMP/bin:$PATH" MOCK_LOG="$TMP/install.log" MODPATH="$MOD" O5_RESETPROP_BIN="$TMP/mock_resetprop" \
  sh -c 'ui_print() { echo "$1" >> "$MOCK_LOG"; }; . "'"$MOD/customize.sh"'"'
grep -q "SETPROP persist.vivo.charge_capacity_up_limit_support 1" "$TMP/install.log"
grep -q "SETPROP persist.vivo.all_bypass_charge_support 1" "$TMP/install.log"
grep -q "SETPROP persist.vivo.phone.smart_aod 1" "$TMP/install.log"
grep -q "SETTINGS put secure vivo_integration_aod_enable 1" "$TMP/install.log"
grep -q "RESETPROP ro.vivo.keyguard_full_aod.enable 1" "$TMP/install.log"

PATH="$TMP/bin:$PATH" MOCK_LOG="$TMP/uninstall.log" sh "$MOD/uninstall.sh"
grep -q "SETPROP persist.vivo.charge_capacity_up_limit_support" "$TMP/uninstall.log"
grep -q "SETPROP persist.vivo.audio.feature.uselowlatency.enable false" "$TMP/uninstall.log"
grep -q "SETTINGS put secure vivo_integration_aod_enable 0" "$TMP/uninstall.log"

# 4. Verify build.sh produces valid flashable ZIP
bash "$ROOT/build.sh" >/dev/null
ZIP="$ROOT/dist/OriginOS5_Hidden_Features_v1.0.zip"
[ -f "$ZIP" ]
unzip -l "$ZIP" | grep -q "META-INF/com/google/android/update-binary"
unzip -l "$ZIP" | grep -q "module.prop"
unzip -l "$ZIP" | grep -q "late-load.sh"

echo "ALL 4 MODULE TESTS PASSED"
