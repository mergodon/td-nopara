# State

Project:  td-flow
Topic:    section-ownership
Phase:    v4.9 built — ready to close
Blocker:  none
Last:     2026-05-22 — added a session doc-sync to /td-clear (post-review).

## Resume note

v4.9 — five pieces, full plan in `.td/work/section-ownership.md`. All shipped:

- Piece 5 — GSD legacy migration dropped.
- Piece 1 — CLAUDE.md is a managed file + a `td:custom` region.
- Piece 2 — `/td-refresh` rewritten to take-canonical-and-resplice, then trimmed
  to framework-sync only (BACKLOG flush + cross-repo drift dropped — scope creep).
- Piece 3 — inbox nudges scoped to Bugs/Tasks (Ideas/Epics quiet unless asked).
- Piece 4 — Idea→Task promotion (`/td-mailbox` `promote` + auto-promote on
  `start`, "show me the ideas" conversational route).
- Plus (post-review): `/td-clear` gained a session doc-sync — it now syncs
  PROJECT.md/WORKWAY.md to what the session changed, not just STATE.

Ready to close as v4.9 — `/td-close`: PROJECT.md § Shipped entry, STATE to
closed shape, doc-hygiene pass. `.td/work/section-ownership.md` folds-and-deletes
at close.
