# State

Project:  td-flow
Topic:    section-ownership
Phase:    working
Blocker:  none
Last:     2026-05-22 — shipped v4.9 Piece 2 (/td-refresh take-canonical-and-resplice).

## Resume note

Building v4.9 — five pieces, full plan in `.td/work/section-ownership.md`.

Shipped: Piece 5 (GSD legacy migration dropped); Piece 1 (CLAUDE.md is a managed
file — managed-file preamble + a `td:custom` editable region); Piece 2
(`/td-refresh` rewritten to take-canonical-and-resplice — the section-categorizer
is gone, the reconcile is mechanical and non-interactive). `td:scratch`
considered, dropped — lean.

Remaining: Piece 3 (Bug/Task-only inbox nudges — Ideas/Epics quiet unless
asked), Piece 4 (Idea→Task promotion). Then close as v4.9.

Two things to verify before building: the exact GraphQL mutation to change an
issue's Type (Piece 4), and whether `gh issue list` supports `--type` natively
(Piece 3) or the nudge needs the GraphQL shape `/td-mailbox` Step 2 already uses.
