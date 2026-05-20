# State

Project:  td-flow
Topic:    idle
Phase:    idle
Blocker:  none
Last:     2026-05-20 — session shipped: ARCHITECTURE.md as sixth standard doc (#9), /td-mailbox start/status verbs (then status retired), /td-clear+/td-close mailbox-aware (#10), simplify pass across 9 surfaces. Roleplay test passed.

## Resume note

No active piece.

This session added the sixth canonical doc (ARCHITECTURE.md) with hooks into /td-init scaffold, /td-clear drift heads-up, /td-close hygiene pass, /td-refresh Phase 4 existence check, /td-incident architectural-learning capture. /td-clear + /td-close gained mailbox awareness (snapshot + open-Bug/Task gate). Then a complexity review pruned 9 surfaces: dropped /td-mailbox outbound `status` verb, consolidated /td-clear heads-ups, single /td-incident close-out capture prompt, fixed /td-refresh Step 1 short-circuit bug, halved CLAUDE.md slash-commands list, restructured CLAUDE.md § Cross-repo for sharper structure.

Mailbox: empty (3 self-filed issues from prior session all closed today: #7 not planned, #8 not planned, #9 shipped, #10 shipped). 4 commits ahead in this session — none holding.

td-flow is the public, file-based, repo-portable solo-developer framework hosted at `mergodon/td-flow`. It eats its own dog food — this repo IS a td-flow project. Current surface: root `CLAUDE.md` contract + 5 `.td/` docs (PROJECT/WORKWAY/STATE/BACKLOG, optional DEBUG) + `work/<topic>.md` scratch + **7 slash commands** (`/td-init`, `/td-clear`, `/td-close`, `/td-refresh`, `/td-mailbox`, `/td-incident`, `/td-park`). Everything else is conversational.

Cross-repo state per project = two pieces: a `.td/PROJECT.md § Cross-repo` markdown list + `**From:** <project>` body marker on every cross-repo filing. No tracker Epic, no external registry repo, no SERVICES.md / NAMING.md / `$TD_REGISTRY` env var. The whole concept retired in v4.1 on 2026-05-20. Friendly-name resolution: PROJECT.md H1 → directory basename.

Doc hygiene is mechanical at `/td-clear` (stack-drift heads-up + keep/clear filter on STATE handoff) and `/td-close` (full dep-file diff vs PROJECT.md § Stack, plus per-doc hygiene pass including cross-repo registry drift check). Stack drift can't accumulate silently across sessions.

Issue Types in use across the mergodon org: Idea, Task, Bug, Epic (Feature was retired mid-session 2026-05-19).

Open follow-ups live as GitHub Issues (`gh issue list --state open` to see). Currently 4 open after this session's close:
- #7 Task — context7 step in the rhythm if it surfaces as a missing pattern
- #8 Task — subagent / parallel-piece path for features with 4+ independent pieces
- #9 Idea — decide whether ARCHITECTURE.md should be a standard .td/ doc
- #10 Task — enrich /td-clear (inbox+outbox surface) and /td-close (unresolved-issues check)

If picking this up later: read this note → read `PROJECT.md` for shape → `git log --oneline -20` for recent arc → `gh issue list --state open` for parked work. If the framework needs a doc refresh from canonical, run `/td-refresh`. If something's actively going to be worked on, `/td-init` is for fresh projects only — this one's already initialized.
