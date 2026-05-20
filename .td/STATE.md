# State

Project:  td-flow
Topic:    idle
Phase:    closed (2026-05-20)
Blocker:  none
Last:     2026-05-20 — shipped v4.4: ARCHITECTURE.md removed as a standard doc; follow-up dropped /td-refresh's now-vacuous Phase 4 (5 phases → 4).

## Resume note

td-flow is the public, file-based, repo-portable solo-dev framework at `mergodon/td-flow` — and this repo IS a td-flow project (eats its own dogfood). Surface: root `CLAUDE.md` contract + four standard `.td/` docs (PROJECT/WORKWAY/STATE/BACKLOG) + optional DEBUG + `work/<topic>.md` scratch + seven slash commands (`/td-init`, `/td-clear`, `/td-close`, `/td-refresh`, `/td-mailbox`, `/td-incident`, `/td-park`). Everything else is conversational.

Last shipped (v4.4, 2026-05-20): ARCHITECTURE.md dropped as a standard `.td/` doc. It was added in v4.2 (same day), audited as ~95% redundant with PROJECT.md § Stack/§ Shipped + CLAUDE.md § Cross-repo + WORKWAY § Framework specifics, and never sat in the every-session read set — so it rarely fired. Removed along with the same-session `feat(architecture-draft)` drafting feature: shipped and reverted within the day, the td-bus pattern. The standard set is back to four docs, and `/td-refresh` dropped its now-vacuous Phase 4 (the standard-docs existence check) — five phases to four. The one non-redundant guard it held ("don't collapse detect-at-close/act-at-refresh") was folded into PROJECT.md § Shipped v4.3 before deletion. Full change list in PROJECT.md § Shipped v4.4; detail in `git log`.

Also shipped this session (2026-05-20): `/td-mailbox` now reports Epics as planning surfaces — no `start` nudge on a parent Epic; Epics are picked up via their child Bug/Task issues, matching `/td-close` Step 2's Bug/Task-only gate.

Nothing pending — 0 open issues, BACKLOG empty, no work files. To pick up: PROJECT.md for shape, `git log --oneline -15` for the recent arc. This repo is already initialized — `/td-init` is for fresh projects; `/td-refresh` syncs from canonical.
