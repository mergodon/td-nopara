# td-flow

A minimal, file-based, repo-portable framework for solo development.

Every project gets the same structured docs and the same 6-phase cycle (plan / execute / test / ship / validate / document). The conversation is the interface. There's one slash command, `/td-init`, and after that you just talk.

## Install

```
git clone https://github.com/mergodon/td-nopara ~/projects/td
cd ~/projects/td
./install.sh
```

Symlinks created:
- `~/.claude/commands/td-init.md`
- `~/.claude/skills/td-flow`
- `~/.claude/td-templates`

To update on any machine: `git pull && ./install.sh`.

## Use

In any project directory:

```
claude
/td-init
```

`/td-init` is brownfield-aware — it maps existing files (`package.json`, framework configs, `README.md`) and asks for the gaps before writing `.td/`.

After init, just talk:

- "let's add a search bar" — starts the cycle at phase 1
- "test command is `npm test`" — updates `.td/TESTING.md` § Local testing
- "live URL is myapp.pages.dev" — updates `.td/ENV.md`
- "remember to debounce search" — appends `.td/INBOX.md`
- "ship it" — runs phases 3–6
- "where are we" — reads `.td/STATE.md`
- "let's wrap" — rewrites `.td/STATE.md` as a handoff before `/clear`

## The cycle

```
1. PLAN      — what are we building, in pieces, and how will it be tested?
2. EXECUTE   — do the pieces. One commit per piece.
3. TEST      — run TESTING.md § Local testing pre-ship checklist.
4. SHIP      — push to origin/main. Deploy follows automatically per ENV.md.
5. VALIDATE  — run TESTING.md § Live testing post-ship checklist (skip if "none").
6. DOCUMENT  — update PROJECT.md, clear .td/work/<topic>.md, STATE.md → idle.
```

A session can cover any subset of phases — single stage or multi-stage. STATE.md tracks where you are; the next session picks up cold.

## Files in every td-flow project

```
CLAUDE.md                    ← stable contract, identical across projects
.td/
  PROJECT.md                 ← what / who / stack / scope
  TESTING.md                 ← Local testing + Live testing (locked sections)
  ENV.md                     ← live URL, deploy, dashboards
  STATE.md                   ← current phase, current topic, resume note
  INBOX.md                   ← bugs/ideas captured mid-flow
  frameworks/                ← framework guidelines (Laravel Boost etc.)
  work/<topic>.md            ← active work (one file per topic, deleted at phase 6)
.env.example                 ← committed, lists secret names
.env                         ← gitignored, real values
.git/hooks/pre-commit        ← runs Test command from TESTING.md § Local testing
```

## Repo layout (this repo)

```
commands/td-init.md   the only slash command
templates/            files copied into target projects on /td-init
  CLAUDE.md           the universal contract
  td/PROJECT.md
  td/TESTING.md       the locked-shape testing doc
  td/ENV.md
  td/STATE.md
  td/INBOX.md
  td/frameworks/.gitkeep
  .gitignore
  .env.example
  FEEDBACK.md         template for the framework-level feedback file
skill/SKILL.md        skill definition (symlinked into ~/.claude/skills/td-flow)
hooks/pre-commit      test-on-commit hook installed by /td-init
install.sh            symlinks commands, skill, templates into ~/.claude/
FEEDBACK.md           feedback about td-flow itself, captured from any project
```

## Principles

Lifted from gsd-2 VISION and kept verbatim:

- Three similar lines beats a premature abstraction.
- Tests are the contract.
- Ship fast, fix fast.
- Complexity without user-visible value doesn't belong.

## Not in scope (yet)

- Research / context7 step before phase 1 — useful, deferred.
- Subagents for parallel pieces — useful, deferred.
- Anything that turns this into a CLI or npm package.
