# State

Project:  td-flow
Topic:    section-ownership
Phase:    working
Blocker:  none
Last:     2026-05-22 — shipped v4.9 Piece 3 (Bug/Task-only inbox nudges).

## Resume note

Building v4.9 — five pieces, full plan in `.td/work/section-ownership.md`.

Shipped: Piece 5 (GSD legacy migration dropped); Piece 1 (CLAUDE.md managed file
+ `td:custom` region); Piece 2 (`/td-refresh` take-canonical-and-resplice);
Piece 3 (inbox nudges scoped to Bugs/Tasks — Ideas/Epics quiet unless asked;
`gh issue list` can't filter by type, so the nudge uses `gh api graphql`).

Remaining: Piece 4 (Idea→Task promotion). Then close as v4.9.

Verify before building Piece 4: the exact GraphQL mutation to change an issue's
Issue Type (`updateIssue` with `issueTypeId`, or a dedicated mutation).
