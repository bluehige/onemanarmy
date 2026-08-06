#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
BUILD_DIR="$ROOT/build/web"

cd "$ROOT"

python3 tools/mobile_web/prepare_export.py

"$GODOT_BIN" --headless --path "$ROOT" --editor --quit

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
"$GODOT_BIN" --headless --path "$ROOT" \
  --export-release "Web Mobile" "$BUILD_DIR/index.html"

python3 tools/mobile_web/postprocess_export.py

INDEX="$BUILD_DIR/index.html"
test -s "$INDEX"
test -n "$(find "$BUILD_DIR" -maxdepth 1 -type f -name '*.wasm' -size +0c -print -quit)"
test -n "$(find "$BUILD_DIR" -maxdepth 1 -type f -name '*.pck' -size +0c -print -quit)"
grep -q 'mobile-rotate-notice' "$INDEX"
grep -q 'touch-action: none' "$INDEX"

echo "MOBILE_WEB_BUILD_OK"
du -sh "$BUILD_DIR"
find "$BUILD_DIR" -maxdepth 1 -type f -printf '%f %s bytes\n' | sort
