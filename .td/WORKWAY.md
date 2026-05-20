# Way of work

How the td-flow framework itself gets tested, verified, and shipped. This repo is its own first project — the framework eats its own dog food.

## Local testing

The framework has no automated test suite (yet). The current contract is manual smoke checks.

- Test command:    none
- Dev server:      none
- Local URL:       none
- Pre-ship checklist:
  - [ ] `bash -n install.sh` (syntax-check the installer)
  - [ ] `bash -n hooks/pre-commit` (syntax-check the hook)
  - [ ] `./install.sh` runs idempotently (re-running doesn't error or duplicate symlinks)
  - [ ] All 7 slash commands appear in `~/.claude/commands/` (`td-init.md`, `td-clear.md`, `td-close.md`, `td-refresh.md`, `td-mailbox.md`, `td-incident.md`, `td-park.md`)
  - [ ] Skill at `~/.claude/skills/td-flow` resolves
  - [ ] Templates at `~/.claude/td-templates` resolves to `templates/`
  - [ ] AWK extractor in `hooks/pre-commit` returns the expected value when run against a filled WORKWAY.md template

### When local testing isn't possible

The framework is fully testable locally. If a future change involves a Claude Code-side behavior (e.g. how the skill loads), live-testing means: open Claude Code in another project, run `/td-init`, verify behavior. Document the case in the topic's work file.

## Local UAT

- Who runs it: Claude (smoke checks) + the maintainer (real-world use across portfolio projects).
- What to verify: after a change, run a fresh `./install.sh`, then in a throwaway directory run `/td-init`. Walk through any flow affected by the change.
- How: `mkdir /tmp/td-test && cd /tmp/td-test && claude` → `/td-init` → exercise the change.

## Live

The "live" environment for this framework is `mergodon/td-flow` on GitHub plus the symlinked install on each machine.

- Live URL:        https://github.com/mergodon/td-flow
- Deploy:          `git push origin main` (immediate; symlinks pick up changes since `templates/`, `commands/`, `skill/` are linked, not copied)
- Smoke after ship: re-run `./install.sh` on the local machine; verify the new content is visible
- Logs:            none (this is just files + symlinks)
- Dashboards:      none

## Framework specifics

### Bash + AWK

- `install.sh` is bash. Use `set -euo pipefail` for safety.
- `hooks/pre-commit` is bash; AWK extracts the Test command from `WORKWAY.md` § Local testing.
- AWK pattern: section starts at `^## Local testing`, terminates at next `^## ` (so H3 subsections like `### When local testing isn't possible` stay inside the section).

### Claude Code skill / commands

- Slash commands are markdown files with YAML frontmatter (`---\ndescription: …\n---`).
- Skill at `skill/SKILL.md` with YAML frontmatter (`name`, `description`).
- All three are loaded by Claude Code from `~/.claude/commands/` and `~/.claude/skills/`.

### Multi-machine sync

- Each machine gets a fresh `git clone https://github.com/mergodon/td-flow ~/projects/td-flow` then `./install.sh`.
- Updates: `git pull` then `./install.sh` — `install.sh` is idempotent; re-run it whenever command files are added/renamed, even without a pull (`/td-refresh` Phase 0 does this automatically).
- No global memory dependency — everything ships through git.

## Notes

- The framework went through three rewrites in two days (v1 → v2 → v3). This is fine for a personal tool with a single user, but signals: don't over-engineer; build for what's actually used. The shape stabilized only after looking at real portfolio projects.
- Eat-own-dog-food: this very repo IS a td-flow project. Confirms the framework is self-consistent. If `/td-clear` and `/td-close` work here, they work in general.
- Boost-style framework pollution is handled as a manual edge case, NOT engineered around in the default flow. Per Laravel team's own docs, gitignoring Boost's outputs is the recommended path; td-flow's `/td-init` does this for Laravel projects when detected.
