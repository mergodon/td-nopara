# td-flow

A minimal, file-based, repo-portable framework for solo development.

Same shape every project. Conversational interface — after `/td-flow-init`, you just talk and I orchestrate. **GitHub Issues are the source of truth for parked work; `git log` is the source of truth for done work.** Local `.td/` is the workbench, not an archive.

## Install

```
git clone https://github.com/mergodon/td-flow ~/projects/td-flow
cd ~/projects/td-flow
./install.sh
```

Symlinks created:

- `~/.claude/commands/td-flow-init.md`
- `~/.claude/commands/td-flow-clear.md`
- `~/.claude/commands/td-flow-complex-clear.md`
- `~/.claude/commands/td-flow-close.md`
- `~/.claude/commands/td-flow-refresh.md`
- `~/.claude/commands/td-flow-mailbox.md`
- `~/.claude/commands/td-flow-health.md`
- `~/.claude/commands/td-flow-incident.md`
- `~/.claude/commands/td-flow-park.md`
- `~/.claude/commands/td-flow-snapshot.md`
- `~/.claude/skills/td-flow`
- `~/.claude/td-templates`
- `~/.claude/td-flow-contract.md` — the canonical contract, `@import`-ed by every project

To update on any machine: `git pull && ./install.sh`.

## The slash commands

| Command | When you reach for it | What it does |
|---|---|---|
| `/td-flow-init` | Once per project | Bootstrap or migrate (brownfield-aware). `--template <name>` to start from a saved starter. |
| `/td-flow-clear` | Mid-session checkpoint | Memory scan → doc-sync → light prune → STATE handoff → push. Ready for `/clear`. Fast. |
| `/td-flow-complex-clear` | Mid-session checkpoint, but for multi-day complex work | Enhanced `/td-flow-clear` with required STATE sections (lead "Resume — start here" block, pending-action list by owner, dependency graph, volatile artifacts, credentials state, safe-vs-needs-approval boundary) + self-validation gate. Use when standard `/td-flow-clear` is too loose for the complexity. |
| `/td-flow-close` | End of project (or phase) | Park leftover BACKLOG + work files to GitHub Issues, full doc audit, validate PROJECT, push. |
| `/td-flow-refresh` | When the framework has moved on | Pulls the latest framework + re-runs the installer. One-time: migrates a legacy project's `CLAUDE.md` onto the `@import`. |
| `/td-flow-mailbox` | Unified cross-repo check | One pass over both directions: inbound (filed INTO this repo, grouped by Issue Type) AND outbound (open cross-repo issues we filed, scoped by `.td/PROJECT.md § Cross-repo` and filtered by the `**From:**` body marker). Close/comment/skip inbound, comment/verify/close-stale/reopen/skip outbound. |
| `/td-flow-health` | Proactive production check | Run the project's `.td/health.sh` routine. Reports `OK`/`WARN`/`FAIL`; parks warnings to `BACKLOG.md`, escalates failures to `/td-flow-incident`. First run scaffolds the routine (or marks the project non-production). |
| `/td-flow-incident` | Live production fire | Drop everything else. Snapshots any in-flight piece first (so nothing is lost), then focus, diagnose with read-only-by-default constraint, fix or park as `Bug`. Surfaces `DEBUG.md` if present. |
| `/td-flow-park` | Mid-session BACKLOG bloat | Flush `BACKLOG.md` to GitHub Issues — consolidate related lines into a proposed issue set, then batch-create with type + dedupe. The canonical BACKLOG-flush procedure; `/td-flow-close` runs it too. |
| `/td-flow-snapshot` | Save the in-flight piece, switch focus | Commits current state to `snapshot/<slug>`, files a `Snapshot`-type GitHub issue with the resume command (`git checkout` + `claude --resume <session-id>`), resets STATE to idle. Resume by checking out the branch + running the resume line. Used standalone for mid-session pivots, or composed by `/td-flow-incident`. |

Shipping individual pieces is conversational: tests pass → commit → push. No slash command for that.

## After init, just talk

Most work is conversational. Here's what gets routed where:

```
"let's add a search bar"              → starts the rhythm
"fix X"                               → starts the rhythm on a fix
"test command is npm test"            → .td/WORKWAY.md § Local testing
"live URL is myapp.pages.dev"         → .td/WORKWAY.md § Live
"remember to debounce later"          → appends .td/BACKLOG.md
"park this to GH as Bug"              → creates GH issue directly with Type
"flush the backlog to GH"             → invokes /td-flow-park
"snapshot this" / "save and switch"   → invokes /td-flow-snapshot (branch + GH Snapshot issue)
"resume snapshot/X"                   → git checkout + claude --resume from the issue

# Picking between /td-flow-park and /td-flow-snapshot:
#   /td-flow-park     — flushes accumulated ideas (BACKLOG.md → GH Issues). Doesn't touch code,
#                  doesn't touch STATE.Topic. Use when brainstorm ideas have piled up and you
#                  want a clean BACKLOG without changing the active piece.
#   /td-flow-snapshot — preserves an in-flight piece (STATE.Topic != idle, uncommitted edits, work
#                  file) to a snapshot/<slug> branch + Snapshot-type GH issue. Use when you're
#                  mid-work and need to pivot (incident, other priority, stepping away).
# Both can run in sequence: /td-flow-snapshot first to preserve code, /td-flow-park to flush ideas.
"let's plan a big redesign"           → starts a planning work file (later → Epic)
"add to DEBUG: Sentry filter trick"   → writes to .td/DEBUG.md (creates if missing)
"file an issue for rgb-api to ..."    → cross-repo issue with `**From:**` marker
"any incoming?" / "check inbox"       → open Bugs/Tasks in this repo (or /td-flow-mailbox)
"show me the ideas"                   → lists open Ideas to triage / promote to Task
"what did we file?" / "show outbox"   → /td-flow-mailbox (the outbound section)
"did rgb-api respond yet?"            → /td-flow-mailbox or inline subIssues query
"health check" / "is prod healthy?"   → runs /td-flow-health
"ship it"                             → tests pass → commit → push
"where are we?"                       → summarizes STATE.md
"let's clear" / about to /clear       → runs /td-flow-clear
"wrap the project"                    → runs /td-flow-close
"save this as a 'laravel' template"   → extracts current .td/ shape
```

## The rhythm

```
1. Plan      — single-shot OR multi-step in .td/work/<topic>.md
2. Park      — out-of-scope items → .td/BACKLOG.md (flushes to GitHub at /td-flow-close)
3. Work      — implement
4. Test      — follow .td/WORKWAY.md (Local testing → Local UAT → Live)
5. Ship      — commit + push to origin/main when green
6. Close     — review, validate, prune redundant docs, park leftovers to GH, push
```

A session can cover any subset. `STATE.md` tracks where you are; the next session picks up cold.

## The docs

Four standard docs, one optional, plus scratch:

```
CLAUDE.md                ← one-line @import of the shared td-flow contract
.td/
  PROJECT.md             ← what / who / stack / scope
  WORKWAY.md             ← Local testing + Local UAT + Live + Framework specifics
  STATE.md               ← current phase, current topic, blocker, resume note
  BACKLOG.md             ← session-scoped parking; flushes to GH at /td-flow-close
  work/<topic>.md        ← active work scratch; deleted at close
  DEBUG.md  (optional)   ← project-specific troubleshooting reference (created on demand)
```

Plus the environment scaffolding:

```
.env.example             ← committed
.env                     ← gitignored
.git/hooks/pre-commit    ← runs Test command from WORKWAY.md § Local testing
```

## Common scenarios

**Quick fix during normal work**

```
You: "fix the navbar dropdown — not closing on outside click"
Me:  reads STATE, surfaces open Bugs/Tasks (startup nudge), starts the rhythm.
     [work + test happens]
You: "ship it"
Me:  tests pass, commits as fix(navbar): close dropdown on outside click, pushes.
```

**Planning a bigger piece (becomes an Epic with sub-issues)**

```
You: "let's plan the user dashboard redesign"
Me:  creates .td/work/user-dashboard-redesign.md, we sketch the plan together.
You: "plan looks solid, commit it"
Me:  creates an Epic in this repo with the plan as body. Breaks out 4 sub-issues
     (Task type) for concrete pieces. Fold-and-deletes the work file in the
     same commit. The Epic's progress bar updates as sub-issues close.
[later]
You: "let's work on the first sub-task"
Me:  picks up #42, sets STATE.Topic, starts the rhythm.
```

**Live production fire**

```
You: /td-flow-incident
Me:  STATE.Topic != idle — invokes /td-flow-snapshot first to preserve current piece.
     Commits in-flight work to snapshot/user-dashboard, files Snapshot issue #88
     with the `claude --resume <session-id>` line in the body, switches back to
     main with STATE idle, pushes.
     "Snapshotted user-dashboard → #88. What's broken? One-line description."
You: "checkout flow returns 500 for ~10% of users"
Me:  sets STATE.Topic = "incident: checkout-500", opens work file, surfaces
     DEBUG.md if present, walks diagnosis (read-only-by-default on prod).
[diagnosis converges on a missing DB index]
You: applies fix
Me:  tests pass, commits as fix(checkout): add missing index on user_id, pushes.
     "Anything worth saving to DEBUG.md?"
You: "yes — the Sentry-filter-by-release trick"
Me:  appends to DEBUG.md (creates from template if missing), commits.
     STATE back to idle. "Previous piece resumable from snapshot/user-dashboard
     (#88) — the resume line is in the issue body."
```

**Routine health check**

```
You: /td-flow-health
Me:  runs .td/health.sh — app reachable, disk, queues, deploy in sync.
     "myapp: 1 warn — queue 'default' wait 80s. Park to BACKLOG?"
You: "yes — park it"
Me:  appends the warning to BACKLOG.md, commits.
[another day, a check comes back red]
Me:  "myapp: 1 fail — worker process not running. Escalate to /td-flow-incident?"
You: "yes"
Me:  drops into incident mode, "worker process down" pre-filled as the symptom.
```

**Cross-repo request (outbound)**

```
You: "file a CR to rgb-api: please add a timestamp to the /X endpoint"
Me:  checks this project's .td/PROJECT.md § Cross-repo for the target repo,
     drafts:
       Title: Add timestamp field to /X endpoint
       Body:  **From:** <this-project>
              <ask + why>
       Type:  Task
     Confirms with you. Runs `gh api graphql createIssue` against the target.
     Returns the issue URL. The receiving project sees it via /td-flow-mailbox.
     **If the work belongs to a planning Epic in this repo, also addSubIssue
     to that Epic** so cross-repo progress rolls up. Otherwise no extra step.
[a few days later, this project]
You: /td-flow-mailbox
Me:  inbound: open issues in this repo, Epics with sub-issue progress.
     Outbound: search bounded to .td/PROJECT.md § Cross-repo repos, filter
     by **From:** marker. Shows rgb-api#42 as "Awaiting reply (3 days)".
You: "comment back: we can wait one more sprint"
Me:  drafts comment, signs as <this-project>, confirms, posts.
```

**End of work day**

```
Quick checkpoint:    /td-flow-clear   → memory scan, doc-sync, STATE handoff, push, ready for /clear
Full project wrap:   /td-flow-close   → park leftovers to GH, code sanity, doc audit, push
```

## Issue Types and Epics

GitHub Issues are the source of truth for parked work. At the org level, five Issue Types organize the queue:

| Type | When |
|---|---|
| `Idea` | exploratory, no commitment, browse later |
| `Task` | specific piece of work — most things end up here, including new features |
| `Bug` | unexpected problem or broken behavior |
| `Epic` | bigger work that decomposes into sub-issues |
| `Snapshot` | personal lifecycle marker for paused in-flight work (filed by `/td-flow-snapshot`) — not a work request, surfaces in `/td-flow-mailbox`'s Snapshots bucket |

An `Idea` you decide to act on becomes a `Task` — via `/td-flow-mailbox`'s `promote`, or automatically when you start work on it. Ask "show me the ideas" any time to triage the `Idea` queue.

Epics can have formal sub-issues across repos in the same org. Per-project Epics live in the project's own repo. The parent's progress bar updates automatically as cross-repo sub-issues close.

`/td-flow-mailbox` reads Issue Types via `gh api graphql` (the `gh` CLI doesn't filter by type natively yet, so we use GraphQL directly).

**Forkers:** define your own Issue Types at your org level via github.com → org settings → Issue Types. The framework discovers them at runtime — no extra setup.

## Cross-repo requests

Projects sometimes need things from other projects. Convention:

1. Each `.td/PROJECT.md` keeps an opt-in `## Cross-repo` section listing the repos this project legitimately files against. **This list IS the outbound scope** for `/td-flow-mailbox`.
2. To file: `gh api graphql createIssue` (with the appropriate Type) against the target repo. Body opens with `**From:** <this-project>` so the receiver identifies the source mechanically — independent of which GH account opened the issue.
3. **If the work belongs to a planning Epic in this repo, also `addSubIssue`** to that Epic so cross-repo progress rolls up natively. Otherwise no extra step — `/td-flow-mailbox`'s outbound query finds the filing via the body marker scoped to declared repos.
4. The receiving project sees it via `/td-flow-mailbox` (inbound section), walks the CR alongside their own queue.
5. Receiver closes via `Closes <slug>#N` in a commit message — auto-links both sides.

No labels, no status enum, no separate inbox. Open = pending; closed = done.

**`/td-flow-mailbox` is the unified view, minimum-dependency.** One command walks both directions: inbound (open issues in this repo, Epics with sub-issue progress inline) and outbound (open cross-repo issues we filed, scoped by `.td/PROJECT.md § Cross-repo` and filtered by the `**From:** <project>` body marker). No tracker Epic, no sentinel logic. The connected-repos list bounds the search; the body marker identifies our filings. That's all.

Unified view across all your repos: `gh search issues --owner <your-org> --state open` (REPO is the unit of interest; no author filter — works regardless of which GH identity you're using).

**Use friendly project names in cross-repo messages, not GH slugs.** When filing/commenting cross-repo, reference projects by their friendly name (e.g. "filed from `<consumer-app>`"). Resolution: first H1 in `.td/PROJECT.md`, fall back to directory basename. Keep PROJECT.md's H1 set to the project's friendly name on every td-flow project. GH slugs change on rename; friendly names stay stable and identity-agnostic across machines.

## Updating an existing td-flow project

Updating is nearly free now — the contract isn't copied into your project; your `CLAUDE.md` `@import`s the canonical one. So:

```
cd ~/projects/td-flow && git pull && ./install.sh
```

That's it — **every** td-flow project picks up the new contract on its next session. Nothing per-project.

If a project still carries a *pre-import* full copy of the contract in its `CLAUDE.md`, run `/td-flow-refresh` in it once — that migrates the `CLAUDE.md` onto the `@import`.

## Saving and reusing templates

When a project's setup is dialed in, say "save this as a `<name>` template." I copy `.td/*` (anonymized — placeholders restored) to `~/projects/td-flow/templates/<name>/`. Future `/td-flow-init --template <name>` starts from that shape so the next project of the same kind is configured out of the gate.

Current templates:

- `templates/cloudflare-static-assets` — Cloudflare Workers Static Assets pattern (R2 for media, `wrangler.jsonc`, custom domain quirks baked in).

## Frameworks (Laravel Boost, Next, etc.)

Frameworks like Laravel Boost regenerate root files (`CLAUDE.md`, `AGENTS.md`, `.mcp.json`, `boost.json`, `junie/`) on `boost:install`. We:

1. Use Boost's MCP server (the genuinely useful part — `.mcp.json` is gitignored, regenerated, and that's fine).
2. Note the framework in `.td/WORKWAY.md` § Framework specifics so I know how to use it.
3. Gitignore Boost's auto-generated guideline files.
4. If Boost overwrites root `CLAUDE.md`, you tell me; I restore it — it's just the one `@import` line. An edge case, not the default.

## Repo layout (this repo)

```
commands/             slash commands (td-flow-init, td-flow-clear,
                                      td-flow-complex-clear, td-flow-close,
                                      td-flow-refresh, td-flow-mailbox,
                                      td-flow-health, td-flow-incident,
                                      td-flow-park, td-flow-snapshot)
templates/            files copied into target projects on /td-flow-init
  CLAUDE.md           one-line @import of the canonical contract
  td/PROJECT.md
  td/WORKWAY.md       the way-of-work doc with locked sections
  td/STATE.md
  td/BACKLOG.md
  td/DEBUG.md         optional troubleshooting template (not auto-scaffolded)
  td/health.sh        health-check skeleton (scaffolded by /td-flow-health, not /td-flow-init)
  td/frameworks/.gitkeep   (overflow dir, rarely needed)
  .gitignore
  .env.example
  <name>/             saved starter templates (e.g. cloudflare-static-assets)
CLAUDE.md             the canonical td-flow contract (symlinked as ~/.claude/td-flow-contract.md)
skill/SKILL.md        skill definition (symlinked into ~/.claude/skills/td-flow)
hooks/pre-commit      test-on-commit hook installed by /td-flow-init
scripts/smoke.sh      pre-ship sanity checks for this repo (wired as Test command)
install.sh            symlinks commands, skill, templates, contract into ~/.claude/
FEEDBACK.md           feedback about td-flow itself, captured from any project
```

## Principles

- Three similar lines beats a premature abstraction.
- Tests are the contract.
- Ship fast, fix fast.
- Complexity without user-visible value doesn't belong.
- GitHub is the memory. Don't duplicate.
- Cleanup is part of the work — fix incidental drift in the same commit.
- Present results — assumptions, fixes, decisions visible. No opaque "done."

## Not in scope

- Research / context7 as a formal rhythm phase — decided against; ad-hoc context7 use is already the norm.
- Subagents for implementation fan-out — decided against; coordination cost outweighs the speedup for a solo dev.
- An application-code test suite for the framework itself — there's no application code to test. Mechanical sanity checks (bash syntax, install idempotency, symlink integrity, AWK extractor) are automated in `scripts/smoke.sh` and run by the pre-commit hook; semantic UAT (does `/td-flow-snapshot` actually work?) is still by hand, against `mergodon/td-flow-test1`.
- Anything that turns this into a CLI or npm package. Never.
