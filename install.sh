#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ID="niri-layout-indicator"
PLUGIN_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DST="$HOME/.config/noctalia/plugins/$PLUGIN_ID"
PLUGINS_JSON="$HOME/.config/noctalia/plugins.json"

mkdir -p "$HOME/.config/noctalia/plugins"
rm -rf "$PLUGIN_DST"
cp -r "$PLUGIN_SRC" "$PLUGIN_DST"

python3 - "$PLUGINS_JSON" "$PLUGIN_ID" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
plugin_id = sys.argv[2]

if path.exists() and path.read_text().strip():
    data = json.loads(path.read_text())
else:
    data = {}

data[plugin_id] = {
    "enabled": True,
    "sourceUrl": "local"
}

path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
PY

echo "Installed $PLUGIN_ID"
echo "Restart Noctalia, then enable the plugin and add it to the bar."
