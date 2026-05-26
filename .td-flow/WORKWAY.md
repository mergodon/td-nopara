# Way of work

How the td-flow framework itself gets tested, verified, and shipped. This repo is its own first project — the framework eats its own dog food.

## Local testing

The framework has no application-code test suite (and never will — there's no application code). The pre-ship checks are mechanical sanity checks automated by `scripts/smoke.sh`, which the pre-commit hook runs on every commit.

- Test command:    scripts/smoke.sh
- Dev server:      none
- Local URL:       none
- Pre-ship checks (automated by `scripts/smoke.sh`, OK/WARN/FAIL output, exit 0/1/2 — 10 OK on clean state):
  - [x] `bash -n install.sh` + `bash -n hooks/pre-commit` (syntax — 2 OKs)
  - [x] All 10 slash commands resolve in `~/.claude/commands/` (`td-flow-init`, `td-flow-clear`, `td-flow-complex-clear`, `td-flow-close`, `td-flow-refresh`, `td-flow-mailbox`, `td-flow-health`, `td-flow-incident`, `td-flow-park`, `td-flow-snapshot`)
  - [x] Templates at `~/.claude/td-templates` and contract at `~/.claude/td-flow-contract.md` both resolve
  - [x] `./install.sh` runs idempotently (two consecutive runs both exit 0)
  - [x] AWK extractor in `hooks/pre-commit` returns a non-empty value from `.td-flow/WORKWAY.md § Local testing`
  - [x] **Cross-reference** (v7.1): every `commands/td-flow-*.md` listed in `EXPECTED_COMMANDS` also appears in `CLAUDE.md`'s "Ten commands" trigger map, README's install symlinks list, AND README's slash commands table
  - [x] **Frontmatter validity** (v7.1): every command file has YAML frontmatter with a non-empty `description:` field
  - [x] **Per-command load-bearing anchors** (v7.2): 31 anchors across all 10 commands (Step headers, commit conventions, protocol fragments, named procedure references) — silent regressions on any anchor fail the pre-commit hook on the spot. Edit the `ANCHORS=(…)` array in `scripts/smoke.sh § 8` to add coverage when a new load-bearing piece lands
  - WARN: any unexpected td-flow command symlinked in `~/.claude/commands/` (drift signal — retired command not pruned)

### When local testing isn't possible

The framework is fully testable locally. If a future change involves a Claude Code-side behavior (e.g. how the contract `@import` resolves, how a command surfaces in autocomplete), live-testing means: open Claude Code in another project, run `/td-flow-init`, verify behavior. Document the case in the topic's work file.

## Local UAT

- Who runs it: Claude (smoke checks) + the maintainer (real-world use across portfolio projects).
- What to verify: after a change, run a fresh `./install.sh`, then in a throwaway directory run `/td-flow-init`. Walk through any flow affected by the change.
- How: `mkdir /tmp/td-test && cd /tmp/td-test && claude` → `/td-flow-init` → exercise the change.

## Live

The "live" environment for this framework is `mergodon/td-flow` on GitHub plus the symlinked install on each machine.

- Live URL:        https://github.com/mergodon/td-flow
- Deploy:          `git push origin main` (immediate; symlinks pick up changes since `templates/`, `commands/`, and the contract are linked, not copied)
- Smoke after ship: re-run `./install.sh` on the local machine; verify the new content is visible
- Logs:            none (this is just files + symlinks)
- Dashboards:      none

## Framework specifics

### Bash + AWK

- `install.sh` is bash. Use `set -euo pipefail` for safety.
- `hooks/pre-commit` is bash; AWK extracts the Test command from `WORKWAY.md` § Local testing.
- AWK pattern: section starts at `^## Local testing`, terminates at next `^## ` (so H3 subsections like `### When local testing isn't possible` stay inside the section).

### Claude Code commands + contract

- Slash commands are markdown files with YAML frontmatter (`---\ndescription: …\n---`), loaded by Claude Code from `~/.claude/commands/`.
- The contract is this repo's root `CLAUDE.md` — the canonical source. `install.sh` links it to `~/.claude/td-flow-contract.md`; every consuming project's `CLAUDE.md` is a one-line `@import` of it (Claude Code expands the import in full at session start). Consuming projects never copy the contract; the td-flow repo's own `CLAUDE.md` is the one full copy.
- **No skill.** The `td-flow` skill was retired in v6.1 — it duplicated the rhythm + file structure + command list that the contract already covers via `@import`. Existing machines auto-clean the old `~/.claude/skills/td-flow` symlink on next `./install.sh` run (one-time retirement notice).

### Multi-machine sync

- Each machine gets a fresh `git clone https://github.com/mergodon/td-flow ~/projects/td-flow` then `./install.sh`.
- Updates: `git pull` then `./install.sh` — `install.sh` is idempotent; re-run it whenever command files are added/renamed, even without a pull (`/td-flow-refresh` does this automatically).
- No global memory dependency — everything ships through git.

## Notes

- The framework went through three rewrites in two days (v1 → v2 → v3). This is fine for a personal tool with a single user, but signals: don't over-engineer; build for what's actually used. The shape stabilized only after looking at real portfolio projects.
- Eat-own-dog-food: this very repo IS a td-flow project. Confirms the framework is self-consistent. If `/td-flow-clear` and `/td-flow-close` work here, they work in general.
- Boost-style framework pollution is handled as a manual edge case, NOT engineered around in the default flow. Per Laravel team's own docs, gitignoring Boost's outputs is the recommended path; td-flow's `/td-flow-init` does this for Laravel projects when detected.
- Test harness: `mergodon/td-flow-test1` + `td-flow-test2` (private, kept). Two scaffolded td-flow projects with cross-declared `Cross-repo` registries — re-run td-flow command tests against them: cross-repo, `/td-flow-mailbox`, `/td-flow-park`, and the lifecycle commands (`git clone` for local copies). Created + exercised 2026-05-22; the org disallows issue deletion, so each run leaves closed issues behind.
