# State

Project:  td-flow
Topic:    idle
Phase:    idle
Blocker:  none
Last:     2026-05-26 — two framework fixes: (1) /td-complex-clear resume note now leads with a "Resume — start here" block (first-action guidance was split across §7+§15 and buried — surfaced by garmin's maiden run); (2) fix(hooks): pre-commit trims the extracted Test command with a quote-preserving `sed` instead of `| xargs` (xargs stripped quotes, breaking Xcode/JVM-style commands — bug from impostoree-app). FEEDBACK.md cleared (Open items implemented by /td-complex-clear; xargs fixed). Also registered td-complex-clear in smoke.sh EXPECTED_COMMANDS.

## Resume note

td-flow framework itself, settled. Ten slash commands; contract delivered via one-line `@import` per project; pre-commit hook runs `scripts/smoke.sh` for mechanical sanity. See PROJECT.md § Shipped for the v5.x arc. Next session: pick up whatever the user brings.

Side-finding (unaddressed): td-flow's *own* `.git/hooks/pre-commit` is not installed, so commits to this repo don't auto-gate on smoke — run `scripts/smoke.sh` manually before committing here, or `cp hooks/pre-commit .git/hooks/ && chmod +x .git/hooks/pre-commit` to dogfood it.
