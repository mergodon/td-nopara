# State

Project:  td-flow
Topic:    idle
Phase:    closed (2026-05-20)
Blocker:  none
Last:     2026-05-20 — closed: v4.3 framework self-update shipped.

## Resume note

td-flow is the public, file-based, repo-portable solo-dev framework at `mergodon/td-flow` — and this repo IS a td-flow project (eats its own dogfood). Surface: root `CLAUDE.md` contract + six `.td/` docs (PROJECT/WORKWAY/ARCHITECTURE/STATE/BACKLOG, optional DEBUG) + `work/<topic>.md` scratch + seven slash commands (`/td-init`, `/td-clear`, `/td-close`, `/td-refresh`, `/td-mailbox`, `/td-incident`, `/td-park`). Everything else is conversational.

Last shipped (v4.3, 2026-05-20): framework self-update. `/td-close` Step 11 detects when the local td-flow repo is behind `origin/main` and nudges — read-only, never pulls. `/td-refresh` Phase 0 acts on it: re-runs `install.sh`, offers a confirm-first `--ff-only` pull. Rationale in ARCHITECTURE.md § Important decisions; change list in PROJECT.md § Shipped; detail in `git log`.

Nothing pending — 0 open issues, BACKLOG empty, no work files. Next session is probably a different project, or revisiting these hooks once they've hit a real outside codebase. To pick up: PROJECT.md for shape, `git log --oneline -15` for the recent arc, ARCHITECTURE.md for the load-bearing whys. This repo is already initialized — `/td-init` is for fresh projects; `/td-refresh` syncs from canonical.
