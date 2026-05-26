# State

Project:  td-flow
Topic:    idle
Phase:    idle
Blocker:  none
Last:     2026-05-26 — shipped v7.0: per-project state dir renamed `.td/` → `.td-flow/`. Symlink-first migration via `/td-flow-refresh` Step 1.7 (new). Framework code prefers `.td-flow/` with `.td/` fallback as transition safety net. Per-machine v7.0 banner gated by `~/.claude/.td-flow-v7-acked` marker. Same-session arc complete: v6.0 (commands renamed) → v6.0 cleanup → v6.1 (skill retired) → v7.0 (state dir renamed) — the whole surface now carries the `td-flow` prefix consistently. Live install + smoke clean. One real audit win: `hooks/pre-commit` (no `.sh` extension) was missed by both v6.0 and v7.0 bulk replaces — caught and rewritten by hand.

## Resume note

td-flow framework itself, settled. Ten slash commands under `/td-flow-*`. State dir is `.td-flow/` (this repo's own + scaffolded into every new project + migrated in existing ones via `/td-flow-refresh`). Contract delivered via one-line `@import` per project. Pre-commit hook reads from `.td-flow/WORKWAY.md` with `.td/` fallback (transition safety, removed in v8.0). No skill (retired v6.1). See PROJECT.md § Shipped v6.0/v6.1/v7.0 for the namespace consolidation arc. Next session: pick up whatever the user brings.

Side-finding (unaddressed): td-flow's *own* `.git/hooks/pre-commit` is not installed, so commits to this repo don't auto-gate on smoke — run `scripts/smoke.sh` manually before committing here, or `cp hooks/pre-commit .git/hooks/ && chmod +x .git/hooks/pre-commit` to dogfood it.
