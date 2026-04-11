#!/usr/bin/env bash
# setup.sh — Install Claude Desktop in a Distrobox container on Bazzite Linux.
# Safe to re-run for updates.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="claude-desktop"
CONTAINER_IMAGE="ubuntu:24.04"
GIT_MOUNT="/mnt/git"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
header(){ echo -e "\n${BOLD}$*${NC}"; }

# ---------------------------------------------------------------------------
# 1. Preflight checks
# ---------------------------------------------------------------------------
header "=== Preflight checks ==="

if ! command -v distrobox &>/dev/null; then
    error "distrobox not found. On Bazzite it should be pre-installed."
    error "Try: which distrobox  or  ujust setup-distrobox"
    exit 1
fi
info "distrobox found: $(command -v distrobox)"

if [[ ! -d "${GIT_MOUNT}" ]]; then
    warn "${GIT_MOUNT} does not exist — make sure it is mounted before launching Claude Desktop."
fi

# ---------------------------------------------------------------------------
# 2. Create Distrobox container (idempotent)
# ---------------------------------------------------------------------------
header "=== Distrobox container ==="

if distrobox list 2>/dev/null | grep -q "${CONTAINER_NAME}"; then
    info "Container '${CONTAINER_NAME}' already exists — skipping creation."
else
    info "Creating container '${CONTAINER_NAME}' (${CONTAINER_IMAGE})..."
    distrobox create \
        --name "${CONTAINER_NAME}" \
        --image "${CONTAINER_IMAGE}" \
        --volume "${GIT_MOUNT}:${GIT_MOUNT}" \
        --yes
    info "Container created."
fi

# ---------------------------------------------------------------------------
# 3. Run install script inside the container
#    Home dir is shared, so the script path is accessible from inside.
# ---------------------------------------------------------------------------
header "=== Installing Claude Desktop inside container ==="

INSTALL_SCRIPT="${SCRIPT_DIR}/scripts/install-in-container.sh"
info "Running ${INSTALL_SCRIPT} inside '${CONTAINER_NAME}'..."
distrobox enter --name "${CONTAINER_NAME}" -- bash "${INSTALL_SCRIPT}"
info "In-container install complete."

# ---------------------------------------------------------------------------
# 4. Install MCP config (preserve existing user config)
# ---------------------------------------------------------------------------
header "=== MCP configuration ==="

MCP_CONFIG_DIR="${HOME}/.config/claude"
MCP_CONFIG_FILE="${MCP_CONFIG_DIR}/claude_desktop_config.json"
mkdir -p "${MCP_CONFIG_DIR}"

if [[ -f "${MCP_CONFIG_FILE}" ]]; then
    warn "MCP config already exists at ${MCP_CONFIG_FILE} — not overwriting."
    warn "To reset to template: cp ${SCRIPT_DIR}/config/claude_desktop_config.json ${MCP_CONFIG_FILE}"
else
    cp "${SCRIPT_DIR}/config/claude_desktop_config.json" "${MCP_CONFIG_FILE}"
    info "MCP config installed to ${MCP_CONFIG_FILE}"
fi

# ---------------------------------------------------------------------------
# 5. Export Claude Desktop app to host desktop environment
# ---------------------------------------------------------------------------
header "=== Desktop integration ==="

info "Exporting Claude Desktop app to host..."
distrobox enter --name "${CONTAINER_NAME}" -- distrobox-export --app claude 2>/dev/null || true

DESKTOP_FILE="${HOME}/.local/share/applications/claude.desktop"
if [[ -f "${DESKTOP_FILE}" ]]; then
    # Patch all Exec= lines to prepend Wayland env var (idempotent guard included)
    if ! grep -q "ELECTRON_OZONE_PLATFORM_HINT" "${DESKTOP_FILE}"; then
        sed -i 's|^Exec=|Exec=env ELECTRON_OZONE_PLATFORM_HINT=auto |' "${DESKTOP_FILE}"
        info "Patched ${DESKTOP_FILE} for Wayland support."
    else
        info "Wayland patch already applied to ${DESKTOP_FILE}."
    fi
else
    warn "Could not find exported .desktop file at ${DESKTOP_FILE}"
    warn "You can export manually by running inside the container:"
    warn "  distrobox enter --name ${CONTAINER_NAME} -- distrobox-export --app claude"
fi

# ---------------------------------------------------------------------------
# 6. Install git hooks
# ---------------------------------------------------------------------------
header "=== Git hooks ==="

bash "${SCRIPT_DIR}/hooks/install-hooks.sh"

# ---------------------------------------------------------------------------
# 7. Summary
# ---------------------------------------------------------------------------
header "=== Done ==="
echo ""
echo "  Container:      ${CONTAINER_NAME}"
echo "  App launcher:   ${DESKTOP_FILE:-~/.local/share/applications/claude.desktop}"
echo "  MCP config:     ${MCP_CONFIG_FILE}"
echo "  Git hooks:      pre-commit (shellcheck + JSON lint)"
echo ""
echo "  Launch from terminal:"
echo "    distrobox enter --name ${CONTAINER_NAME} -- claude"
echo ""
echo "  To update Claude Desktop, re-run: ./setup.sh"
echo ""
