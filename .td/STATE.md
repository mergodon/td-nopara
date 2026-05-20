# State

Project:  td-flow
Topic:    idle
Phase:    idle
Blocker:  none
Last:     2026-05-21 — shipped v4.5 + dry-trace sanity-check fixups.

## Resume note

td-flow is the public, file-based, repo-portable solo-dev framework at
`mergodon/td-flow` — and this repo is itself a td-flow project (eats its own
dogfood). Surface: root `CLAUDE.md` contract (mirrored byte-for-byte in
`templates/CLAUDE.md`), four standard `.td/` docs (PROJECT/WORKWAY/STATE/BACKLOG)
+ optional DEBUG + `work/<topic>.md` scratch, seven slash commands, and
`install.sh` symlinking it all into `~/.claude/`. Everything else is conversational.

v4.5 (just shipped) replaced the framework's serial "walk one item at a time"
interaction with a uniform **gather → digest → one decision point → batch
execute** model across `/td-mailbox`, `/td-park`, `/td-close`, `/td-refresh`.
`/td-park` is now the single canonical BACKLOG-flush procedure and gained a
consolidation pass (merge related lines, no blind 1:1 mapping).

Nothing pending — 0 open issues, BACKLOG empty, no work files.
`PROJECT.md § Shipped` carries the version history; `git log` has the detail.
