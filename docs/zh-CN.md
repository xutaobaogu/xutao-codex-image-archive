# xutao-codex-image-archive 中文说明

`xutao-codex-image-archive` 是一个本地优先的 Codex Skill，用来自动归档你粘贴到 Codex 聊天里的截图和图片。

它解决的问题很具体：Codex 历史会话里可能引用 `/var/folders/.../codex-clipboard-*.png` 这类临时图片路径。macOS 清理临时目录后，会话文字还在，但图片可能失效。这个工具会在每轮 Codex 对话结束后扫描最近 session 日志，把可恢复图片保存到本机持久目录。

## 它会保存什么

- Codex session 日志中的 `local_images` 本地图片路径。
- 用户消息中的 `input_image` data URL / base64 图片。
- 来自剪贴板的 `codex-clipboard-*.png` 截图。

默认归档位置：

```text
~/.codex/chat-image-archive/
```

图片位置：

```text
~/.codex/chat-image-archive/images/YYYY/MM/DD/<session_id>/
```

索引文件：

```text
~/.codex/chat-image-archive/manifest.jsonl
```

## 快速安装

```bash
git clone https://github.com/xutaobaogu/xutao-codex-image-archive.git
cd xutao-codex-image-archive
mkdir -p ~/.codex/skills
cp -R skill ~/.codex/skills/xutao-codex-image-archive
~/.codex/skills/xutao-codex-image-archive/scripts/install.sh
```

如果想顺便补归档历史会话中仍可恢复的图片：

```bash
~/.codex/skills/xutao-codex-image-archive/scripts/install.sh --backfill
```

打开 Codex 后，可先执行一次修复，恢复历史会话里被清理掉的临时图片路径：

```bash
~/.codex/bin/codex-image-archive repair
```

## 常用命令

查看可恢复情况，不复制图片：

```bash
~/.codex/bin/codex-image-archive report
```

处理最近会话：

```bash
~/.codex/bin/codex-image-archive recent
```

修复历史会话里已被清理的 `codex-clipboard-*.png`：

```bash
~/.codex/bin/codex-image-archive repair
```

补归档所有历史会话：

```bash
~/.codex/bin/codex-image-archive backfill
```

卸载全局 hook：

```bash
~/.codex/skills/xutao-codex-image-archive/scripts/uninstall.sh
```

卸载不会删除已归档图片。

## 安全性

- 不上传图片。
- 不调用外部 API。
- 不把图片写入项目 Git 仓库。
- 安装前会备份 `~/.codex/config.toml`。
- 如果原来已有 Codex `notify` 命令，会保存并继续调用。
- 归档数据默认只在当前用户的 `~/.codex` 目录下。

## 适合谁

- 经常在 Codex 聊天里粘贴截图、网页截图、UI 截图的人。
- 需要回看历史 Codex 会话图片的人。
- 希望跨项目保留 Codex 对话附件的人。
- 不希望把对话图片上传到云端的人。
