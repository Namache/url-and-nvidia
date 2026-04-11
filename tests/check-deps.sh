#!/usr/bin/env bash
# check-deps.sh — Verify that critical packages are listed in install-in-container.sh.
# These are static checks (no container needed) that catch missing dependencies
# before they cause silent runtime failures in Claude Desktop.
# Exits 1 if any required package is missing from the install script.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
INSTALL_SCRIPT="${REPO_ROOT}/scripts/install-in-container.sh"

PASS=0
FAIL=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}PASS${NC}  $1"; PASS=$((PASS + 1)); }
fail() { echo -e "  ${RED}FAIL${NC}  $1"; FAIL=$((FAIL + 1)); }

echo "=== install-in-container.sh dependency checks ==="

check_dep() {
    local pkg="$1"
    local reason="$2"
    if grep -qE "^\s+${pkg}\b" "${INSTALL_SCRIPT}"; then
        pass "${pkg} is listed"
    else
        fail "${pkg} is missing — ${reason}"
    fi
}

# git: Claude Desktop requires it for local project sessions
check_dep "git" "Claude Desktop requires git for local project sessions"

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed."

if [[ "${FAIL}" -gt 0 ]]; then
    exit 1
fi
