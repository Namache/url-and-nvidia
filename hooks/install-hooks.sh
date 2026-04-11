#!/usr/bin/env bash
# install-hooks.sh — Symlinks repo hooks into .git/hooks.
# Called automatically by setup.sh. Safe to re-run.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_HOOKS_DIR="$(git -C "${SCRIPT_DIR}" rev-parse --git-dir)/hooks"

ln -sf "${SCRIPT_DIR}/pre-commit" "${GIT_HOOKS_DIR}/pre-commit"
echo "[INFO]  pre-commit hook installed -> ${GIT_HOOKS_DIR}/pre-commit"
