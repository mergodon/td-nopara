# State

Project:  td-flow
Topic:    idle
Phase:    shipped — `/td-mailbox` + sub-issue tracker model (2026-05-19)
Blocker:  none
Last:     2026-05-19 — **Shipped `/td-mailbox` — unified cross-repo view backed by GitHub-native sub-issues.** Replaces the previous `/td-inbox` + `/td-outbox` split. Mechanism validated end-to-end in this session by filing a test child into td-registry, attaching as sub-issue of a test Epic in td-flow, exercising state transitions, and probing edge cases. Findings: `addSubIssue` mutation works cross-repo within mergodon org; the receiver gets a native `parent` field (bidirectional linkage, no body-parsing); `subIssuesSummary` updates eventually-consistently within seconds on state change; one aggregate query against all parents in this repo returns every cross-repo child with comments inline (no org-wide search); one constraint to remember — a sub-issue can only have one parent (so Epic-attached children are NOT also attached to the outbound tracker, but the aggregate query catches both). Filing rule (added to CLAUDE.md routing): every cross-repo issue becomes a sub-issue of a parent in this repo — an existing Epic if the work belongs to one, else the auto-created outbound tracker Epic (body opens with `<!-- td-mailbox-tracker -->` sentinel; never closed). The `**From:** <project>` body marker stays on every filing — different role: human-readable identifier for non-GraphQL surfaces (`gh issue view`) and receiver-side source signal independent of GH account. `/td-mailbox` command file written (~200 lines, includes first-run backfill flow for projects with pre-existing cross-repo issues filed before the tracker model existed). `/td-inbox` and `/td-outbox` command files deleted; install.sh's symlink loop is dynamic so cleanup happens on next `./install.sh`. CLAUDE.md (root + templates byte-identical): § Cross-repo gets the new `/td-mailbox is the unified cross-repo view` + `Outbound tracking via sub-issues` paragraphs; § Where things go updates the inbox/outbox conversational triggers to /td-mailbox and augments "file an issue for X" with the addSubIssue step; § Slash commands swaps two rows for one. README, SKILL.md, .td/WORKWAY.md updated for the 8→7 command count and new naming. Earlier today (commit 32a5f3b): mechanical stack-reality-check + doc-hygiene pass landed in `/td-close` and `/td-clear` (the au-dual-track transcript finding).

## Resume note

td-flow at this point: 7 slash commands. Cross-repo work has a single command surface (`/td-mailbox`) backed by GitHub-native sub-issue linkage. Doc hygiene is now mechanical at both handoff (`/td-clear`) and wrap (`/td-close`) — dependency drift can no longer accumulate silently across sessions.

**Open follow-ups (in priority order):**

1. **First real-project run of `/td-mailbox`.** Validated synthetically this session (created + closed test issues in td-flow and td-registry); next step is to run it in anger on a project that already has open cross-repo issues. The first run there will exercise the backfill path (legacy filings discovered via `**From:**` search, offered for one-shot attach to the tracker). Worth doing on a project with a few known outbound issues, not the busiest one.

2. **First real `/td-close` run with the new stack-reality-check.** Will exercise the mechanical dep-file diff vs PROJECT.md § Stack and the doc-hygiene pass across all `.td/` docs. au-dual-track or a similar Livewire project would be a natural test since that's the project whose transcript triggered the upgrade.

3. **The `/td-init` auto-register-in-$TD_REGISTRY piece** is still pending from the 2026-05-17 BACKLOG item ("Piece 2: slash-command enrichment"). Today shipped the /td-clear + /td-close enhancements from that item; the /td-init auto-registration is the remaining sub-piece.

4. **Brownfield-detection real-project validation** of the v4.0 framework is still scheduled and unstarted.

5. **Validation artifacts to clean up (cosmetic, not blocking):** td-flow#1 and td-registry#1 are closed but still exist as `[VALIDATION]` issues from this session's playground. They won't appear in any open-issue query but will surface in any cycling-closed view. Acceptable.
