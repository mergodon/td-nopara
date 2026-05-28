# State

Project:  td-flow
Topic:    idle
Phase:    closed (2026-05-28)
Blocker:  none
Last:     2026-05-28 — dropped the `~/.claude/td-templates` symlink; commands now read templates from the repo clone (`~/projects/td-flow/templates/`). Bundled the stale `templates/td/` → `templates/td-flow/` DEBUG/health pointer fix (broken since the v7.0 dir rename).

## Resume note

Framework consolidated around the `td-flow` namespace; v7.5 wrapped two small pieces (contract tightening post-v7.4 + Bug #14 backtick-handling fix from tasmanvisa-web — both detailed in PROJECT.md § Shipped). Contract delivered via one-line `@import` per project; no skill (retired v6.1); no saved-starter templates (removed v7.4). Pre-commit hook gated by `scripts/smoke.sh`, which strips outer backticks at extraction (v7.5 — Bug #14) so authors can use markdown-formatted `` `Test command:` `` lines without surprises. Eat-own-dog-food: this repo's own WORKWAY uses the backtick-wrapped form, so the framework's pre-commit hook tests the fix on every commit.

If a future session opens here: this is the framework repo itself. Read `CLAUDE.md` for the contract, `PROJECT.md § Shipped` for the version arc, `WORKWAY.md` for how to test/ship. Nothing pending — pick up whatever the user brings.

Two transition pieces still live on disk, scheduled for v8.0 cleanup:

- `.td/` fallback in `hooks/pre-commit` + `scripts/smoke.sh` (preserves un-migrated v6.x projects)
- `.td → .td-flow` compat symlink scaffolding in `/td-flow-init` + `/td-flow-refresh` (preserves any user-side hardcoded `.td/` references)

Both drop in v8.0 once the portfolio has fully migrated. No urgency.
