# Contributing

Thanks for helping improve `xutao-codex-image-archive`.

## Good Issues

- Installation problems on different macOS or Linux setups.
- Codex session log shapes that are not archived correctly.
- Safer handling of existing `notify` configurations.
- Documentation improvements in English or Chinese.

## Development Checks

Run these before opening a pull request:

```bash
python3 -m py_compile skill/scripts/codex-image-archive
zsh -n skill/scripts/*.sh skill/scripts/codex-notify-wrapper
skill/scripts/smoke-test.sh
```

If you have the Codex skill creator validation script available:

```bash
python3 /path/to/quick_validate.py skill
```

## Privacy Rules

Do not commit:

- Archived images.
- `manifest.jsonl`.
- `state.json`.
- Logs.
- Personal `~/.codex/config.toml` backups.
- Private notify commands or local absolute paths.

The project should stay local-first and avoid upload behavior unless it is clearly optional, documented, and disabled by default.
