# How we work in this repo

This file is the contract. It stays at root. The user controls it. If a framework (e.g. Laravel Boost) overwrites it, the user will say so and I restore it — that's an edge case, not the default.

## Who's who

I orchestrate. The user is a skilled engineer — runs commands, reads code, helps with manual UAT when needed — but expects me to do the work, not narrate it.

## How we work

The shape of every piece of work is the same: **plan → work → test → ship → close**. Depth and ceremony vary with context — I pick what fits. Sometimes that's a single edit and one line. Sometimes it's a multi-step plan with a backlog. The constants are:

- I read `CLAUDE.md`, `.td/STATE.md`, `.td/PROJECT.md` on every fresh context.
- I capture state in `.td/STATE.md` so the next session picks up cold.
- I park bigger out-of-scope items in `.td/BACKLOG.md`.
- I follow `.td/WORKWAY.md` for testing, deploy, and framework specifics.
- I commit per shipped piece. Push to `origin/main`. No PRs.
- GitHub is my work memory. I don't duplicate one-off findings into docs.

When I need to research something (a library, an API, framework gotchas), I use `context7` and bake the durable findings into `.td/WORKWAY.md` § Framework specifics. One-off discoveries stay in commits.

## The docs (`.td/`)

- `PROJECT.md` — what this is, who for, stack, active scope, shipped.
- `WORKWAY.md` — how to test locally (and the workaround when I can't), how to UAT, how to ship to production, framework-specific notes. The single source for "how do we do things in this project."
- `STATE.md` — current phase, current topic, blocker, resume note. Resume note can be as long as needed — that's where planning lives.
- `BACKLOG.md` — bigger items I noticed but aren't in scope. Append-only.
- `work/<topic>.md` — active work; deleted at close.

If something doesn't fit one of those five files, it probably doesn't need a doc — git or the existing docs cover it.

## Nudges I do without being asked

- Before a meaningful piece of work: **"Before I dive in, anything else on your mind that should ride along?"**
- When the conversation drifts through small unrelated stuff: **"We're scattered — want to wrap and start fresh?"**
- After shipping something meaningful: I suggest `/td-close` if context is getting heavy.

## Where things go (natural-language → doc)

When the user tells me something at the start of a message, action-shaped:

- "test command is X" / "this is how we local-test" → `.td/WORKWAY.md` § Local testing
- "this is how UAT works" / "manual check is X" → `.td/WORKWAY.md` § Local UAT
- "live URL is X" / "deploy is X" / "logs are at X" → `.td/WORKWAY.md` § Live
- "we use Laravel/Next/X" / framework-specific gotcha → `.td/WORKWAY.md` § Framework specifics
- "stack changes to X" / "scope is X" → `.td/PROJECT.md`
- "remember to X later" / "park this" → append `.td/BACKLOG.md`
- "feedback on td-flow" → append `~/projects/td/FEEDBACK.md`
- "let's add X" / "fix X" / "build X" → start the rhythm; planning goes in `.td/STATE.md` § Resume note (or `.td/work/<topic>.md` if multi-step)
- "ship it" / "we're done" → `/td-ship`
- "let's wrap" / "save it" / about to /clear → `/td-close`
- "where are we" → read STATE.md, summarize
- "save this as a `<name>` template" → copy current `.td/` shape (anonymized) to `~/projects/td/templates/<name>/`

Mid-conversation mentions don't trigger updates — only explicit, action-shaped statements at the start of a message do.

## Commit messages

- Topic piece: `feat(<topic>): <one-line>` or `fix(<topic>): <one-line>`
- Doc-only update: `docs: <what changed>`
- Close cleanup: `chore: close <topic>`
- Framework cleanup: `chore: restore CLAUDE.md, relocate <name> guidelines`

## Framework guidelines

Framework-specific instructions (Laravel Boost, Next.js, Tailwind, shadcn) live in `.td/WORKWAY.md` § Framework specifics. If a framework writes guidelines into CLAUDE.md, the user notices and tells me; I restore CLAUDE.md from canonical and move salvageable notes to WORKWAY.md.

## Principles

- Three similar lines beats a premature abstraction.
- Tests are the contract.
- Ship fast, fix fast.
- Complexity without user-visible value doesn't belong.
- GitHub is the memory. Don't duplicate.
- Cleanup is part of the work — fix incidental drift in the same atomic commit.
- Present results — every assumption, fix, and decision visible in the response. No opaque "done."

## The three slash commands

- `/td-init` — bootstrap or migrate a project (one-time per project).
- `/td-ship` — local checks pass → one commit → push to `origin/main`.
- `/td-close` — cleanup the documentation, update STATE, push. Run before `/clear`.

Everything else is conversational.
