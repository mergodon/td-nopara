# State

Project:  td-flow
Topic:    idle
Phase:    closed (2026-05-21)
Blocker:  none
Last:     2026-05-21 — closed.

## Resume note

td-flow is the public, file-based, repo-portable solo-dev framework at
`mergodon/td-flow` — and this repo is itself a td-flow project (eats its own
dogfood). Surface: root `CLAUDE.md` contract (mirrored byte-for-byte in
`templates/CLAUDE.md`), four standard `.td/` docs (PROJECT/WORKWAY/STATE/BACKLOG)
+ optional DEBUG + `work/<topic>.md` scratch, seven slash commands, and
`install.sh` symlinking it all into `~/.claude/`. Everything else is conversational.

Latest: v4.5 — the batch-decide interaction model. The serial "walk one item at
a time" pattern is gone from `/td-mailbox`, `/td-park`, `/td-close`, `/td-refresh`;
all four now gather → present one digest → take decisions in a single pass →
batch execute. `/td-park` is the single canonical BACKLOG-flush procedure
(consolidates related lines, no blind 1:1 mapping); `/td-close` Step 3 and
`/td-refresh` Phase 2 reference it. `PROJECT.md § Shipped` carries the version
history; `git log` has the detail.

Nothing pending — 0 open issues, BACKLOG empty, no work files. Next session:
`/td-refresh` syncs a consuming project from canonical, `/td-init` bootstraps a
fresh one.
