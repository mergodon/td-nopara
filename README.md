# td-flow

A minimal, file-based, repo-portable framework for solo development.

Every project gets the same shape: one `CLAUDE.md` contract, four small living files in `.td/`, two flows (BIG and SMALL), seven slash commands. Git is the only history log. No CLI, no daemon, no global state.

## Install

```
git clone https://github.com/mergodon/td ~/projects/td
cd ~/projects/td
./install.sh
```

This symlinks:
- `commands/td-*.md` → `~/.claude/commands/`
- `skill/` → `~/.claude/skills/td-flow`
- `templates/` → `~/.claude/td-templates`

To update on any machine: `git pull && ./install.sh`.

## Use

In any project directory:

```
claude
/td-init
```

`/td-init` is brownfield-aware — it maps existing files (package.json, framework configs, README) and asks for the gaps before writing `.td/`.

## The ten commands

| Command | Job |
|---|---|
| `/td-init` | Bootstrap td-flow in this directory. |
| `/td-feature <name>` | Start a BIG flow: discuss → plan → reality check. |
| `/td-fix <description>` | Start a SMALL flow. |
| `/td-note <text>` | Capture a bug or idea about THIS project (`.td/INBOX.md`). |
| `/td-feedback <text>` | Capture a bug or idea about td-flow itself (filed to the framework repo). |
| `/td-ship` | Do the next piece (BIG) or the fix (SMALL): work + test + commit + push. |
| `/td-status` | Print current state. |
| `/td-reset` | Squash local-only commits, write a handoff into STATE.md, push. Run before `/clear`. |
| `/td-cleanup` | Detect framework pollution in `CLAUDE.md`, relocate to `.td/frameworks/`. |
| `/td-help` | One-screen cheat sheet. |

## Files in every td-flow project

```
CLAUDE.md                    ← stable contract, identical across projects
.td/
  PROJECT.md                 ← what / who / stack / scope
  TESTING.md                 ← test command + pre-ship checklist
  ENV.md                     ← live env (URLs, deploy, dashboards)
  STATE.md                   ← where we are now (≤50 lines, rewritten)
  INBOX.md                   ← bugs and ideas captured via /td-note
  frameworks/                ← redirect target for framework injections
  flow/                      ← active work; deleted on completion
.env.example                 ← committed; lists secret names
.env                         ← gitignored; real values
.git/hooks/pre-commit        ← runs the test command from .td/TESTING.md
```

## Repo layout (this repo)

```
commands/        → slash command source (symlinked into ~/.claude/commands/)
templates/       → files copied into target projects on /td-init
skill/SKILL.md   → skill definition (symlinked into ~/.claude/skills/td-flow)
hooks/pre-commit → test-on-commit hook installed by /td-init
install.sh       → symlinks commands, skill, templates into ~/.claude/
```

## Principles

Lifted from gsd-2's VISION.md and kept verbatim:

- Three similar lines is better than a premature abstraction.
- Tests are the contract.
- Ship fast, fix fast.
- Complexity without user-visible value doesn't belong.

## Not in scope (yet)

- Research / web context / context7 — useful, deferred.
- Subagents / parallel pieces — useful, deferred.
- Anything that turns this into a CLI or npm package.
