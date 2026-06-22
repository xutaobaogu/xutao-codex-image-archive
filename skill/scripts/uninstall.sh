#!/usr/bin/env zsh
set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CONFIG="$CODEX_HOME/config.toml"
ARCHIVE_ROOT="${CODEX_IMAGE_ARCHIVE_ROOT:-$CODEX_HOME/chat-image-archive}"
ORIGINAL_NOTIFY_JSON="$ARCHIVE_ROOT/original-notify.json"

if [ ! -f "$CONFIG" ]; then
  echo "Codex config not found: $CONFIG" >&2
  exit 1
fi

python3 - "$CONFIG" "$ORIGINAL_NOTIFY_JSON" <<'PY'
import json
import sys
from pathlib import Path

config = Path(sys.argv[1]).expanduser()
original_notify_json = Path(sys.argv[2]).expanduser()

if not original_notify_json.exists():
    raise SystemExit("Saved original notify not found; restore from a config.toml.bak.image-archive.* backup manually.")

payload = json.loads(original_notify_json.read_text(encoding="utf-8"))
notify = payload.get("notify")
if not isinstance(notify, list):
    raise SystemExit("Saved original notify is invalid.")

replacement = "notify = " + json.dumps(notify, ensure_ascii=False)
lines = config.read_text(encoding="utf-8").splitlines()
for index, line in enumerate(lines):
    if line.startswith("notify = "):
        lines[index] = replacement
        break
else:
    lines.insert(0, replacement)
config.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

echo "Restored original notify in $CONFIG"
echo "Archived images were left untouched at $ARCHIVE_ROOT"

