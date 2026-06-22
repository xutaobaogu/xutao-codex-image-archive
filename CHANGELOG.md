# Changelog

## v0.1.0 - 2026-06-22

- Initial public release.
- Archive Codex chat images from `local_images` and embedded `input_image` data URLs.
- Install a global Codex `notify` wrapper that preserves the original notify command.
- Support `report`, `recent`, and `backfill` commands.
- Deduplicate archived images by SHA-256.
- Add local-only manifest, state, and logs under `~/.codex/chat-image-archive/`.
- Add install, uninstall, and smoke-test scripts.
