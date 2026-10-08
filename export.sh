#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T3_SRC="${T3_USERDATA:-$HOME/.t3/userdata}"
CURSOR_SRC="${CURSOR_HOME:-$HOME/.cursor}"

copy_file() {
  local src="$1"
  local dest="$2"
  if [[ ! -f "$src" ]]; then
    echo "missing $src" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "exported $dest"
}

# Snapshot published color themes. The filename is the theme id. Symlinks and
# files over the server's 32KB limit are skipped, matching what T3 will serve.
export_themes() {
  local src_dir="$1"
  local dest_dir="$2"
  local tmp copied=0 f base size
  mkdir -p "$dest_dir"
  tmp="$(mktemp -d)"
  if [[ -d "$src_dir" ]]; then
    shopt -s nullglob
    for f in "$src_dir"/*.json; do
      if [[ -L "$f" ]]; then
        echo "skipped symlink $f" >&2
        continue
      fi
      base="$(basename "$f")"
      size="$(stat -c%s "$f")"
      if (( size > 32768 )); then
        echo "skipped oversized theme $f" >&2
        continue
      fi
      cp "$f" "$tmp/$base"
    done
    shopt -u nullglob
  fi
  shopt -s nullglob
  for f in "$dest_dir"/*.json; do
    rm "$f"
  done
  for f in "$tmp"/*.json; do
    base="$(basename "$f")"
    cp "$f" "$dest_dir/$base"
    echo "exported $dest_dir/$base"
    copied=$((copied + 1))
  done
  shopt -u nullglob
  rm -rf "$tmp"
  if (( copied == 0 )); then
    echo "no published themes in $src_dir"
  fi
}

copy_file "$T3_SRC/settings.json" "$ROOT/userdata/settings.json"
copy_file "$T3_SRC/keybindings.json" "$ROOT/userdata/keybindings.json"
copy_file "$T3_SRC/client-settings.json" "$ROOT/userdata/client-settings.json"
export_themes "$T3_SRC/themes" "$ROOT/userdata/themes"
copy_file "$CURSOR_SRC/mcp.json" "$ROOT/cursor/mcp.json"

python3 - "$CURSOR_SRC/cli-config.json" "$ROOT/cursor/cli-config.json" <<'PY'
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dest = Path(sys.argv[2])
if not src.is_file():
    raise SystemExit(f"missing {src}")
data = json.loads(src.read_text())
data.pop("authInfo", None)
dest.parent.mkdir(parents=True, exist_ok=True)
dest.write_text(json.dumps(data, indent=2) + "\n")
print(f"exported {dest} (login details omitted)")
PY
