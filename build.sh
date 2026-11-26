#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
VERSION="$(grep '^version=' "$ROOT/module/module.prop" | cut -d= -f2-)"
OUT_DIR="$ROOT/dist"
OUT_ZIP="$OUT_DIR/OriginOS5_Hidden_Features_${VERSION}.zip"

mkdir -p "$OUT_DIR"
rm -f "$OUT_ZIP"

(
  cd "$ROOT/module"
  zip -r9 "$OUT_ZIP" . -x '*.DS_Store'
)

echo "Built: $OUT_ZIP"
sha256sum "$OUT_ZIP"
