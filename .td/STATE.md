# State

Project:  td-flow
Topic:    test-framework
Phase:    (b) shipped — moving to (a) scripts/smoke.sh
Blocker:  none
Last:     2026-05-24 — (b) /td-snapshot UAT against td-flow-test1 passed, one Step-1 clarity bug found + fixed. Next: build scripts/smoke.sh.

## Resume note

[mailbox] empty

td-flow v5.2 shipped earlier this session (`b645118` → `6017c72`, five commits): `/td-snapshot` (commit current piece to `snapshot/<slug>` branch + `Snapshot`-type GH issue with native `claude --resume <session-id>` line); `/td-incident` rewritten as `/td-snapshot` composition (drops the bespoke pointer-preservation that caused #11); `/td-mailbox` surfaces Snapshots as a separate bucket with `resume`/`delete` actions; Fix D contract rule (materialise topic to disk before designing). #11 closed.

**Next topic: a small test framework.** User asked for it after the v5.2 ship. The current testing surface is manual: pre-ship checklist in WORKWAY.md § Local testing (syntax checks, install idempotency, command symlinks), plus the two test-harness repos (`mergodon/td-flow-test1` + `td-flow-test2`, private, kept). The biggest gap: `/td-snapshot` and the rewritten `/td-incident` shipped today but have NEVER been live-exercised — only dry-run in roleplay. Highest-value first step is either (a) automate the pre-ship checklist as `scripts/smoke.sh`, or (b) live-exercise `/td-snapshot` against `td-flow-test1` to validate it actually works. Discuss with user which to build first when picking it up.

Session-ID env var (`$CLAUDE_CODE_SESSION_ID`) and transcript-path derivation (`~/.claude/projects/<pwd-as-dashes>/<session-id>.jsonl`) — both verified in this session, both used by `/td-snapshot`. The Snapshot Issue Type was created in mergodon org during this session (visible in `gh api graphql organization(login:"mergodon"){issueTypes{...}}`).
