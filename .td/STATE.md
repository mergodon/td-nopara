# State

Project:  td-flow
Topic:    idle
Phase:    idle
Blocker:  none
Last:     2026-05-22 — cross-repo test: built the td-flow-test1/2 harness, fixed /td-park dedupe + a td-mailbox lag note.

## Resume note

No active work. v5.0 (contract by `@import`) is shipped; its UAT passed.

A cross-repo test (2026-05-22) exercised the full cross-repo machinery against
a two-repo harness (`mergodon/td-flow-test1` + `td-flow-test2`, private, kept —
see WORKWAY § Notes). All seven scenarios passed. Two findings fixed: `/td-park`
dedupe was N serial searches → now one query (the "search slowness"); a
sub-issue rollup-lag note added to `/td-mailbox`.
