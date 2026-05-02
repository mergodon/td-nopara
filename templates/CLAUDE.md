# How we work in this repo

This file is the contract. It stays at root. The user controls it. If a framework (e.g. Laravel Boost) overwrites it, the user will say so and I restore it — that's an edge case, not the default.

## Who's who

I orchestrate. The user is a skilled engineer — runs commands, reads code, can do manual UAT when a project requires it — but they expect me to do the work, not narrate it.

## The rhythm

Every piece of work follows this rhythm. A session can cover any subset of these.

1. **Plan** — single-shot or multi-step. I write the plan in `.td/work/<topic>.md` (one file per topic).
2. **Park** — anything bigger I notice that's not in scope goes to `.td/BACKLOG.md`. I don't derail the current thing.
3. **Work** — I implement. Notes go in `.td/work/<topic>.md`.
4. **Test** — I follow `.td/WORKWAY.md` (Local testing → Local UAT → Production / Ship sections).
5. **Ship** — push to `origin/main` when everything is green. Big, meaningful pushes — the commit log is the history.
6. **Close** — before context reset, I review the code, validate it, update `.td/STATE.md` with anything that survives context loss, **remove any docs that git already covers**, and push.

GitHub is my work memory. I don't duplicate one-off findings into docs — git remembers. If the user later asks "why did we do X," I `git log` and answer.

## The docs (`.td/`)

- `PROJECT.md` — what this is, who it's for, stack, active scope, shipped.
- `WORKWAY.md` — how to test locally, how to UAT, how to ship to production, framework-specific notes. The single source for "how do we do things in this project." I update it when the user tells me how something works.
- `STATE.md` — current phase, current topic, blocker, resume note. ≤30 lines. Rewritten by me.
- `BACKLOG.md` — parked items: bigger work I noticed but isn't in scope yet. Append-only.
- `work/<topic>.md` — active work. Deleted at close.

Anything not covered above probably doesn't need a doc — git or the existing five files cover it.

## Rails (the few things I always do)

- On every fresh context, read `CLAUDE.md`, `.td/STATE.md`, `.td/PROJECT.md`. Orient before responding.
- Run `WORKWAY.md` § Local testing before pushing. Failing test → no commit, no push.
- One commit per shipped piece. Push to `origin/main`. No PRs.
- At close, run the cleanup ritual: review, validate, update STATE, remove redundant docs, push.

## Nudges I do without being asked

- Before a meaningful piece of work: **"Before I dive in, anything else on your mind that should ride along?"** — collects related items so we don't fragment.
- When the conversation drifts through small unrelated stuff: **"We're scattered — want to wrap and start fresh?"** — hint to the user to `/clear`.
- Before context close: I run the cleanup ritual without being asked.

## Where things go (natural-language → doc)

When the user tells me something at the start of a message, action-shaped:

- "test command is X" / "this is how we local-test" → `.td/WORKWAY.md` § Local testing
- "this is how UAT works" / "manual check is X" → `.td/WORKWAY.md` § Local UAT
- "live URL is X" / "deploy is X" / "logs are at X" → `.td/WORKWAY.md` § Production / Ship
- "we use Laravel Boost / Next / X" / framework-specific gotcha → `.td/WORKWAY.md` § Framework specifics
- "stack is X" / "scope changes to X" → `.td/PROJECT.md`
- "remember to X later" / "park this" → append `.td/BACKLOG.md`
- "feedback on td-flow" → append `~/projects/td/FEEDBACK.md`
- "let's add X" / "fix X" / "build X" → start the rhythm at step 1, write `.td/work/<topic>.md`
- "ship it" / "we're done" → run steps 4–6
- "where are we" → read STATE.md, summarize
- "save this as a template" / "make this a `<name>` starter" → copy current `.td/` shape (anonymized) to `~/projects/td/templates/<name>/`
- "let's wrap" / "save it" / about to /clear → suggest `/td-clear` (or run the equivalent close ritual if user already typed `/td-clear`)

Mid-conversation mentions of testing or deploy do not trigger updates — only explicit, action-shaped statements at the start of a message do.

## Commit messages

- Topic piece: `feat(<topic>): <one-line>` or `fix(<topic>): <one-line>`
- Doc-only: `docs: <what changed>`
- Cleanup at close: `chore: close <topic>`
- Framework cleanup: `chore: restore CLAUDE.md, relocate <name> guidelines`

## Principles

- Three similar lines beats a premature abstraction.
- Tests are the contract.
- Ship fast, fix fast.
- Complexity without user-visible value doesn't belong.

## The two slash commands

- `/td-init` — bootstrap or migrate a project (one-time per project).
- `/td-clear` — review, validate, cleanup, push. Run before `/clear` so the next session picks up cold.

Everything else is conversational.
