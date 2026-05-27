# State

Project:  td-flow
Topic:    contract-tightening
Phase:    shipping
Blocker:  none
Last:     2026-05-28 — applied 5 tightening fixes to CLAUDE.md + 2 to WORKWAY.md + 1 ripple to PROJECT.md; smoke clean.

## Resume note

Post-v7.4 content-review pass on the contract — origin: user noticed `~/.claude/td-rider-contract.md` is 93.8k chars (over the 40k warning), asked to apply the same lean-and-loaded-only-if-needed audit to td-flow's. Contract is at 210 lines / ~22k chars; under threshold, lean by structural standards, so this pass tightens within the existing shape (preserves spirit) rather than splitting content out to skills/rules (a separate, bigger conversation if the size ever matters here).

Fixes shipped:
- "Where things go" — trimmed three oversized entries (lines for "park this to GH", "file an issue for X", "snapshot this") that had grown procedural detail belonging in command files. Detail verified to live in `/td-flow-park` Step 5, `/td-flow-snapshot`, and `## Cross-repo § Filing workflow` — entries now point to those.
- BACKLOG flush dedupe — line in `## Drift signals` ("BACKLOG > 15 items") and the `## Where things go` "park this" line both trimmed; canonical statement lives once in `## The docs` BACKLOG.md description.
- `## Framework guidelines` "Never run /init" — compressed from 3 sentences to 1, same content.
- `## The slash commands` intro — "Ten commands" → "Each command" so the count doesn't drift when an 11th lands. Ripple: PROJECT.md "Ten slash commands" → "Slash commands"; WORKWAY's "CLAUDE.md's 'Ten commands' trigger map" reference updated to "`## The slash commands` trigger map".
- WORKWAY pre-ship checklist intro — dropped the "11 OK on clean state" magic number.

Net: CLAUDE.md ~22k → ~21.5k chars (-6%); line count unchanged at 210 (compressions within lines, no whole lines dropped). Smoke 11 OK 0 WARN 0 FAIL. Spirit preserved throughout — three findings tagged [verify] / [extend] / [skip] in the review left for explicit user direction.

If a future session opens here: this is the framework repo itself. Read `CLAUDE.md` for the contract, `.td-flow/PROJECT.md § Shipped` for the version arc, `WORKWAY.md` for how to test/ship.

Two transition pieces still live on disk, scheduled for v8.0 cleanup:

- `.td/` fallback in `hooks/pre-commit` + `scripts/smoke.sh` (preserves un-migrated v6.x projects)
- `.td → .td-flow` compat symlink scaffolding in `/td-flow-init` + `/td-flow-refresh` (preserves any user-side hardcoded `.td/` references)

Both drop in v8.0 once the portfolio has fully migrated. No urgency.
