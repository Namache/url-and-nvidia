# Claude Desktop on Bazzite Linux

Installs [Claude Desktop](https://claude.ai/download) on [Bazzite](https://bazzite.gg/) (an immutable Fedora-based gaming/desktop OS) using a [Distrobox](https://distrobox.it/) container. Because Bazzite's host filesystem is read-only, the app runs inside an Ubuntu 24.04 container and is exported to the host desktop via `distrobox-export`.

**Features**
- MCP filesystem server pre-configured to browse repos at `/mnt/git`
- Full internet + local LAN access (container shares host network namespace)
- Wayland support out of the box (`ELECTRON_OZONE_PLATFORM_HINT=auto`)
- Idempotent setup — re-run `./setup.sh` to update

---

## Requirements

- Bazzite (or any Fedora Silverblue/Kinoite-based OS with Distrobox pre-installed)
- `/mnt/git` — mounted and accessible before launching Claude Desktop

---

## Setup

```bash
git clone <repo-url>
cd Bazzite-ClaudeDesktop
./setup.sh
```

That's it. The script will:

1. Create an Ubuntu 24.04 Distrobox container named `claude-desktop` with `/mnt/git` mounted
2. Install Claude Desktop (`.deb`) and its dependencies inside the container
3. Install Node.js LTS and the MCP filesystem server (`@modelcontextprotocol/server-filesystem`)
4. Copy the MCP config to `~/.config/claude/claude_desktop_config.json` (skipped if it already exists)
5. Export the app to your host desktop (app grid + `.desktop` launcher)
6. Patch the launcher for Wayland
7. Install the git pre-commit hook (shell + JSON linting)

### Launching

From your app grid, or from a terminal:

```bash
distrobox enter --name claude-desktop -- claude
```

---

## Updating Claude Desktop

Re-run the setup script — it will re-download and reinstall the latest `.deb` without recreating the container:

```bash
./setup.sh
```

---

## MCP Configuration

The default config at `~/.config/claude/claude_desktop_config.json` gives Claude read access to everything under `/mnt/git`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/mnt/git"]
    }
  }
}
```

To add more paths, edit that file directly and restart Claude Desktop. See the [MCP filesystem server docs](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem) for options.

> **Note:** The setup script will not overwrite an existing config. To reset to the template:
> ```bash
> cp config/claude_desktop_config.json ~/.config/claude/claude_desktop_config.json
> ```

---

## Troubleshooting

### `distrobox: command not found`

Distrobox ships with Bazzite but may not be in `PATH` for all shells. Try:

```bash
ujust setup-distrobox   # Bazzite helper
# or
/usr/bin/distrobox list
```

---

### `/mnt/git` not accessible inside the container

The volume is mounted at container creation time. If `/mnt/git` wasn't available when you ran `./setup.sh`, recreate the container:

```bash
distrobox rm claude-desktop
./setup.sh
```

Verify the mount is visible inside the container:

```bash
distrobox enter --name claude-desktop -- ls /mnt/git
```

---

### Claude Desktop won't launch / blank window

**Wayland issue** — check that `ELECTRON_OZONE_PLATFORM_HINT=auto` is in the `.desktop` file:

```bash
grep ELECTRON ~/.local/share/applications/claude.desktop
```

If it's missing, re-run `./setup.sh` to re-apply the patch, or force X11 as a workaround:

```bash
distrobox enter --name claude-desktop -- env DISPLAY=:0 claude
```

---

### MCP filesystem server not connecting

In Claude Desktop, go to **Settings → Developer → MCP Servers** and check the `filesystem` status.

Common causes:

| Symptom | Fix |
|---|---|
| `npx: command not found` | Run `./setup.sh` again — Node.js may not have installed correctly |
| `/mnt/git` permission denied | Check that your user owns the mount point |
| Server listed but shows error | Restart Claude Desktop; check `~/.config/claude/claude_desktop_config.json` for syntax errors |

To test the MCP server manually inside the container:

```bash
distrobox enter --name claude-desktop -- npx -y @modelcontextprotocol/server-filesystem /mnt/git
```

---

### App not showing in app grid after export

```bash
distrobox enter --name claude-desktop -- distrobox-export --app claude
```

Then refresh your app grid (log out/in or `killall gnome-shell` on GNOME).

---

## Repo Structure

```
setup.sh                        # Run this on Bazzite to install everything
scripts/install-in-container.sh # Runs inside the container (called by setup.sh)
config/claude_desktop_config.json  # MCP config template
tests/lint.sh                   # shellcheck + JSON validation
hooks/pre-commit                # Git pre-commit hook (runs lint.sh)
hooks/install-hooks.sh          # Wires hooks/ into .git/hooks/
.github/workflows/ci.yml        # CI: lint on push/PR to main
```
