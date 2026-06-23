# Troubleshooting

## `codex-image-archive: command not found`

Run the installer first:

```bash
~/.codex/skills/xutao-codex-image-archive/scripts/install.sh
```

Then verify:

```bash
~/.codex/bin/codex-image-archive report
```

## No images were archived

Run:

```bash
~/.codex/bin/codex-image-archive report
```

If it reports `missing`, the original temporary files may already have been cleaned. Recovery is still possible only when the Codex session JSONL contains embedded `input_image` data URLs.

If historical messages now show missing images after restarting your Mac, run:

```bash
~/.codex/bin/codex-image-archive repair
```

This checks all historical sessions and restores the temporary image paths from the local archive or embedded base64.

## I already had a Codex `notify` command

The installer saves the original command to:

```text
~/.codex/chat-image-archive/original-notify.json
```

The wrapper calls the original notify command first, then runs:

```bash
~/.codex/bin/codex-image-archive recent
```

Re-running install does not overwrite the first saved original notify command unless you pass:

```bash
~/.codex/skills/xutao-codex-image-archive/scripts/install.sh --force-original
```

## Restore the original `notify`

Run:

```bash
~/.codex/skills/xutao-codex-image-archive/scripts/uninstall.sh
```

Archived images are not deleted.

## Use a different archive directory

Set `CODEX_IMAGE_ARCHIVE_ROOT` before running the archiver:

```bash
CODEX_IMAGE_ARCHIVE_ROOT=/path/to/archive ~/.codex/bin/codex-image-archive backfill
```

For automatic notify-time archiving, configure this environment variable in the environment where Codex runs.

## Inspect logs

Automatic runs write logs under:

```text
~/.codex/chat-image-archive/logs/archive.log
```

## 中文排障

- 如果命令不存在，先运行 `scripts/install.sh`。
- 如果没有归档到图片，先运行 `codex-image-archive report` 看 `missing` 和 `would_archive` 数量。
- 如果临时文件已经被系统清理，只有 session JSONL 中包含 `input_image` base64 时才能恢复。
- 如果在重启或系统清理后历史消息里出现“图片 loading 不出来”，请执行：

```bash
~/.codex/bin/codex-image-archive repair
```
- 这条命令会扫描历史会话，优先从本机归档目录回写缺失的临时图片文件，再从 `input_image` base64 补充。
- 如果想恢复原来的 Codex `notify`，运行 `scripts/uninstall.sh`。
- 卸载不会删除已经保存的图片。
