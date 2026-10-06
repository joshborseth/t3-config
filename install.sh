#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T3_DEST="${T3_USERDATA:-$HOME/.t3/userdata}"
CURSOR_DEST="${CURSOR_HOME:-$HOME/.cursor}"
stamp="$(date +%Y%m%d-%H%M%S)"

install_file() {
  local src="$1"
  local dest="$2"
  if [[ ! -f "$src" ]]; then
    echo "missing $src" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$dest")"
  if [[ -f "$dest" ]]; then
    cp "$dest" "$dest.bak-$stamp"
    echo "backed up $dest"
  fi
  cp "$src" "$dest"
  echo "installed $dest"
}

install_file "$ROOT/userdata/settings.json" "$T3_DEST/settings.json"
install_file "$ROOT/userdata/keybindings.json" "$T3_DEST/keybindings.json"
install_file "$ROOT/userdata/client-settings.json" "$T3_DEST/client-settings.json"
install_file "$ROOT/cursor/mcp.json" "$CURSOR_DEST/mcp.json"

python3 - "$ROOT/cursor/cli-config.json" "$CURSOR_DEST/cli-config.json" "$stamp" <<'PY'
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dest = Path(sys.argv[2])
stamp = sys.argv[3]
incoming = json.loads(src.read_text())
incoming.pop("authInfo", None)
dest.parent.mkdir(parents=True, exist_ok=True)
if dest.is_file():
    backup = dest.with_name(dest.name + f".bak-{stamp}")
    backup.write_bytes(dest.read_bytes())
    print(f"backed up {dest}")
    existing = json.loads(dest.read_text())
    if "authInfo" in existing:
        incoming["authInfo"] = existing["authInfo"]
dest.write_text(json.dumps(incoming, indent=2) + "\n")
print(f"installed {dest}")
PY

echo "Restart T3 Code so it reloads these settings."
