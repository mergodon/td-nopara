# How to work in this repo (td-flow)

This file is the contract. It does not change project-to-project. Project-specific things live in `.td/`. Frameworks must not write here — see "Framework guidelines" below.

## The five living files

Always read these first. Never append (except INBOX.md), always rewrite to current truth.

- `.td/PROJECT.md` — what this is, who for, stack, current scope, shipped, out of scope. Edited freely; reflects the present.
- `.td/TESTING.md` — how to test this project. The single source for test commands and the pre-ship checklist.
- `.td/ENV.md` — live environment: URLs, deploy command, dashboards, where logs are, where secrets live (names only — actual values stay in `.env`, gitignored).
- `.td/STATE.md` — where we are right now. ≤50 lines. Rewritten after every meaningful action. Past sessions are not kept here — git is the log.
- `.td/INBOX.md` — bugs and ideas captured mid-flow via `/td-note`. Append-only. Items get deleted when they ship.

## The two flows

Pick one based on size. Never run both at once.

### BIG — for features, anything non-trivial
1. **Discuss** — ask 3–5 bullet questions, write `.td/flow/00-brief.md`.
2. **Plan** — break into pieces. Each piece must be ≤30 minutes of work, describable in one sentence, with one obvious test. Stub each piece as `.td/flow/01-name.md`, `.td/flow/02-name.md`, etc. Write the index in `.td/flow/plan.md`.
3. **Reality check** — re-read the plan and ask the user: (a) "Are we overcomplicating?" (b) "Are pieces too big? What can split?" Plan locks only after user confirms.
4. **Execute pieces in order** with `/td-ship`. One piece per ship.
5. **Wrap** — when all pieces done, update `.td/PROJECT.md` (move from "active scope" to "shipped"), delete `.td/flow/`.

### SMALL — for fixes, tweaks, small things
1. Write a one-page `.td/flow/fix.md`: goal, plan, how to test.
2. Do it. Test. `/td-ship`.
3. Delete `.td/flow/`.

No discussion phase, no plan, no numbered pieces, no reality check.

## Commit & push policy

- **One piece = one commit. One fix = one commit.** No "wip", no "fix typo". Mid-piece work stays unstaged. If you need a checkpoint, use `/td-reset`.
- **Auto-push to `origin/main` on every successful `/td-ship`.** Tests pass = commit = push. No PRs, no branches, no force-pushes.
- **Commit message format** (so `git log --oneline` is the audit trail):
  - BIG piece: `feat(<feature>): 02 wire-api`
  - SMALL fix: `fix: search overflowing on mobile`
  - Framework cleanup: `chore: relocate <name> guidelines out of CLAUDE.md`
  - Init: `chore: td-flow init`

## Test policy

`.td/TESTING.md` defines the pre-ship checklist. `/td-ship` runs it. **Failing checklist = no commit, no push.** Update `TESTING.md` if the checklist changes — never skip it silently.

A pre-commit hook installed by `/td-init` runs the test command from `TESTING.md`. Don't bypass it (no `--no-verify`).

## Framework guidelines

Framework-specific instructions (Laravel Boost, Next.js, Tailwind, shadcn, etc.) live in `.td/frameworks/<name>.md`, never here. If a framework tool writes to this file, run `/td-cleanup` to relocate it.

When working with a framework, read `.td/frameworks/<name>.md` first.

## Principles (lifted from gsd-2 VISION, kept because they're right)

- **Three similar lines is better than a premature abstraction.**
- **Tests are the contract.** If behavior changes, tests tell you what broke.
- **Ship fast, fix fast.** Every commit works. Iterate over the live thing.
- **Complexity without user-visible value doesn't belong.**
- **Don't add error handling, fallbacks, or validation for cases that can't happen.**

## Reset policy (before /clear)

Run `/td-reset`:
- Squashes any local checkpoint commits ahead of `origin/main` into a clean message
- Rewrites `.td/STATE.md` so a fresh conversation picks up cold
- Pushes the squashed commit

Never force-push commits that are already on `origin/main`.

## The eight commands

| Command | Job |
|---|---|
| `/td-init` | Bootstrap a project. Brownfield-aware: maps existing files, asks for gaps, fills `.td/`. |
| `/td-feature <name>` | Start a BIG flow: discuss → plan → reality check. |
| `/td-fix <description>` | Start a SMALL flow. |
| `/td-note <text>` | Append a bug or idea to `.td/INBOX.md` mid-flow. Does not interrupt current work. |
| `/td-ship` | Do the next piece (BIG) or the fix (SMALL): work + test + commit + push + advance. |
| `/td-status` | Print `STATE.md` summary: position, last action, next piece, blocker, inbox count. |
| `/td-reset` | Squash local-only commits, write handoff into `STATE.md`, push. Run before `/clear`. |
| `/td-cleanup` | Detect framework pollution in this file; relocate to `.td/frameworks/`. Manual only. |

That's the whole framework. Anything not covered here is implementation freedom — choose the library, choose the structure, follow `.td/PROJECT.md` for scope.
