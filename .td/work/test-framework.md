# Test framework

## Spec (verbatim from user)

> test framework
>
> do both

Teed up by 2026-05-24 `/td-clear` STATE resume note. Two starting points named there:

- **(a) Automate the pre-ship checklist as `scripts/smoke.sh`** — turn the manual WORKWAY § Local testing routine (syntax checks, install idempotency, command symlinks) into a script. Catches regressions in framework mechanics.
- **(b) Live-exercise `/td-snapshot` against `td-flow-test1`** — the v5.2 work (snapshot + the rewritten `/td-incident`) shipped today without ever being run for real. Validates the new commands actually work end-to-end.

User: "do both".

## Proposed order

**(b) first, then (a).** Reasoning:

- (b) is a UAT of v5.2 work that shipped today and has never been live-exercised. If it surfaces bugs in `/td-snapshot` or the rewritten `/td-incident`, we want to fix them while context is hot — not after building tooling on top of an unverified base.
- (a) is additive — building it doesn't depend on (b), and (b) doesn't depend on (a). But running (a) on a framework with latent bugs would muddy results.
- (b) is also the higher-stakes one: the commands are now part of the documented surface; if they don't work, that's a real regression.

## (b) — Live-exercise /td-snapshot — SHIPPED 2026-05-24

UAT against `mergodon/td-flow-test1` from this session (option 2 — driver-from-another-session, so transcript path expected to be unfound, accepted as a known trade-off).

**Mechanic exercised end-to-end:**
1. Set up in-flight piece: `STATE.Topic = webhook-retry`, `.td/work/webhook-retry.md`, dirty config edit.
2. Ran `/td-snapshot test-uat` — Steps 0-8 executed exactly as documented. Snapshot branch `snapshot/webhook-retry` pushed (commit `9f5c97c`); GH issue #14 filed with type `Snapshot`, `**From:** td-flow-test1` marker, full resume line, frozen STATE block; main reset to idle (`33115c3`).
3. Composition path: re-set up `event-schema-v2` in-flight, ran `/td-incident` Step 1 (composition entry point) → invoked snapshot procedure with `reason=incident-pivot` → issue #15 filed → Step 3 STATE template rendered the prior-snapshot reference correctly.
4. `/td-mailbox` Snapshot bucket: inbound query returned #14 and #15 with `issueType.name = "Snapshot"` — partition logic works.

**Findings:**
- All three v5.2 commands work as documented. The #11 failure mode (incident-mode pointer-preservation losing content) is genuinely fixed — full content lives on the branch + in the issue body.
- One procedural-clarity bug in `commands/td-snapshot.md` Step 1: `<original-topic>`, `<original-phase>`, `<original-last>` were only declared by being referenced in Step 6's body template. Added explicit capture instruction at Step 1, with a "before Step 7 rewrites STATE" reminder. Fixed in this commit.
- Resume-path test (option 1, real-session resume) deferred — the option-2 UAT verified the resume LINE is correctly built; the actual `claude --resume <session-id>` invocation is a Claude Code feature, not a td-flow concern. If anyone wants a full option-1 UAT later, run /td-snapshot from a fresh test1 session and confirm the resume line spawns a working session in a new terminal.

**Cleanup:** snapshot branches deleted (local + remote), issues #14/#15 closed as `not_planned`, test1 STATE restored to its pre-UAT closed state, post-UAT commit `1e682dc` pushed to test1/main.

## (a) — scripts/smoke.sh

**Goal:** automate the pre-ship checks currently done by hand per WORKWAY § Local testing.

**Candidate checks (to confirm against WORKWAY before writing):**
- Bash syntax check across `install.sh`, `commands/*.md` if any have shell blocks, `templates/td/health.sh`.
- `install.sh` idempotency: run twice, second run should be no-op or only re-link.
- Symlink integrity: every file in `commands/` resolves to a real file from `~/.claude/commands/`.
- `~/.claude/td-flow-contract.md` → `~/projects/td-flow/CLAUDE.md` link present.
- Optional: lint markdown frontmatter on `commands/*.md` (every command has the required fields).

**Output protocol:** mirror `/td-health` — exit `0`/`1`/`2`, lines prefixed `OK`/`WARN`/`FAIL`. Then WORKWAY § Local testing can shrink to "run `scripts/smoke.sh`."

## Out of scope for this topic

- Automated test suite for the framework itself (per PROJECT.md § Out of scope, dropped 2026-05-05). `smoke.sh` is a pre-ship sanity check, not a test suite.
- New `/td-test` command. Conversational + `scripts/smoke.sh` is enough.
