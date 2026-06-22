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
FORCE_ORIGINAL=0

for arg in "$@"; do
  case "$arg" in
    --backfill) RUN_BACKFILL=1 ;;
    --force-original) FORCE_ORIGINAL=1 ;;
    *)
      echo "Usage: install.sh [--backfill] [--force-original]" >&2
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

python3 - "$CONFIG" "$WRAPPER" "$ORIGINAL_NOTIFY_JSON" "$BACKUP" "$FORCE_ORIGINAL" <<'PY'
import ast
import datetime as dt
import json
import sys
from pathlib import Path

config = Path(sys.argv[1]).expanduser()
wrapper = str(Path(sys.argv[2]).expanduser())
original_notify_json = Path(sys.argv[3]).expanduser()
backup = Path(sys.argv[4]).expanduser()
force_original = sys.argv[5] == "1"


def parse_notify_from_text(text):
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped.startswith("notify"):
            continue
        key, sep, value = stripped.partition("=")
        if sep and key.strip() == "notify":
            return ast.literal_eval(value.strip())
    return None


def load_notify(raw_text):
    try:
        import tomllib

        return tomllib.loads(raw_text).get("notify")
    except ModuleNotFoundError:
        return parse_notify_from_text(raw_text)


raw = config.read_bytes()
raw_text = raw.decode("utf-8")
existing_notify = load_notify(raw_text)
wrapper_notify = [wrapper, "turn-ended"]

should_save_original = (
    existing_notify != wrapper_notify
    and isinstance(existing_notify, list)
    and (force_original or not original_notify_json.exists())
)

if should_save_original:
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
lines = raw_text.splitlines()
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
