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

copy_file "$T3_SRC/settings.json" "$ROOT/userdata/settings.json"
copy_file "$T3_SRC/keybindings.json" "$ROOT/userdata/keybindings.json"
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
