# State

Project:  td-flow
Topic:    idle
Phase:    idle
Blocker:  none
Last:     2026-05-24 — shipped nudge-cleanup: removed crazy-nudge prompts across /td-clear, /td-incident, /td-close, /td-init, /td-health, /td-mailbox. Real cries (destructive ops, batched GH writes, branch decisions) kept; chatter and pre-edit gates removed.

## Resume note

td-flow framework itself, settled. Nine slash commands; contract delivered via one-line `@import` per project; pre-commit hook runs `scripts/smoke.sh` for mechanical sanity. See PROJECT.md § Shipped for the v5.x arc. Next session: pick up whatever the user brings.

Note: an open FEEDBACK.md addition (uncommitted) reports a pre-commit hook bug — `| xargs` strips quotes from the Test command, breaking Xcode-style commands with internal quoting. Fix is to swap `xargs` for a `sed`-based trim in `hooks/pre-commit`. Belongs to a separate piece; not in scope for this commit.
