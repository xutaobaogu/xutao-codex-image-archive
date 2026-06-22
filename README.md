# xutao-codex-image-archive

A Codex skill and helper scripts for preserving images pasted into Codex chats.

Codex clipboard images often live under temporary paths such as
`/var/folders/.../codex-clipboard-*.png`. This skill installs a global archive
hook that scans Codex session logs after each turn and saves recoverable chat
images into a durable local archive.

## What It Saves

- `local_images` recorded in Codex session logs.
- `input_image` data URLs embedded in session JSONL.
- Clipboard screenshots referenced as `codex-clipboard-*.png`.

The archive is local only. It does not upload images or commit them to Git.

## Install The Skill

Clone this repository, then copy the skill folder into Codex:

```bash
mkdir -p ~/.codex/skills
cp -R skill ~/.codex/skills/xutao-codex-image-archive
```

Install the global archive hook:

```bash
~/.codex/skills/xutao-codex-image-archive/scripts/install.sh
```

Optionally backfill existing recoverable images:

```bash
~/.codex/bin/codex-image-archive backfill
```

## Verify

```bash
~/.codex/bin/codex-image-archive report
~/.codex/bin/codex-image-archive recent
```

Archived images are written to:

```text
~/.codex/chat-image-archive/images/
```

The manifest is written to:

```text
~/.codex/chat-image-archive/manifest.jsonl
```

## Uninstall

```bash
~/.codex/skills/xutao-codex-image-archive/scripts/uninstall.sh
```

The uninstall script restores the original Codex `notify` command when it was
saved during install. It does not delete archived images.

## Publish To GitHub

After creating a GitHub repository named `xutao-codex-image-archive`:

```bash
git remote add origin https://github.com/YOUR_USERNAME/xutao-codex-image-archive.git
git push -u origin main
```

