# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [0.1.0] - 2026-04-19

### Added
- Initial Claude Desktop setup for Bazzite Linux via Distrobox (Ubuntu 24.04 container)
- `setup.sh` — idempotent host-side orchestration script with preflight checks, container creation, MCP config merging, desktop export, and Wayland support patching
- `scripts/install-in-container.sh` — installs Claude Desktop from the community APT repo, Node.js, and MCP servers inside the container
- Safe MCP config merge: preserves existing user config, only updates the `filesystem` entry
- Multi-directory filesystem MCP support via `.env` configuration
- Opt-in logging via `ENABLE_LOGGING` in `.env`
- Git installed in container so Claude Desktop can open local sessions
- `libasound2t64` (ALSA) dependency fix for silent Electron launch failures
- Pre-commit hook enforcing shellcheck and JSON validation
- GitHub Actions CI (lint workflow)
- Issue templates: bug report, feature request, improvement, documentation
- MIT license, CONTRIBUTING.md, CODEOWNERS

[Unreleased]: https://github.com/tpfirman/Bazzite-ClaudeDesktop/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/tpfirman/Bazzite-ClaudeDesktop/releases/tag/v0.1.0
