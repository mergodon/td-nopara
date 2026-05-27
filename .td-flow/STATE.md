# State

Project:  td-flow
Topic:    idle
Phase:    closed (2026-05-26)
Blocker:  none
Last:     2026-05-27 — removed saved-starter template functionality entirely (--template flag, save-as-template path, templates/<name>/ subdirs). Closes #13.

## Resume note

Framework consolidated around the `td-flow` namespace across the whole surface — project name, GH slug, local clone path, contract file, slash commands (`/td-flow-*`), per-project state dir (`.td-flow/`), template scaffold (`templates/td-flow/`). Ten slash commands; contract delivered via one-line `@import` per project; no skill (retired v6.1). Pre-commit hook gated by `scripts/smoke.sh` — 11 OK on clean state, including 31 per-command load-bearing anchors that fail-fast on silent structural regressions and a drift-catcher that surfaces stale `.git/hooks/pre-commit` before install.sh idempotency self-heals it.

If a future session opens here: this is the framework repo itself. It IS a td-flow project. Read `CLAUDE.md` for the contract, `.td-flow/PROJECT.md § Shipped` for the version arc, `WORKWAY.md` for how to test/ship. Nothing pending — pick up whatever the user brings.

Two transition pieces still live on disk, scheduled for v8.0 cleanup:

- `.td/` fallback in `hooks/pre-commit` + `scripts/smoke.sh` (preserves un-migrated v6.x projects)
- `.td → .td-flow` compat symlink scaffolding in `/td-flow-init` + `/td-flow-refresh` (preserves any user-side hardcoded `.td/` references)

Both drop in v8.0 once the portfolio has fully migrated. No urgency.
