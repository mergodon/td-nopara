# State

Project:  td-flow
Topic:    enrich-clear-close
Phase:    shipped (awaiting test)
Blocker:  none
Last:     2026-05-20 — shipped /td-clear mailbox-snapshot + /td-close unresolved-gate; Closes #10.

## Resume note

**Active piece:** #10 shipped (auto-closes on push). /td-clear now writes a `[mailbox]` snapshot at the top of Resume notes; /td-close gates on open Bug/Task (Epics + Ideas don't gate per [[feedback-epic-not-work-unit]]). Awaiting user test — if good, Topic flips to idle.

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
