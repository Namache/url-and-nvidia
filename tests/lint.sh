#!/usr/bin/env bash
# lint.sh — Validate all shell scripts (shellcheck) and JSON files in the repo.
# Exits 1 if any check fails. Run locally or via CI.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

PASS=0
FAIL=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}PASS${NC}  $1"; PASS=$((PASS + 1)); }
fail() { echo -e "  ${RED}FAIL${NC}  $1"; FAIL=$((FAIL + 1)); }

# ---------------------------------------------------------------------------
# Shell script linting
# ---------------------------------------------------------------------------
echo "=== Shell scripts (shellcheck) ==="

if ! command -v shellcheck &>/dev/null; then
    echo "shellcheck not found. Install it:"
    echo "  Bazzite/Fedora: sudo rpm-ostree install ShellCheck"
    echo "  Ubuntu/Debian:  sudo apt-get install shellcheck"
    exit 1
fi

while IFS= read -r -d '' sh_file; do
    rel="${sh_file#"${REPO_ROOT}/"}"
    if shellcheck "${sh_file}"; then
        pass "${rel}"
    else
        fail "${rel}"
    fi
done < <(find "${REPO_ROOT}" -name "*.sh" -not -path "*/.git/*" -print0)

# Also lint hook scripts that lack a .sh extension
while IFS= read -r -d '' hook_file; do
    rel="${hook_file#"${REPO_ROOT}/"}"
    # Only check files that have a bash/sh shebang
    if head -1 "${hook_file}" | grep -qE '^#!.*(bash|sh)'; then
        if shellcheck "${hook_file}"; then
            pass "${rel}"
        else
            fail "${rel}"
        fi
    fi
done < <(find "${REPO_ROOT}/hooks" -type f -not -name "*.sh" -print0 2>/dev/null || true)

# ---------------------------------------------------------------------------
# JSON validation
# ---------------------------------------------------------------------------
echo ""
echo "=== JSON files ==="

while IFS= read -r -d '' json_file; do
    rel="${json_file#"${REPO_ROOT}/"}"
    if python3 -m json.tool "${json_file}" > /dev/null 2>&1; then
        pass "${rel}"
    else
        fail "${rel}"
    fi
done < <(find "${REPO_ROOT}" -name "*.json" \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -print0)

# ---------------------------------------------------------------------------
# Results
# ---------------------------------------------------------------------------
echo ""
echo "Results: ${PASS} passed, ${FAIL} failed."

if [[ "${FAIL}" -gt 0 ]]; then
    exit 1
fi
