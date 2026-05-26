# State

Project:  td-flow
Topic:    idle
Phase:    idle
Blocker:  none
Last:     2026-05-26 — shipped v6.1: retired the `td-flow` skill. Deleted `skill/` dir, removed skill install from install.sh (replaced with retirement-detection block + one-time banner), removed skills/td-flow check from smoke.sh § 3, swept README/WORKWAY/PROJECT for skill references. Why useless: skill duplicated the rhythm + commands + file structure that the `@import` contract already covers in every td-flow project's CLAUDE.md — vestigial since v5.0. Visible cost: `/td-flow` appeared in Claude Code autocomplete next to the 10 real commands, looking like an 11th command. Same session also shipped v6.0 (commands renamed /td-* → /td-flow-*) and a v6.0 cleanup pass folding /td-flow-complex-clear into all command-list surfaces.

## Resume note

td-flow framework itself, settled. Ten slash commands under `/td-flow-*`. Contract delivered via one-line `@import` per project; pre-commit hook runs `scripts/smoke.sh` for mechanical sanity (quote-preserving sed trim after v5.5 fix). No skill — retired v6.1; install.sh's retirement-detection block prunes any leftover `~/.claude/skills/td-flow` symlink on next `./install.sh` and prints a one-time notice. See PROJECT.md § Shipped v6.0/v6.1 for the rename + skill-retirement detail. Next session: pick up whatever the user brings.

Side-finding (unaddressed): td-flow's *own* `.git/hooks/pre-commit` is not installed, so commits to this repo don't auto-gate on smoke — run `scripts/smoke.sh` manually before committing here, or `cp hooks/pre-commit .git/hooks/ && chmod +x .git/hooks/pre-commit` to dogfood it.
