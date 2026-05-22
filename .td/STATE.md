# State

Project:  td-flow
Topic:    section-ownership
Phase:    working
Blocker:  none
Last:     2026-05-22 — shipped v4.9 Piece 5 (dropped GSD legacy migration).

## Resume note

Building v4.9 — five pieces, full plan in `.td/work/section-ownership.md`.

Shipped: Piece 5 — GSD legacy migration dropped from `/td-init` + `SKILL.md`
(dead code since v3; "(the gsd-2 mistake)" attribution dropped from PROJECT.md).

Remaining: Piece 1 (managed-file header + `td:custom` region in CLAUDE.md),
Piece 2 (`/td-refresh` take-canonical-and-resplice — depends on 1), Piece 3
(Bug/Task-only inbox nudges), Piece 4 (Idea→Task promotion). Then close as v4.9.

Two things to verify before building: the exact GraphQL mutation to change an
issue's Type (Piece 4), and whether `gh issue list` supports `--type` natively
(Piece 3) or the nudge needs the GraphQL shape `/td-mailbox` Step 2 already uses.
