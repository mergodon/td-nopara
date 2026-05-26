# State

Project:  td-flow
Topic:    idle
Phase:    idle
Blocker:  none
Last:     2026-05-26 — shipped v7.1: smoke.sh gained 3 drift-catcher checks (cross-reference, frontmatter validity, complex-clear structural anchors). Triggered by an onboarding audit of `/td-flow-complex-clear` — the audit was clean but surfaced that the drift class which left complex-clear off canonical lists for several versions had no mechanical detector. Now it does. Smoke reports 10 OK on clean state, up from 7. Same-session arc: v6.0 (commands renamed) → v6.0 cleanup → v6.1 (skill retired) → v7.0 (state dir renamed) → v7.1 (smoke hardened).

## Resume note

td-flow framework itself, settled. Ten slash commands under `/td-flow-*`. State dir is `.td-flow/` (this repo's own + scaffolded into every new project + migrated in existing ones via `/td-flow-refresh`). Contract delivered via one-line `@import` per project. Pre-commit hook reads from `.td-flow/WORKWAY.md` with `.td/` fallback (transition safety, removed in v8.0). No skill (retired v6.1). Smoke now runs 10 checks (added v7.1: cross-reference, frontmatter, complex-clear structural). See PROJECT.md § Shipped v6.0/v6.1/v7.0/v7.1 for the namespace consolidation + hardening arc. Next session: pick up whatever the user brings.

Side-finding (unaddressed): td-flow's *own* `.git/hooks/pre-commit` is not installed, so commits to this repo don't auto-gate on smoke — run `scripts/smoke.sh` manually before committing here, or `cp hooks/pre-commit .git/hooks/ && chmod +x .git/hooks/pre-commit` to dogfood it.
