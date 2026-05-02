# How to work in this repo (td-flow)

This is the contract. Identical across every td-flow project. The conversation is the interface; the docs in `.td/` are the structure. Don't add things here — see "Framework guidelines" below.

## The cycle (6 phases as checkpoints)

Every piece of work moves through these phases. A session can cover any subset — single phase or all six. STATE.md tracks where we are.

1. **PLAN**     — what are we building, in pieces, and how will it be tested?
2. **EXECUTE**  — do the pieces. One commit per piece.
3. **TEST**     — run the Local testing pre-ship checklist from `.td/TESTING.md`.
4. **SHIP**     — push to `origin/main`. Deploy follows automatically per `.td/ENV.md`.
5. **VALIDATE** — run the Live testing post-ship checklist from `.td/TESTING.md`. Skip silently if "none".
6. **DOCUMENT** — update `.td/PROJECT.md` (Active → Shipped). Clear `.td/work/<topic>.md`. Set `STATE.md` to idle.

If a session ends mid-cycle, STATE.md captures the phase. Next session resumes there.

## The docs (`.td/`)

Six files. Same shape every project. Only values differ.

- `PROJECT.md` — what / who / stack / active scope / shipped
- `TESTING.md` — Local testing + Live testing (locked sections)
- `ENV.md` — live URL, deploy, dashboards, logs
- `STATE.md` — current phase, current topic, blocker, resume note (≤50 lines, rewritten by me)
- `INBOX.md` — bugs/ideas captured mid-flow (append-only)
- `frameworks/<name>.md` — framework guidelines (Laravel Boost, etc.) so they don't pollute CLAUDE.md

`.td/work/<topic>.md` — the active work file. One per topic. Sections for plan / execute notes / test results / validate notes. Deleted at phase 6.

## Rails (the few things I always do)

- On every fresh context, read `CLAUDE.md`, `.td/STATE.md`, `.td/PROJECT.md`. Orient before responding.
- Run `TESTING.md` § Local testing pre-ship checklist before phase 4. Failing check = no commit, no push.
- One commit per piece. Push to `origin/main` directly. No PRs. Never bypass the pre-commit hook.
- Run `TESTING.md` § Live testing post-ship validation as phase 5 (skip if section is "none").
- At phase 6, update `PROJECT.md` and clear `.td/work/<topic>.md`. Reset `STATE.md` to idle.
- When the user signals wrap-up ("let's wrap", "save it", mentions of `/clear`), rewrite `STATE.md` as a handoff with current phase and a 2–4 line resume note.
- When a framework writes guidelines into CLAUDE.md, relocate them to `.td/frameworks/<name>.md`.

## Where things go (natural-language → doc map)

When the user says any of these (at the start of a message, action-shaped), this is the destination:

- "test command is X" / "this is how local testing works" → `.td/TESTING.md` § Local testing
- "deploy is X" / "this is how live testing works" / "smoke check is X" → `.td/TESTING.md` § Live testing
- "live URL is X" / "logs are at X" / "dashboard is at X" → `.td/ENV.md`
- "stack changed to X" / "we use X for Y" / "scope is X" → `.td/PROJECT.md`
- "remember to X" / "park this idea" / "don't forget X" → append `.td/INBOX.md`
- "feedback on td-flow" / "td-flow should X" → append `~/projects/td/FEEDBACK.md`
- "let's add X" / "fix the bug X" / "build X" → start cycle at phase 1, write `.td/work/<topic>.md`
- "ship it" / "we're done" / "looks good" → run phases 3 → 6
- "where are we" / "status" → read STATE.md, summarize
- "let's wrap" / "save it" / about to /clear → rewrite STATE.md as handoff

Mid-conversation mentions of testing or deployment do not trigger updates — only explicit, action-shaped statements at the start of a message do.

## Commit message format

So `git log --oneline` is the audit trail:

- Piece in a cycle: `feat(<topic>): <short summary>` or `fix(<topic>): <short summary>`
- Doc-only update: `docs: <what changed>`
- Inbox entry: `chore: inbox — <bug|idea>: <first 50 chars>`
- Framework cleanup: `chore: relocate <name> guidelines out of CLAUDE.md`

## Framework guidelines

Framework-specific instructions (Laravel Boost, Next.js, Tailwind, shadcn) live in `.td/frameworks/<name>.md`, never here. If a framework tool writes to this file, relocate the content the next time you notice. CLAUDE.md is a stable contract.

## Principles (anti-bloat)

- Three similar lines beats a premature abstraction.
- Tests are the contract.
- Ship fast, fix fast.
- Complexity without user-visible value doesn't belong.
- Don't add error handling, fallbacks, or validation for cases that can't happen.

## The one slash command

Just `/td-init` — bootstraps a new project's `.td/` from a known template. Everything else is conversational.
