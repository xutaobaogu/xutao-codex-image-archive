#!/usr/bin/env zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
TMP_HOME="$(mktemp -d "${TMPDIR:-/tmp}/xutao-codex-image-archive.XXXXXX")"

cleanup() {
  rm -rf "$TMP_HOME"
}
trap cleanup EXIT

mkdir -p "$TMP_HOME/sessions/2026/06/22"
cat > "$TMP_HOME/config.toml" <<'EOF'
notify = ["/bin/echo", "original-notify"]
model = "test"
EOF

python3 - "$TMP_HOME/sessions/2026/06/22/rollout-test.jsonl" <<'PY'
import json
import sys

events = [
    {"timestamp": "2026-06-22T00:00:00Z", "type": "session_meta", "payload": {"id": "test-session", "cwd": "/tmp/project"}},
    {"timestamp": "2026-06-22T00:00:01Z", "type": "turn_context", "payload": {"turn_id": "test-turn", "cwd": "/tmp/project"}},
    {
        "timestamp": "2026-06-22T00:00:02Z",
        "type": "response_item",
        "payload": {
            "type": "message",
            "role": "user",
            "content": [
                {"type": "input_text", "text": "<image path=\"/var/folders/example/T/codex-clipboard-aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee.png\">"},
                {"type": "input_image", "image_url": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII="},
            ],
        },
    },
]

with open(sys.argv[1], "w", encoding="utf-8") as handle:
    for event in events:
        handle.write(json.dumps(event) + "\n")
PY

CODEX_HOME="$TMP_HOME" "$SCRIPT_DIR/install.sh"
CODEX_HOME="$TMP_HOME" "$TMP_HOME/bin/codex-image-archive" report | grep "would_archive=1"
CODEX_HOME="$TMP_HOME" "$TMP_HOME/bin/codex-image-archive" backfill | grep "archived=1"
test -f "$TMP_HOME/chat-image-archive/original-notify.json"
test "$(find "$TMP_HOME/chat-image-archive/images" -type f | wc -l | tr -d ' ')" = "1"
CODEX_HOME="$TMP_HOME" "$SCRIPT_DIR/uninstall.sh"
grep -F 'notify = ["/bin/echo", "original-notify"]' "$TMP_HOME/config.toml"

echo "smoke-test ok"
