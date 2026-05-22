# State

Project:  td-flow
Topic:    section-ownership
Phase:    working
Blocker:  none
Last:     2026-05-22 — shipped v4.9 Piece 1 (managed CLAUDE.md + td:custom region).

## Resume note

Building v4.9 — five pieces, full plan in `.td/work/section-ownership.md`.

Shipped: Piece 5 (GSD legacy migration dropped); Piece 1 (CLAUDE.md is now a
managed file — managed-file preamble + a `td:custom` editable region for
project-only rules; everything else is canonical. Mirrored into
templates/CLAUDE.md, still byte-identical). `td:scratch` considered, dropped — lean.

Remaining: Piece 2 (`/td-refresh` take-canonical-and-resplice — uses the
`td:custom` region from Piece 1), Piece 3 (Bug/Task-only inbox nudges), Piece 4
(Idea→Task promotion). Then close as v4.9.

Two things to verify before building: the exact GraphQL mutation to change an
issue's Type (Piece 4), and whether `gh issue list` supports `--type` natively
(Piece 3) or the nudge needs the GraphQL shape `/td-mailbox` Step 2 already uses.
