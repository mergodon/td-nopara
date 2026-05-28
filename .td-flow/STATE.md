# State

Project:  td-flow
Topic:    idle
Phase:    shipping
Blocker:  none
Last:     2026-05-28 — fixed Bug #14 (pre-commit backtick handling). Two pieces shipped today; ready to re-run /td-flow-close.

## Resume note

Two pieces shipped 2026-05-28 on top of the v7.4 close:

**1. Contract tightening (commit 00c9450).** Post-v7.4 content-review pass — origin: user noticed `~/.claude/td-rider-contract.md` is 93.8k chars (over the 40k warning), asked to apply the same lean-and-loaded-only-if-needed audit to td-flow's. Contract was at 210 lines / ~23k chars; under threshold, lean by structural standards, so the pass tightened within the existing shape (preserves spirit) rather than splitting content to skills/rules (a separate, bigger conversation if size ever matters here). Trimmed three oversized "Where things go" router entries (procedural detail verified to live in command files / `## Cross-repo § Filing workflow`), deduped 3 BACKLOG flush mentions to 1, compressed "Never run /init", made "Ten commands" count-free with ripple to PROJECT.md + WORKWAY. Net −1,413 chars (−6%).

**2. Bug #14 fix (this piece).** tasmanvisa-web filed 2026-05-27: the `eval "$CMD"` in `hooks/pre-commit` triggers command substitution when WORKWAY's `Test command:` line uses markdown-style backticks. Bug body proposed 3 fixes; picked option 1 (strip outer backticks in awk extractor) — option 2 (`bash -c` instead of `eval`) was misdiagnosed in the bug body (same outcome — both re-parse as shell), option 3 (document the constraint) was tasmanvisa-web's local workaround (discipline, not engineering). Fix: extended the sed pipeline in both `hooks/pre-commit` and `scripts/smoke.sh` (they share the extractor verbatim) from `[[:space:]]+` → `[[:space:]\`]+` at the trim boundaries. Eat-own-dog-food: WORKWAY's own Test command now wrapped in backticks, so the framework's own pre-commit hook exercises the fix on every commit — no separate test fixture needed.

Smoke 11 OK 0 WARN 0 FAIL. tasmanvisa-web can revert their local Option-3 workaround (commit eceb154) next pull — informational only, not our action.

If a future session opens here: this is the framework repo itself. Read `CLAUDE.md` for the contract, `.td-flow/PROJECT.md § Shipped` for the version arc, `WORKWAY.md` for how to test/ship. /td-flow-close was invoked then aborted to fix #14 first — re-running it now is the natural next step.

Two transition pieces still live on disk, scheduled for v8.0 cleanup:

- `.td/` fallback in `hooks/pre-commit` + `scripts/smoke.sh` (preserves un-migrated v6.x projects)
- `.td → .td-flow` compat symlink scaffolding in `/td-flow-init` + `/td-flow-refresh` (preserves any user-side hardcoded `.td/` references)

Both drop in v8.0 once the portfolio has fully migrated. No urgency.
