#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${T3_USERDATA:-$HOME/.t3/userdata}"

mkdir -p "$ROOT/userdata"

for file in settings.json keybindings.json; do
  src="$SRC/$file"
  if [[ ! -f "$src" ]]; then
    echo "missing $src" >&2
    exit 1
  fi
  cp "$src" "$ROOT/userdata/$file"
  echo "exported $file"
done
