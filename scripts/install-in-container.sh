#!/usr/bin/env bash
# install-in-container.sh — Runs INSIDE the claude-desktop Distrobox container.
# Installs Claude Desktop (.deb) and the MCP filesystem server (Node.js).
# Safe to re-run for updates.
set -euo pipefail

# Update this URL if Anthropic changes the download location.
CLAUDE_DEB_URL="https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/latest/claude_latest_amd64.deb"
NODE_MIN_VERSION=18

info() { echo "[INFO]  $*"; }
warn() { echo "[WARN]  $*"; }

# ---------------------------------------------------------------------------
# 1. Update apt
# ---------------------------------------------------------------------------
info "Updating apt package index..."
sudo apt-get update -qq

# ---------------------------------------------------------------------------
# 2. Install Electron runtime dependencies
# ---------------------------------------------------------------------------
info "Installing runtime dependencies..."
sudo apt-get install -y --no-install-recommends \
    wget \
    curl \
    ca-certificates \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxss1 \
    libxtst6 \
    xdg-utils

# ---------------------------------------------------------------------------
# 3. Download and install Claude Desktop
# ---------------------------------------------------------------------------
info "Downloading Claude Desktop..."
wget -q --show-progress -O /tmp/claude_latest_amd64.deb "${CLAUDE_DEB_URL}"

info "Installing Claude Desktop..."
# dpkg may fail on missing deps; apt-get install -f resolves them
sudo dpkg -i /tmp/claude_latest_amd64.deb || sudo apt-get install -f -y

rm -f /tmp/claude_latest_amd64.deb
info "Claude Desktop installed: $(command -v claude || echo 'binary not in PATH — check /opt or /usr/bin')"

# ---------------------------------------------------------------------------
# 4. Install Node.js LTS (required for MCP server)
# ---------------------------------------------------------------------------
node_needs_install=true

if command -v node &>/dev/null; then
    node_ver=$(node -e 'process.stdout.write(String(process.versions.node.split(".")[0]))')
    if (( node_ver >= NODE_MIN_VERSION )); then
        info "Node.js v${node_ver} already installed (>= ${NODE_MIN_VERSION}) — skipping."
        node_needs_install=false
    else
        warn "Node.js v${node_ver} is below minimum (${NODE_MIN_VERSION}), upgrading..."
    fi
fi

if [[ "${node_needs_install}" == "true" ]]; then
    info "Installing Node.js LTS via NodeSource..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    info "Node.js $(node --version) installed."
fi

# ---------------------------------------------------------------------------
# 5. Install MCP filesystem server
# ---------------------------------------------------------------------------
info "Installing @modelcontextprotocol/server-filesystem..."
sudo npm install -g @modelcontextprotocol/server-filesystem
info "MCP filesystem server installed."
