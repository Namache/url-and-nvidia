# CLAUDE.md

This repo sets up Claude Desktop on Bazzite Linux using a Distrobox container. See README.md for user-facing docs.

## Running Tests

```bash
bash tests/lint.sh
```

Requires `shellcheck` and `python3`. On Ubuntu/Debian: `sudo apt-get install shellcheck`. On Bazzite: `sudo rpm-ostree install ShellCheck`.

Checks all `.sh` files with shellcheck and validates all `.json` files with `python3 -m json.tool`.

## Key Files

| File | What it does |
|---|---|
| `setup.sh` | Orchestrates everything — run on the Bazzite host |
| `scripts/install-in-container.sh` | Installs Claude Desktop `.deb`, Node.js, MCP server inside Ubuntu 24.04 container |
| `config/claude_desktop_config.json` | MCP filesystem server template — copied to `~/.config/claude/` |
| `tests/lint.sh` | Shell + JSON linting |

## Development Notes

- All scripts must pass `shellcheck` with no warnings before committing (enforced by pre-commit hook and CI)
- `setup.sh` and `install-in-container.sh` must remain idempotent — safe to re-run
- The Claude Desktop `.deb` download URL is a variable at the top of `scripts/install-in-container.sh` (`CLAUDE_DEB_URL`) — update it there if the URL changes
- Do not overwrite `~/.config/claude/claude_desktop_config.json` if it already exists (user may have customized it)
- The git hooks in `hooks/` are wired up by `hooks/install-hooks.sh`, which is called by `setup.sh`
