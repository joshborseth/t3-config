#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${T3_USERDATA:-$HOME/.t3/userdata}"
stamp="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$DEST"

for file in settings.json keybindings.json; do
  src="$ROOT/userdata/$file"
  dest="$DEST/$file"
  if [[ ! -f "$src" ]]; then
    echo "missing $src" >&2
    exit 1
  fi
  if [[ -f "$dest" ]]; then
    cp "$dest" "$dest.bak-$stamp"
    echo "backed up $dest"
  fi
  cp "$src" "$dest"
  echo "installed $file -> $dest"
done

echo "Restart T3 Code so it reloads these settings."
