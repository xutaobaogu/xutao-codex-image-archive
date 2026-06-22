#!/usr/bin/env zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
BIN_DIR="$CODEX_HOME/bin"
CONFIG="$CODEX_HOME/config.toml"
ARCHIVE_ROOT="${CODEX_IMAGE_ARCHIVE_ROOT:-$CODEX_HOME/chat-image-archive}"
ORIGINAL_NOTIFY_JSON="$ARCHIVE_ROOT/original-notify.json"
STAMP="$(date +%Y%m%d%H%M%S)"
BACKUP="$CONFIG.bak.image-archive.$STAMP"
WRAPPER="$BIN_DIR/codex-notify-wrapper"
RUN_BACKFILL=0

for arg in "$@"; do
  case "$arg" in
    --backfill) RUN_BACKFILL=1 ;;
    *)
      echo "Usage: install.sh [--backfill]" >&2
      exit 2
      ;;
  esac
done

if [ ! -f "$CONFIG" ]; then
  echo "Codex config not found: $CONFIG" >&2
  exit 1
fi

mkdir -p "$BIN_DIR" "$ARCHIVE_ROOT"
cp "$SCRIPT_DIR/codex-image-archive" "$BIN_DIR/codex-image-archive"
cp "$SCRIPT_DIR/codex-notify-wrapper" "$WRAPPER"
chmod +x "$BIN_DIR/codex-image-archive" "$WRAPPER"

cp "$CONFIG" "$BACKUP"

python3 - "$CONFIG" "$WRAPPER" "$ORIGINAL_NOTIFY_JSON" "$BACKUP" <<'PY'
import datetime as dt
import json
import sys
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:
    import tomli as tomllib

config = Path(sys.argv[1]).expanduser()
wrapper = str(Path(sys.argv[2]).expanduser())
original_notify_json = Path(sys.argv[3]).expanduser()
backup = Path(sys.argv[4]).expanduser()

raw = config.read_bytes()
parsed = tomllib.loads(raw.decode("utf-8"))
existing_notify = parsed.get("notify")
wrapper_notify = [wrapper, "turn-ended"]

if existing_notify != wrapper_notify and isinstance(existing_notify, list):
    original_notify_json.parent.mkdir(parents=True, exist_ok=True)
    original_notify_json.write_text(
        json.dumps(
            {
                "notify": existing_notify,
                "saved_at": dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds"),
                "config_backup": str(backup),
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

replacement = f'notify = [{json.dumps(wrapper)}, "turn-ended"]'
lines = raw.decode("utf-8").splitlines()
for index, line in enumerate(lines):
    if line.startswith("notify = "):
        lines[index] = replacement
        break
else:
    lines.insert(0, replacement)

config.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

echo "Installed $BIN_DIR/codex-image-archive"
echo "Installed $WRAPPER"
echo "Backed up $CONFIG to $BACKUP"
echo "Archive root: $ARCHIVE_ROOT"

if [ "$RUN_BACKFILL" -eq 1 ]; then
  "$BIN_DIR/codex-image-archive" backfill
fi

