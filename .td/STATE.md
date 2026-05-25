# State

Project:  td-flow
Topic:    idle
Phase:    idle
Blocker:  none
Last:     2026-05-26 — fix(td-complex-clear): folded the resume note's first-action guidance (was split across §7 + §15, buried at the tail) into a single "Resume — start here" lead block, physically first. Surfaced by garmin's maiden /td-complex-clear run, where the next session skipped the buried §15. Also registered td-complex-clear in scripts/smoke.sh EXPECTED_COMMANDS (missing since the command landed in 6ee1cd3).

## Resume note

td-flow framework itself, settled. Ten slash commands; contract delivered via one-line `@import` per project; pre-commit hook runs `scripts/smoke.sh` for mechanical sanity. See PROJECT.md § Shipped for the v5.x arc. Next session: pick up whatever the user brings.

Open framework bug tracked in FEEDBACK.md: `hooks/pre-commit` `| xargs` trim strips quotes from a quoted Test command (bites Xcode/JVM-style commands). Not in scope here.
