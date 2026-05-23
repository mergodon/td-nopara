# State

Project:  td-flow
Topic:    idle
Phase:    idle
Blocker:  none
Last:     2026-05-24 — /td-snapshot landed; /td-incident rewritten as composition; #11 closed.

## Resume note

td-flow v5.2 just shipped — added `/td-snapshot` (commit current piece to a `snapshot/<slug>` branch + `Snapshot`-type GH issue with native `claude --resume` line), rewrote `/td-incident` to invoke `/td-snapshot` first (replacing the bespoke pointer-preservation mechanic that caused #11), surfaced Snapshots in `/td-mailbox` as a separate bucket, added Fix D contract rule (materialise topic to disk before designing). Five-commit increment from `b645118` to here. Next session: clean slate — pick up from `/td-mailbox` or whatever comes in.
