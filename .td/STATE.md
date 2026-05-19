# State

Project:  td-flow
Topic:    idle
Phase:    shipped — `/td-mailbox` post-roleplay refinements (2026-05-19)
Blocker:  none
Last:     2026-05-19 — **Shipped post-roleplay refinements to `/td-mailbox`** after live roleplay validation surfaced four real gaps: (A) `Feature` Issue Type had been retired from the mergodon org mid-session, but the framework still listed it as a possible type — scrubbed throughout (CLAUDE.md, templates, all command files, README); `Feature` work now files as `Task`. (B+C) Step 4 backfill check was first-run-only — should be **every run** to catch issues filed via web UI or older tooling that skip the `addSubIssue` step; rewrote as continuous orphan detection using each issue's native `parent` field (no diffing against the aggregate query needed). (D) Step 7 only suggested "gentle ping" for long-pending outbound; added "Stale — close as not_planned?" recommendation for >60-day cases + `close` action with the `--reason "not planned" --comment` form. (E) Dropped the `**Source:**` line from the cross-repo issue body convention — sub-issue parent linkage IS the sender-side reference now; the body should just have `**From:**` + ask + why. Live-tested the new orphan detection end-to-end: filed a deliberate orphan in td-registry, ran the search, confirmed it was detected; ran backfill, confirmed it was removed from orphan set on re-run. False-positive filter validated — the search matched an unrelated rgb-ggbuddy issue mentioning "td-flow" but the body-marker filter correctly excluded it. All 6 roleplay artifacts (td-flow#2-4, td-registry#2-4) closed with informative comments. Earlier today: shipped mechanical stack-reality-check + doc hygiene at /td-clear and /td-close (commit 32a5f3b); shipped /td-mailbox + sub-issue tracker model (commit 886a8a3).

## Resume note

td-flow at 7 slash commands. The cross-repo work surface (`/td-mailbox`) now has:
- One aggregate query for inbound + outbound.
- Continuous orphan detection (every run) — catches manual-UI filings that skip `addSubIssue`.
- Tracker auto-create on first orphan filing (body sentinel `<!-- td-mailbox-tracker -->`).
- Per-direction action sets including `close` for our own stale outbound (reason: not planned).
- Stale-close recommendation kicks in at 60 days awaiting reply with no movement.

Doc hygiene is mechanical at `/td-clear` (heads-up) and `/td-close` (full diff vs PROJECT.md § Stack).

Issue Types in use: Idea, Task, Bug, Epic. Feature was retired from the mergodon org mid-session and from the framework — Task is the generic "new work" type now.

**Open follow-ups (in priority order):**

1. **First real-project run of `/td-mailbox`.** Synthetic-validated twice this session (initial GraphQL plumbing + full roleplay walk). Next step: run it on a real project that already has open cross-repo issues. The continuous orphan detection will exercise on whatever's been filed manually.

2. **First real `/td-close` run with the new stack-reality-check.** au-dual-track or any other Livewire project would be a natural test — that's the project whose transcript triggered the upgrade.

3. **The `/td-init` auto-register-in-$TD_REGISTRY piece** from the 2026-05-17 BACKLOG item is still pending. Today shipped the /td-clear + /td-close enhancements from that item; the /td-init auto-registration is the remaining sub-piece.

4. **Brownfield-detection real-project validation** of the v4.0 framework — still scheduled, unstarted.
