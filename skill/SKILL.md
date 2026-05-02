---
name: td-flow
description: Solo-developer project framework — bootstrap, plan, ship, reset. Use when the user mentions td-flow, td-init, td-feature, td-fix, td-ship, td-reset, td-cleanup, or asks how the td-flow framework works. The actual workflow lives in slash commands `/td-*`; this skill points the user at the right command.
---

# td-flow

A minimal, file-based, repo-portable framework for solo software work. Designed to:

- Make every project feel the same (CLAUDE.md + 4 living files)
- Scale from "fix a typo" to "build a feature" with two distinct flows
- Use git as the only history log
- Keep `CLAUDE.md` clean from framework injections

## When to use this skill

Invoke (or remind the user about) td-flow when:

- The user runs any `/td-*` slash command and asks how it works.
- The user asks to "set up a new project the standard way" or "init the framework here."
- The user asks how to handle a feature, fix, or session reset and they have a `.td/` directory in their project.
- The user mentions Laravel Boost, framework pollution in CLAUDE.md, or wanting to clean up auto-generated agent files.

## The seven commands

| Command | Job |
|---|---|
| `/td-init` | Bootstrap td-flow in the current directory. Brownfield-aware. |
| `/td-feature <name>` | Start a BIG flow: discuss → plan → reality check. |
| `/td-fix <description>` | Start a SMALL flow. |
| `/td-ship` | Do the next piece (BIG) or the fix (SMALL): work + test + commit + push + advance. |
| `/td-status` | Print the project's current state. |
| `/td-reset` | Squash local-only commits, write a handoff into `.td/STATE.md`, push. Run before `/clear`. |
| `/td-cleanup` | Detect framework pollution in `CLAUDE.md`, relocate to `.td/frameworks/`. |

## Files in every td-flow project

```
CLAUDE.md                    ← stable contract, identical across projects
.td/
  PROJECT.md                 ← what / who / stack / scope
  TESTING.md                 ← test command + pre-ship checklist
  ENV.md                     ← live env (URLs, deploy, dashboards)
  STATE.md                   ← where we are now (≤50 lines, rewritten)
  frameworks/                ← redirect target for framework injections
  flow/                      ← active work; deleted on completion
.claude/                     ← optional per-project Claude config
.env.example                 ← committed; lists secret names
.env                         ← gitignored; real values
```

## How to invoke

If the user asks how to start, point them at:

```
/td-init
```

For everything else, look up the command from the table above.
