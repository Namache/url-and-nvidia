# Contributing to Bazzite-ClaudeDesktop

Thanks for your interest in contributing. This document covers how to report issues, suggest improvements, and submit pull requests.

## A note on how this project is built

This project is heavily AI-assisted — most of the code is written with Claude Code ("vibe coded"). That said, every change is human-reviewed and tested on real hardware before it lands in `main`. All pull requests, regardless of origin, require human review and approval before merging.

---

## Ways to contribute

- **Bug reports** — something broke? Open a [bug report](https://github.com/tpfirman/Bazzite-ClaudeDesktop/issues/new?template=bug_report.yml).
- **Feature requests** — want something new? Open a [feature request](https://github.com/tpfirman/Bazzite-ClaudeDesktop/issues/new?template=feature_request.yml).
- **Improvements** — existing behaviour that could be better? Open an [improvement](https://github.com/tpfirman/Bazzite-ClaudeDesktop/issues/new?template=improvement.yml).
- **Documentation** — unclear or missing docs? Open a [documentation issue](https://github.com/tpfirman/Bazzite-ClaudeDesktop/issues/new?template=documentation.yml).
- **Pull requests** — see below.

---

## Branch and PR workflow

1. Fork the repository and create a branch from `main`:
   ```bash
   git checkout -b feat/my-change
   ```
2. Make your changes. Keep commits focused and well-described.
3. Run the local lint checks before pushing:
   ```bash
   bash tests/lint.sh
   ```
4. Push your branch and open a pull request against `main`.
5. CI will run automatically. All checks must pass before review.
6. A maintainer (@tpfirman) will review and merge approved PRs.

There are no auto-merges. Every PR gets a human look before it lands.

---

## Code standards

- **All shell scripts must pass `shellcheck` with no warnings.** CI enforces this; the pre-commit hook enforces it locally. See [CLAUDE.md](CLAUDE.md) for how to install shellcheck.
- **Scripts must remain idempotent** — safe to re-run without side effects.
- **Follow existing patterns.** Read the files you're changing before modifying them.
- **No speculative features.** Changes should solve a real, stated problem.
- **Test-driven where possible.** If your change can be verified by a lint check, a syntax test, or a functional test, add one. See [CLAUDE.md](CLAUDE.md) for the test setup.

---

## Review process

- @tpfirman reviews all pull requests.
- External contributors cannot self-merge — branch protection requires at least one approval.
- Feedback will be direct and focused on the change. Don't take it personally.
- If a PR sits unreviewed for more than a week, feel free to ping in the issue or PR thread.
