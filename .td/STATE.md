# State

Project:  td-flow
Topic:    handoff hardening (stack-reality-check + doc hygiene at /td-clear and /td-close)
Phase:    shipped piece 1 of 2 — hygiene + mechanical stack diff (2026-05-19); next: /td-mailbox + sub-issue tracker model
Blocker:  none
Last:     2026-05-19 — **Shipped mechanical stack-reality-check + doc-hygiene pass in `/td-close` and `/td-clear`.** Triggered by an au-dual-track transcript review: `/td-close` had fixed Livewire 3→4 + Sentry-added drift in PROJECT.md at close, but the drift had accumulated silently across many sessions because the "stack signals changed → flag" drift signal in CLAUDE.md was too soft (relied on Claude noticing). Fix: `/td-close` Step 6 is now mechanical (enumerate dep files present — `package.json`/`composer.json`/`pyproject.toml`/`requirements.txt`/`Gemfile`/`go.mod`/`Cargo.toml`; diff top-level deps vs PROJECT.md § Stack; surface one-liners for y/n/edit). Step 7 is the doc-hygiene pass: re-articulates the keep/clear filter and walks each `.td/` doc through it. `/td-clear` got a lightweight version: `git log --since="<STATE.Last>" --name-only -- <dep files>` heads-up (flag, don't fix; full check happens at /td-close), plus a hygiene reminder in the STATE handoff step. CLAUDE.md got a "Doc hygiene" paragraph at the end of § The docs articulating the principle ("the next session loads these docs cold and assumes everything in them is true"), plus the soft drift-signal line replaced with explicit mechanical-safety-net reference. templates/CLAUDE.md mirrored byte-identical.

## Resume note

Next piece up: **`/td-mailbox` (merges `/td-inbox` + `/td-outbox`) with sub-issue tracker model for outbound.** Validation completed earlier this session — proved end-to-end that GitHub's `addSubIssue` GraphQL mutation works cross-repo within mergodon org, that the receiver's native `parent` field surfaces source bidirectionally, that `subIssuesSummary` updates on state transitions (eventually consistent, ~seconds), and that one aggregate query against all parents in this repo returns every cross-repo child with comments inline. Validation artifacts (td-flow#1 + td-registry#1) are closed but exist as history.

Design for the mailbox piece:

- **Single command `/td-mailbox`.** Replaces both `/td-inbox` and `/td-outbox`. Inbound section reuses current /td-inbox query, with one filter: skip issues whose body contains `<!-- td-mailbox-tracker -->` (the sentinel marking the outbound tracker Epic). Outbound section uses aggregate query: `repository.issues(states:OPEN) { ... subIssues { ... filter where repo != current } ... }` — one round trip, comments inline, exact membership.
- **Filing rule (CLAUDE.md addition).** Every cross-repo issue filed FROM this project becomes a sub-issue of one parent in this repo: an existing Epic if the work belongs to one, otherwise the **outbound tracker Epic** (auto-created on first orphan filing, body opens with `<!-- td-mailbox-tracker -->` sentinel + a "do not close" note).
- **The `**From:** <project>` body marker stays.** Different role now — the GitHub-native parent linkage handles sender-side queries; the body marker handles human readability in non-GraphQL surfaces (gh CLI, etc.) and gives the receiver a stable "from project X" signal that's independent of the GH account that opened the issue.
- **Per-item walk preserved.** Inbound: close/comment/skip. Outbound: comment/verify/reopen/skip. Single end-summary.
- **Constraint to remember:** one sub-issue can only have one parent (validated). So Epic-attached sub-issues are NOT also attached to the outbound tracker. The aggregate query catches both regardless.
- **Migration / backfill** at adoption: walk existing open cross-repo issues via the old `**From:** <project>` org-wide search, attach each as sub-issue of the outbound tracker (or relevant Epic). After backfill, /td-mailbox is self-contained.

Files to touch in commit 2:
- ADD `commands/td-mailbox.md`
- DEL `commands/td-inbox.md`, `commands/td-outbox.md` (install.sh's symlink loop is dynamic — cleanup is automatic on next install)
- EDIT `CLAUDE.md` (§ Cross-repo replaces "Inbox + outbox are paired" with mailbox + filing rule; § Where things go replaces inbox/outbox triggers with mailbox and augments "file an issue for X" routing to include addSubIssue; § Slash commands swaps the two rows for one)
- EDIT `templates/CLAUDE.md` (mirror)
- EDIT `skill/SKILL.md` (description line + slash command list, 8→7)
- EDIT `README.md` (symlinks list, slash commands table row, examples, "Inbox + outbox are paired" paragraph)
- EDIT `.td/WORKWAY.md` (8→7 commands list)
- EDIT `.td/STATE.md` (move to shipped piece 2)

Open question for piece 2 to decide as we write the command:
- Backfill: ship the migration script as part of the command (one-shot), or as a one-time conversational walkthrough triggered the first time `/td-mailbox` runs without finding the tracker? Likely the latter — keeps the command file slim.

Out of scope for this session (parked):
- The BACKLOG already had a "Piece 2: slash-command enrichment" item from 2026-05-17 that mentions auto-register in $TD_REGISTRY at /td-init, surfacing inbox/outbox in /td-clear resume note, and checking unresolved issues at /td-close. Today's commits cover SOME of that scope (handoff hardening at clear/close) but not the $TD_REGISTRY auto-register piece — that's still pending.
- Real-project validation of the v4.0 framework on a brownfield repo — still scheduled but not started.
