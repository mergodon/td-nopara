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

Another project's repo is another team's territory, even when the same human wears both hats. I read freely. I do NOT commit, push, run tests, trigger pre-commit hooks, start their dev servers, or otherwise touch their lifecycle. The way to ask another project to do something is to file a GitHub issue.

`.td/PROJECT.md § Cross-repo` is the per-project registry of repos this project legitimately files against. The section is opt-in — only present when the project has a real cross-repo relationship to declare. For the friendly-name → GH slug lookup across the user's whole portfolio (when you can't remember which slug is which), see `~/projects/td/SERVICES.md` — the meta-registry. To file:

1. Check `.td/PROJECT.md § Cross-repo`. If the target isn't listed, ask the user before filing.
2. `gh repo view <slug>` to verify access. Read its README (and `.td/PROJECT.md` if it's a td-flow project) for enough context to write a meaningful body.
3. `gh issue create --repo <slug> --title "..." --body "..."`. Body has: the ask, the why, and the source (this commit / this file / current session).
4. Discuss in `gh issue comment <id> --repo <slug>`. The receiver closes via `Closes <slug>#N` in a commit message — auto-links both sides.

No labels, no status enum, no separate inbox. Open = pending; closed = done.

**Inbox stays repo-scoped by default.** "CRs?" / "any incoming?" / warm-up checks run `gh issue list --state open` for the **current repo only**. I do NOT widen to all your repos unless you explicitly ask ("all repos", "global inbox", "everything open", "what's open across the board"). Issues in other repos are their projects' business — not background context to surface here. The `## Cross-repo` registry tells me which repos this project *files into*, not which I should *poll*.

## The docs (`.td/`)

- `PROJECT.md` — what this is, who for, stack, active scope, shipped.
- `WORKWAY.md` — how to test locally (and the workaround when I can't), how to UAT, how to ship to production, framework-specific notes. The single source for "how do we do things in this project."
- `STATE.md` — current phase, current topic, blocker, resume note. Resume note can be as long as needed — that's where planning lives.
- `BACKLOG.md` — bigger items I noticed but aren't in scope. Append-only.
- `work/<topic>.md` — active work; deleted at close.

If something doesn't fit one of those five surfaces, it probably doesn't need a doc — git or the existing docs cover it.

## Nudges I do without being asked

- At the first message of a fresh session: if `STATE.Topic` is not idle, I summarize where we are (one line: topic, last, next step) before answering. Also run `gh issue list --state open` and surface incoming asks (one line, or "(inbox empty)") alongside the STATE summary.
- Before a meaningful piece of work: **"Before I dive in, anything else on your mind that should ride along?"**
- **"Lets do it" / "go ahead" / "yes" / "do it" / "ok" in response to a proposal I just made** — that *is* the start of meaningful work, not a clearance to skip. I run the "anything else on your mind?" nudge before starting, not after.
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

## Drift signals I surface

I watch for these and flag with one line — the user decides:

- `work/<topic>.md` cold for 7+ days → "still active, BACKLOG, or drop?"
- `STATE.Topic` and `work/<topic>.md` disagree → ask which is right.
- PROJECT.md "Active scope" item has shipping commits → propose moving to Shipped.
- WORKWAY test command no longer exists in `package.json`/equivalent → flag.
- BACKLOG > 15 items → suggest triage at next `/td-clear`.
- 5+ local commits ahead of `origin/main` → ask if holding for a reason.
- Root `CLAUDE.md` drifted from canonical and the user didn't say so → ask if Boost/Cursor/etc. overwrote it.
- Stack signals changed (new framework file, removed dependency) and `WORKWAY.md` § Framework specifics not updated → flag.
- I've fixed the same kind of issue 3+ times → ask about root cause.
- About to commit a file that looks like a secret (`.env`, token, key) → stop and confirm.

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
- "file an issue for X" / "ask X to do Y" / "send a CR to X" → check `.td/PROJECT.md § Cross-repo`, then `gh issue create --repo <slug>` with body = ask + why + source.
- "any incoming?" / "check the inbox" / "CRs?" → `gh issue list --state open` (current repo ONLY — the default; never widen here).
- "all repos?" / "global inbox" / "everything open" / "what's open across the board?" → `gh search issues --owner <owner> --involves @me --state open` (cross-repo, only on explicit ask; flag form, not quoted-string).
- "ship it" / "we're done" / "push it" → tests pass, commit the piece, push to `origin/main`. Conversational — no slash command.
- "let's clear" / "save it" / about to /clear mid-project → `/td-clear`
- "wrap the project" / "we're done with this" / project actually finished → `/td-close`
- "where are we" → read STATE.md, summarize
- "save this as a `<name>` template" → copy current `.td/` shape (anonymized) to `~/projects/td/templates/<name>/`

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

## The three slash commands

- `/td-init` — bootstrap or migrate a project (one-time per project).
- `/td-clear` — mid-project context reset. Save STATE handoff, light prune, push. Run before `/clear` when the project continues.
- `/td-close` — wrap the project (or a major phase). Full doc audit, prune everything `git log` covers, push.

Everything else — including shipping individual pieces — is conversational.
