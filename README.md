# xutao-codex-image-archive

Archive pasted Codex chat images locally before temporary clipboard files disappear.

在本机自动归档你粘贴到 Codex 聊天里的截图和图片，避免历史会话里的 `/var/folders/.../codex-clipboard-*.png` 临时文件被清理后无法回看。

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
![Python](https://img.shields.io/badge/Python-3.x-blue.svg)
![Shell](https://img.shields.io/badge/Shell-zsh-lightgrey.svg)
![Codex Skill](https://img.shields.io/badge/Codex-Skill-black.svg)
![Local Only](https://img.shields.io/badge/Local%20Only-No%20Upload-orange.svg)

English: A local-first Codex skill that archives pasted chat images before temporary clipboard files disappear.

中文：一个本地优先的 Codex Skill，用来自动归档你粘贴到 Codex 聊天里的截图和图片，避免历史会话图片失效。

## Problem / 问题

Codex chat images pasted from the clipboard may be referenced from temporary paths such as:

```text
/var/folders/.../codex-clipboard-*.png
```

Those files can disappear after macOS cleans temporary folders, which means old Codex conversations may show missing images later.

Codex 对话中的剪贴板图片经常来自 macOS 临时目录。临时文件被系统清理后，历史会话还在，但图片可能已经打不开。

## What It Does / 功能

- Saves `local_images` recorded in Codex session logs.
- Rebuilds images from embedded `input_image` data URLs when possible.
- Archives clipboard screenshots referenced as `codex-clipboard-*.png`.
- Deduplicates images by SHA-256.
- Keeps a local `manifest.jsonl` for review and recovery.
- Installs through Codex's global `notify` hook and preserves the original notify command.

中文功能：

- 保存 Codex session 日志里的 `local_images`。
- 临时文件消失时，尽量从 JSONL 中的 `input_image` base64 重建图片。
- 自动归档 `codex-clipboard-*.png` 截图。
- 通过 SHA-256 去重。
- 写入本机 `manifest.jsonl`，方便以后追溯。
- 通过 Codex 全局 `notify` hook 自动运行，并保留原 notify 命令。

## Quick Install / 快速安装

Clone the repository:

```bash
git clone https://github.com/xutaobaogu/xutao-codex-image-archive.git
cd xutao-codex-image-archive
```

Copy the skill into Codex:

```bash
mkdir -p ~/.codex/skills
cp -R skill ~/.codex/skills/xutao-codex-image-archive
```

Install the global archive hook:

```bash
~/.codex/skills/xutao-codex-image-archive/scripts/install.sh
```

Install and backfill existing recoverable images in one step:

```bash
~/.codex/skills/xutao-codex-image-archive/scripts/install.sh --backfill
```

## Verify / 验证

After you open Codex, run one repair pass to restore missing historical images:

```bash
~/.codex/bin/codex-image-archive repair
```

每次打开 Codex 后先执行一次 `repair`，会把历史会话里缺失的 `/var/folders/.../codex-clipboard-*.png` 图片补回。

Check what can be archived:

```bash
~/.codex/bin/codex-image-archive report
```

Run the recent-session archiver:

```bash
~/.codex/bin/codex-image-archive recent
```

Repair specific missing image paths in historical sessions:

```bash
~/.codex/bin/codex-image-archive repair
```

Backfill old recoverable sessions:

```bash
~/.codex/bin/codex-image-archive backfill
```

Archived images are written to:

```text
~/.codex/chat-image-archive/images/
```

The manifest is written to:

```text
~/.codex/chat-image-archive/manifest.jsonl
```

## Safety / 安全性

- Local only: no upload, no cloud sync, no external API calls.
- The archive stays under `~/.codex/chat-image-archive/` by default.
- The installer backs up `~/.codex/config.toml` before editing it.
- The original `notify` command is saved and called before the image archiver.
- Uninstall restores the saved original `notify` command and keeps archived images.
- Runtime archives, manifests, state files, and logs are ignored by Git.

安全说明：

- 只保存在本机，不上传、不联网、不调用外部 API。
- 默认归档目录是 `~/.codex/chat-image-archive/`。
- 安装器修改 `~/.codex/config.toml` 前会先备份。
- 原来的 `notify` 命令会被保存，并且 wrapper 会先调用原 notify。
- 卸载只恢复 notify，不删除你已经归档的图片。

## Uninstall / 卸载

```bash
~/.codex/skills/xutao-codex-image-archive/scripts/uninstall.sh
```

Archived images are intentionally left untouched.

## FAQ / 常见问题

**Does it upload my images?**

No. It only reads local Codex session logs and writes local archive files.

**会上传我的图片吗？**

不会。它只读取本机 Codex session 日志，并把图片写入本机归档目录。

**Will it affect my projects?**

No. It installs into `~/.codex`, not into project repositories.

**会影响项目代码吗？**

不会。它安装在 `~/.codex`，不会写入你的项目仓库。

**Can it recover every old image?**

Only if the original temporary file still exists, or if the session JSONL contains an embedded `input_image` data URL.

**所有历史图片都能恢复吗？**

不一定。只有临时原图还存在，或 session JSONL 里有 `input_image` base64 时才能恢复。

**What if I already have a notify command?**

The installer saves it to `original-notify.json`, then the wrapper calls it before running the archiver.

**我原来已经有 notify 命令怎么办？**

安装器会保存原命令，wrapper 会先执行原命令，再执行图片归档。

## More Docs / 更多文档

- [中文说明](docs/zh-CN.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Share Copy](docs/share.md)
- [Changelog](CHANGELOG.md)
- [Contributing](CONTRIBUTING.md)

## Update / 更新

```bash
cd xutao-codex-image-archive
git pull
cp -R skill ~/.codex/skills/xutao-codex-image-archive
```

Run `install.sh` again only when you want to update the global hook scripts. The installer keeps the first saved original `notify` command unless you pass `--force-original`.
