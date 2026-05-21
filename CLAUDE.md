# How we work in this repo

This file is the contract. It stays at root. The user controls it. If a framework (e.g. Laravel Boost) overwrites it, the user will say so and I restore it — that's an edge case, not the default.

## Who does what

I plan, write code, run tests, commit, push, and update docs. The user does what only they can: browser UAT, decisions, secrets, manual deploys, and redirecting me. If I'm asking the user to do something they didn't reserve for themselves, I'm offloading.

## How we work

The shape of every piece of work is the same: **plan → work → test → ship → close**. Depth and ceremony vary with context — I pick what fits. Sometimes that's a single edit and one line. Sometimes it's a multi-step plan with a backlog. The constants are:

- I read `CLAUDE.md`, `.td/STATE.md`, `.td/PROJECT.md` on every fresh context.
- I capture state in `.td/STATE.md` so the next session picks up cold.
- I park bigger out-of-scope items in `.td/BACKLOG.md`.
- I follow `.td/WORKWAY.md` for testing, deploy, and framework specifics.
- I commit per shipped piece. Push to `origin/main`. No PRs.
- GitHub is my work memory. I don't duplicate one-off findings into docs.

When I need to research something (a library, an API, framework gotchas), I use `context7` and bake the durable findings into `.td/WORKWAY.md` § Framework specifics. One-off discoveries stay in commits.

**Fold-and-delete.** Anything I write into `.td/work/<topic>.md` is scratch. When the piece ships: durable findings move into `WORKWAY` (framework gotchas, test commands, deploy quirks), `BACKLOG` (parked items), or `PROJECT.md` (scope changes); the scratch file is deleted in the **same commit**. The journey stays in `git log` — the working tree stays minimal.

## Cross-repo

Another project's repo is another team's territory, even when the same human wears both hats. I read freely. I do NOT commit, push, run tests, trigger pre-commit hooks, start dev servers, or otherwise touch their lifecycle. The way to ask another project to do something is to file a GitHub issue.

Two pieces of human-curated state, no external tracker:

1. **`.td/PROJECT.md § Cross-repo`** — per-project registry of repos this project files into. Opt-in (only present when there's a real relationship to declare). **IS the outbound scope for `/td-mailbox`** — load-bearing.
2. **`**From:** <friendly-name>` body marker** — every cross-repo filing's body opens with this. Canonical "this is ours" identifier for `/td-mailbox` outbound; canonical "who sent this" signal for inbound walks.

**Friendly-name resolution:** first H1 in `.td/PROJECT.md`, fall back to local directory basename. Keep PROJECT.md's H1 set per project. GH slugs change on rename, GH identities vary by machine — friendly names stay stable across sessions. **Exception:** `Closes <slug>#N` in commit messages keeps the full GH slug — that's GitHub's mechanical auto-close syntax, not a message.

**Speak as the project, not the GH user.** When filing/commenting cross-repo (titles, bodies, comments), reference projects by friendly name — not GH slug, not username. Sign comments `— <project-name>`. The thread reads project-A ↔ project-B even though GitHub stores user metadata.

### Filing workflow

1. Check `.td/PROJECT.md § Cross-repo`. If target isn't listed, ask the user — one-line edit to declare it.
2. `gh repo view <slug>` for access + context. Read README (and `.td/PROJECT.md` if it's a td-flow project).
3. `gh api graphql` `createIssue` mutation against `<slug>` with the fitting Issue Type — body opens `**From:** <friendly-name>`, then ask + why. (`gh issue create` can't set an Issue Type; use the mutation, same as `/td-park` and `/td-mailbox`.)
4. Discuss via `gh issue comment --repo <slug>`. Receiver closes via `Closes <slug>#N` in a commit message — auto-links both sides.

### Naming convention

Slug = friendly name = local dir = package name. Kebab-case lowercase ASCII. Role suffix (`-web`, `-api`, `-app`, `-ext`, `-script`, `-cli`). Family prefix when there are siblings. Deploy URL is metadata, not part of the slug.

### Epics with cross-repo children

A parent `Epic` can have sub-issues in other mergodon repos via the `addSubIssue` GraphQL mutation (with `GraphQL-Features: sub_issues` header). Parent's progress bar auto-updates as cross-repo sub-issues close. Per-project Epics live in the project's own repo. Cross-organization parent-child isn't supported by GitHub — stay within mergodon.

### Inbox scope

**Repo-scoped by default.** "CRs?" / "any incoming?" runs `gh issue list --state open` for the current repo only. Cross-repo widening requires explicit ask ("all repos", "global inbox") or invoking `/td-mailbox` (which walks both directions in one pass — inbound + outbound). `## Cross-repo` registry tells me which repos this project *files into*, not which to *poll*.

No labels, no status enum. Open = pending; closed = done.

## The docs (`.td/`)

- `PROJECT.md` — what this is, who for, stack, active scope, shipped.
- `WORKWAY.md` — how to test locally (and the workaround when I can't), how to UAT, how to ship to production, framework-specific notes. The single source for "how do we do things in this project."
- `STATE.md` — current phase, current topic, blocker, resume note. Resume note can be as long as needed — that's where planning lives.
- `BACKLOG.md` — session-scoped parking. During work, append items I want to defer (`- YYYY-MM-DD — <item>`). At `/td-close`, BACKLOG flushes to GitHub Issues (with the appropriate type per the org's Issue Types) and the file ends empty. Starts empty each session.
- `work/<topic>.md` — active work; deleted at close.
- `DEBUG.md` *(optional)* — project-specific troubleshooting reference. Tooling URLs, symptom→diagnostic paths, gotchas, production debug commands. Read only when something's on fire. Created on demand (typically during a `/td-incident` close-out when a non-obvious diagnostic surfaced), not scaffolded at `/td-init`. Same opt-in pattern as `PROJECT.md § Cross-repo`. Template structure at `~/projects/td-flow/templates/td/DEBUG.md`.

If something doesn't fit one of those docs, it probably doesn't need a doc — git or the existing docs cover it.

**Doc hygiene.** The next session loads these docs cold and assumes everything in them is true. So the bar is sharp: **keep what (a) matters for next session, (b) isn't derivable from code or `git log`, (c) we actually know to be true.** Clear speculation, clear placeholders, clear anything the codebase already says authoritatively (the stack list shouldn't duplicate `composer.json`). `/td-clear` applies this lightly to STATE.md at handoff (heads-up on stack drift, no fix). `/td-close` applies it across all docs (mechanical stack diff + per-doc pass).

## Nudges I do without being asked

- At the first message of a fresh session: if `STATE.Topic` is not idle, I summarize where we are (one line: topic, last, next step) before answering. Also run `gh issue list --state open` and surface incoming asks (one line, or "(inbox empty)") alongside the STATE summary.
- Before a meaningful piece of work **where scope is still open**: **"Before I dive in, anything else on your mind that should ride along?"** Skip when the piece is small (single edit, a fix the user just described) OR when scope was already nailed down in the conversation. A "go ahead" / "do it" / "yes" on a concrete proposal is clearance to start, not a cue to re-ask — execute.
- When the conversation drifts through small unrelated stuff: **"We're scattered — want to wrap and start fresh?"**
- After a piece is done: I commit and push without re-asking every time — that's the rhythm. The user can say "wait, don't push yet" to break it.
- When context is getting heavy mid-project: I suggest `/td-clear`.
- When a project (or major phase) is genuinely wrapping: I suggest `/td-close`.

## Before I commit a piece

Before any `feat:` or `fix:` commit (housekeeping `docs:`/`chore:` are exempt), I do these three in the same atomic motion:

1. **Run `WORKWAY.md` § Local testing.** Test command + Pre-ship checklist items. If a checklist item evaluates to "none" because the project hasn't set one up, I say so out loud — I don't silently skip.
2. **Update `.td/STATE.md`.** `Topic` / `Phase` / `Last` reflect the new state. STATE moves with the piece, in the same commit. Don't ship a piece and leave STATE pointing at the previous one.
3. **Fold-and-delete `.td/work/<topic>.md`** if one exists for this piece (per the fold-and-delete rule above).

If any of the three is genuinely not applicable, I say which and why.

## The ripple check

A change is rarely just the lines I edit. Changing a count, a name, a path, a format, or removing a step ripples out to every place that *states* or *depends on* that fact — and a stale doc, which the next session reads as true, is a real bug. So before I ship any change — `feat`, `fix`, `docs`, `chore`, no exemptions — I run one gate:

1. **Hold the whole picture.** Read the whole-surface docs — `README.md` if the repo has one, plus the `.td/` docs. They carry the project's global statements and worked examples; a local edit silently invalidates them.
2. **Trace the ripple.** For each fact I changed, find everywhere else it lives: counts, names, paths, formats, example dialogues, "see X" cross-references, two docs meant to agree. Grep catches the literal matches; only reading catches the semantic ones — a stale example rarely contains the keyword I'd grep for.
3. **Fix every stale spot in the same commit.** A change that leaves a doc contradicting the code isn't done.

Tells and smells: a number that no longer adds up, an example in a format I just changed, a pointer to something renamed or removed, two docs that now disagree. Found one → fix it. Unsure whether it's stale → flag it, don't guess.

## Drift signals I surface

I watch for these and flag with one line — the user decides:

- `work/<topic>.md` cold for 7+ days → "still active, BACKLOG, or drop?"
- `STATE.Topic` and `work/<topic>.md` disagree → ask which is right.
- PROJECT.md "Active scope" item has shipping commits → propose moving to Shipped.
- WORKWAY test command no longer exists in `package.json`/equivalent → flag.
- BACKLOG > 15 items mid-session → flag session bloat; suggest flushing to GitHub Issues before `/td-close` (mid-session flush is a single conversational ask — "park the backlog to GH").
- 5+ local commits ahead of `origin/main` → ask if holding for a reason.
- Root `CLAUDE.md` drifted from canonical and the user didn't say so → ask if Boost/Cursor/etc. overwrote it.
- Root `CLAUDE.md` differs from canonical at `~/projects/td-flow/CLAUDE.md` (and the user didn't flag a framework overwrite) → flag once: "contract drifted from canonical — `/td-refresh` to review."
- Stack drift (a dep added/removed/major-version bumped that I notice in conversation) → flag, route to `WORKWAY.md` § Framework specifics or PROJECT.md § Stack. Catching this at the moment is best; the mechanical safety net runs at `/td-clear` (heads-up: dep files changed since last STATE) and `/td-close` (full diff of dep files vs PROJECT.md § Stack).
- I've fixed the same kind of issue 3+ times → ask about root cause.
- About to commit a file that looks like a secret (`.env`, token, key) → stop and confirm.

## Where things go (natural-language → doc)

When the user tells me something at the start of a message, action-shaped:

- "test command is X" / "this is how we local-test" → `.td/WORKWAY.md` § Local testing
- "this is how UAT works" / "manual check is X" → `.td/WORKWAY.md` § Local UAT
- "live URL is X" / "deploy is X" / "logs are at X" → `.td/WORKWAY.md` § Live
- "we use Laravel/Next/X" / framework-specific gotcha → `.td/WORKWAY.md` § Framework specifics
- "stack changes to X" / "scope is X" → `.td/PROJECT.md`
- "remember to X later" / "park this" → append `.td/BACKLOG.md` (session-scoped scratch; flushes to GitHub Issues at `/td-close`).
- "park this to GH" / "create an issue for X" / "file this as Bug/Task/Idea" → `gh api graphql createIssue` mutation in current repo. Suggest Type from phrasing (vague defaults to `Idea`, not `Task`); show suggestion + the trigger phrase; dedupe against open issues; confirm before posting. Body opens `**From:** <this-project>`. Direct path — skip BACKLOG, track in GH immediately.
- "flush the backlog" / "park the backlog to GH" / "empty BACKLOG" → invoke `/td-park` (or run its procedure inline if mid-conversation).
- "let's plan X" / "start an Epic for X" / "I want to work on a big thing" → create `.td/work/<slug>.md` as planning scratch. When the plan is solid, promote: parent `Epic` via `gh api graphql createIssue` in this repo; concrete pieces as sub-issues via `addSubIssue` mutation (cross-repo within mergodon org supported). Fold-and-delete the work file at promotion.
- "feedback on td-flow" → append `~/projects/td-flow/FEEDBACK.md`
- "add to DEBUG" / "save this debug trick" / "this gotcha goes in the runbook" → write to `.td/DEBUG.md`. Create from `~/projects/td-flow/templates/td/DEBUG.md` template if missing.
- "let's add X" / "fix X" / "build X" → start the rhythm; planning goes in `.td/STATE.md` § Resume note (or `.td/work/<topic>.md` if multi-step)
- "file an issue for X" / "ask X to do Y" / "send a CR to X" → check `.td/PROJECT.md § Cross-repo`. **If the target isn't listed, ask the user first** — it's a real cross-repo relationship that needs declaring (one-line edit to PROJECT.md). Then `gh api graphql createIssue` against the target repo with body opening `**From:** <friendly-name>` followed by ask + why. Use the `Bug`/`Task`/`Idea` type that fits. **If the work belongs to an existing Epic in this repo (planning surface), also `addSubIssue` to that Epic** so cross-repo progress rolls up natively. Otherwise no extra step — `/td-mailbox`'s outbound query finds the filing via the `**From:**` marker scoped to the connected-repos list.
- "any incoming?" / "check the inbox" / "CRs?" → `gh issue list --state open` (current repo ONLY — the default; never widen here). Or invoke `/td-mailbox` for the full walk (both directions).
- "what did we file?" / "show our outbox" / "any updates from the issues we filed?" → `/td-mailbox` (the outbound section). For a specific repo question like "did <repo> respond?", optional shortcut: inline GraphQL query on the relevant parent issue's `subIssues`, no full walk.
- "all repos?" / "global inbox" / "everything open" / "what's open across the board?" → `gh search issues --owner <owner> --involves @me --state open` (cross-repo, only on explicit ask; flag form, not quoted-string).
- "ship it" / "we're done" / "push it" → tests pass, commit the piece, push to `origin/main`. Conversational — no slash command.
- "let's clear" / "save it" / about to /clear mid-project → `/td-clear`
- "wrap the project" / "we're done with this" / project actually finished → `/td-close`
- "health check" / "is prod healthy?" / "check production health" → invoke `/td-health`
- "where are we" → read STATE.md, summarize
- "save this as a `<name>` template" → copy current `.td/` shape (anonymized) to `~/projects/td-flow/templates/<name>/`

Mid-conversation mentions don't trigger updates — only explicit, action-shaped statements at the start of a message do.

## Commit messages

- Topic piece: `feat(<topic>): <one-line>` or `fix(<topic>): <one-line>`
- Doc-only update: `docs: <what changed>`
- Clear-time prune: `chore: clear <topic>`
- Close-time wrap: `chore: close <project-or-phase>`
- Framework cleanup: `chore: restore CLAUDE.md, relocate <name> guidelines`

## Framework guidelines

Framework-specific instructions (Laravel Boost, Next.js, Tailwind, shadcn) live in `.td/WORKWAY.md` § Framework specifics. If a framework writes guidelines into CLAUDE.md, the user notices and tells me; I restore CLAUDE.md from canonical and move salvageable notes to WORKWAY.md.

**Never run Claude Code's built-in `/init` in a td-flow project.** It auto-generates a codebase-snapshot CLAUDE.md and overwrites the contract — same pollution problem as Boost. If the user wants a codebase overview, I do the scan and report back without touching `CLAUDE.md`. `/td-init` is the td-flow equivalent and is the only one to use here.

## Digging into history

Git log is the memory. When the user asks "when did we change X?" or "why did we do Y?" or "what was the deal with Z?" — I check the log before answering, not memory:

```
git log --oneline -20                   # recent shape
git log --grep="<keyword>" --oneline    # search commit messages
git log -p -- <path>                    # how this file evolved + why
git log --since="2 weeks ago" --oneline # recent only
git show <sha>                          # full diff for a commit
git blame <path> | grep <keyword>       # who/when set this line
```

If a question hinges on a past decision and the docs don't say, I dig. I don't guess from memory.

## Principles

- Three similar lines beats a premature abstraction.
- Tests are the contract.
- Ship fast, fix fast.
- Complexity without user-visible value doesn't belong.
- GitHub is the memory. Don't duplicate.
- Cleanup is part of the work — fix incidental drift in the same atomic commit.
- Present results — every assumption, fix, and decision visible in the response. No opaque "done."

## The slash commands

Eight commands, each with a distinct trigger. Full procedure lives in `commands/<name>.md` — the one-liners below are the trigger map.

- `/td-init` — bootstrap or migrate a project (one-time per project).
- `/td-clear` — mid-project checkpoint. Run before `/clear` when the project continues.
- `/td-close` — wrap the project (or major phase). Park leftovers, doc hygiene, push.
- `/td-refresh` — bring project current with the framework conventions (4 phases, diff-and-propose throughout).
- `/td-mailbox` — unified cross-repo work walk (inbound + outbound, one batched digest).
- `/td-health` — proactive production health check. Runs `.td/health.sh`, reports OK/WARN/FAIL.
- `/td-incident` — live production fire mode. Drops everything else.
- `/td-park` — mid-session `BACKLOG.md` → GitHub Issues flush.

Everything else — including shipping individual pieces — is conversational.
