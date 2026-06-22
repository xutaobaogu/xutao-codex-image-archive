# Share Copy

Copy these snippets when sharing the project.

## Short English

A local-first Codex skill that archives pasted chat images before temporary clipboard files disappear.

GitHub: https://github.com/xutaobaogu/xutao-codex-image-archive

## 中文短介绍

一个本地优先的 Codex Skill，用来自动归档你粘贴到 Codex 聊天里的截图和图片，避免历史会话图片失效。

GitHub: https://github.com/xutaobaogu/xutao-codex-image-archive

## V2EX / 中文社区

我做了一个小工具：xutao-codex-image-archive。

它解决 Codex 历史会话里的截图失效问题。Codex 从剪贴板粘贴的图片经常是 `/var/folders/.../codex-clipboard-*.png` 这种临时路径，macOS 清理后历史会话还在，但图没了。

这个项目会通过 Codex 的全局 notify hook，在每轮对话结束后自动扫描 session 日志，把可恢复的聊天图片保存到本机 `~/.codex/chat-image-archive/`。

特点：

- 本地保存，不上传
- 支持 backfill 历史可恢复图片
- 支持从 `input_image` base64 重建
- 保留原有 notify 命令
- 可卸载恢复

GitHub: https://github.com/xutaobaogu/xutao-codex-image-archive

## Twitter / X

I built a small local-first Codex skill:

`xutao-codex-image-archive`

It archives pasted Codex chat images before temporary clipboard files like `/var/folders/.../codex-clipboard-*.png` disappear.

Local only. No uploads. Supports backfill.

https://github.com/xutaobaogu/xutao-codex-image-archive

## Reddit / Hacker News

I made a small Codex utility for a surprisingly annoying problem: pasted chat images can be referenced from temporary local clipboard paths, and old conversations may lose those images after the temp files disappear.

This skill installs a Codex notify hook that archives recoverable pasted images locally after each turn. It can also backfill old sessions when the original file or embedded input image data is still available.

It is local-only and does not upload images.

Repo: https://github.com/xutaobaogu/xutao-codex-image-archive
