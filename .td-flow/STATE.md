# State

Project:  td-flow
Topic:    idle
Phase:    idle
Blocker:  none
Last:     2026-05-26 — shipped v7.2: per-command structural anchors expanded from complex-clear-only to all 10 commands (31 anchors total). Smoke check #8 refactored from a dedicated complex-clear test into a generic data-driven loop (`<command>|<pattern>|<desc>` rows). Two pattern bugs surfaced during build + fixed (`--no-verify`/`--ff-only` confused grep as option flags → added `-e` separator; `exit 0/1/2` literal didn't match health's prose → swapped to `= all OK`). Smoke output stays at 10 OK, broader coverage in same slot. Same-session arc: v6.0 → v6.0 cleanup → v6.1 → v7.0 → v7.1 → v7.2.

## Resume note

td-flow framework itself, settled. Ten slash commands under `/td-flow-*`. State dir is `.td-flow/` (this repo's own + scaffolded into every new project + migrated in existing ones via `/td-flow-refresh`). Contract delivered via one-line `@import` per project. Pre-commit hook reads from `.td-flow/WORKWAY.md` with `.td/` fallback (transition safety, removed in v8.0). No skill (retired v6.1). Smoke runs 10 checks; check #8 asserts 31 per-command load-bearing anchors across all 10 commands — silent regressions on Step headers, commit conventions, protocol fragments, named procedure references all fail the pre-commit hook on the spot. Extending coverage when a new load-bearing piece lands = one array row in `scripts/smoke.sh § ANCHORS`. See PROJECT.md § Shipped v6.0/v6.1/v7.0/v7.1/v7.2 for the namespace consolidation + hardening arc. Next session: pick up whatever the user brings.

Side-finding (unaddressed): td-flow's *own* `.git/hooks/pre-commit` is not installed, so commits to this repo don't auto-gate on smoke — run `scripts/smoke.sh` manually before committing here, or `cp hooks/pre-commit .git/hooks/ && chmod +x .git/hooks/pre-commit` to dogfood it.
