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
| `config/claude_desktop_config.example.json` | MCP config reference template |
| `config/claude_desktop_config.json` | Local MCP config override (git-ignored) — if present, copied verbatim by `setup.sh` |
| `tests/lint.sh` | Shell + JSON linting |

## Test Driven Development
When building or planning a new feature, the first step should be to build or update a test, to ensure the end goal is met, if at all possible. When the build is finished, the test should pass. Tests should be added to the git actions that run on merge to main. Tests may be lint checks, syntax validation, or functional/integration tests as appropriate to the change.

## Development Notes

- All scripts must pass `shellcheck` with no warnings before committing (enforced by pre-commit hook and CI)
- `setup.sh` and `install-in-container.sh` must remain idempotent — safe to re-run
- The Claude Desktop `.deb` download URL is a variable at the top of `scripts/install-in-container.sh` (`CLAUDE_DEB_URL`) — update it there if the URL changes
- Do not overwrite `~/.config/claude/claude_desktop_config.json` if it already exists (user may have customized it)
- The git hooks in `hooks/` are wired up by `hooks/install-hooks.sh`, which is called by `setup.sh`
