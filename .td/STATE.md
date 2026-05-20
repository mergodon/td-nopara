# State

Project:  td-flow
Topic:    idle
Phase:    closed (2026-05-20)
Blocker:  none
Last:     2026-05-20 — shipped /td-refresh Phase 0 (framework sync).

## Resume note

**Post-v4.2 (2026-05-20) — framework self-update, two pieces:** (1) `/td-close` Step 11 — read-only check after a successful close; nudges if the td-flow repo is behind origin, never pulls ("Tell the user" → Step 12). (2) `/td-refresh` Phase 0 (new Step 0) — syncs the framework *before* the project refresh: re-runs `install.sh` always (idempotent; catches stale symlinks like the `/td-incident` miss this session), offers a confirm-first `--ff-only` pull if behind. Detect-at-close, act-at-refresh. Both resolve the framework repo via the command symlink (clone-path-independent). Detail in `git log`.

v4.2 shipped: ARCHITECTURE.md is now the sixth canonical `.td/` doc, with hooks into `/td-init` (scaffold), `/td-clear` (drift heads-up), `/td-close` (hygiene pass), `/td-refresh` (Phase 4 existence check), and `/td-incident` (architectural-learning capture at close-out). `/td-mailbox` gained the `start` verb to activate an inbound issue as STATE.Topic with auto `Closes #N` staging. `/td-clear` + `/td-close` are now mailbox-aware (snapshot at handoff, open-Bug/Task gate at wrap — Epics+Ideas don't gate per [[feedback-epic-not-work-unit]]). A same-session simplification pass tightened 9 surfaces without losing capability.

Mailbox empty. Open issues: 0. PROJECT.md § Active scope is `(none)` awaiting real-project use of v4.2 conventions. Next session: probably either a different project, or revisiting any of these v4.2 hooks once they've hit a real codebase.

If picking this up later: read PROJECT.md § Shipped for the v4.2 entry (full change list), `git log --oneline -15` for the commit arc, `.td/ARCHITECTURE.md` for the load-bearing whys. Framework is in good shape — no follow-up debt.

td-flow is the public, file-based, repo-portable solo-developer framework hosted at `mergodon/td-flow`. It eats its own dog food — this repo IS a td-flow project. Current surface: root `CLAUDE.md` contract + 5 `.td/` docs (PROJECT/WORKWAY/STATE/BACKLOG, optional DEBUG) + `work/<topic>.md` scratch + **7 slash commands** (`/td-init`, `/td-clear`, `/td-close`, `/td-refresh`, `/td-mailbox`, `/td-incident`, `/td-park`). Everything else is conversational.

Cross-repo state per project = two pieces: a `.td/PROJECT.md § Cross-repo` markdown list + `**From:** <project>` body marker on every cross-repo filing. No tracker Epic, no external registry repo, no SERVICES.md / NAMING.md / `$TD_REGISTRY` env var. The whole concept retired in v4.1 on 2026-05-20. Friendly-name resolution: PROJECT.md H1 → directory basename.

Doc hygiene is mechanical at `/td-clear` (stack-drift heads-up + keep/clear filter on STATE handoff) and `/td-close` (full dep-file diff vs PROJECT.md § Stack, plus per-doc hygiene pass including cross-repo registry drift check). Stack drift can't accumulate silently across sessions.

Issue Types in use across the mergodon org: Idea, Task, Bug, Epic (Feature was retired mid-session 2026-05-19).

Open follow-ups live as GitHub Issues (`gh issue list --state open` to see). None open right now — #7–#10 all closed (context7 + subagent paths declined as not-planned; ARCHITECTURE.md and the /td-clear+/td-close enrichments shipped in v4.2).

If picking this up later: read this note → read `PROJECT.md` for shape → `git log --oneline -20` for recent arc → `gh issue list --state open` for parked work. If the framework needs a doc refresh from canonical, run `/td-refresh`. If something's actively going to be worked on, `/td-init` is for fresh projects only — this one's already initialized.
