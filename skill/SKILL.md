---
name: td-flow
description: Solo-developer project framework. Conversational interface, structured docs in .td/. Use when the user mentions td-flow, /td-init, the cycle (plan / execute / test / ship / validate / document), or asks how this framework works. After /td-init, the user just talks — no other slash commands.
---

# td-flow

A minimal, file-based, repo-portable framework for solo development. Every project gets the same shape so the user never has to re-explain.

## When to use

- The user runs `/td-init` and asks how to proceed.
- The user mentions td-flow, the cycle, or any of the structured docs.
- The user asks "where are we" or "how do I test this" and a `.td/` directory exists.
- The user mentions framework pollution in `CLAUDE.md` (Laravel Boost etc.) — relocate to `.td/frameworks/`.

## The cycle

```
1. PLAN      — what are we building, in pieces, and how will it be tested?
2. EXECUTE   — do the pieces. One commit per piece.
3. TEST      — run TESTING.md § Local testing pre-ship checklist.
4. SHIP      — push to origin/main.
5. VALIDATE  — run TESTING.md § Live testing post-ship checklist (skip if "none").
6. DOCUMENT  — update PROJECT.md, clear .td/work/<topic>.md, STATE.md → idle.
```

A session can cover any subset. STATE.md captures which phase we're in; next session resumes.

## Files in every project

```
CLAUDE.md                    ← stable contract, identical across projects
.td/
  PROJECT.md                 ← what / who / stack / scope
  TESTING.md                 ← Local testing + Live testing (locked sections)
  ENV.md                     ← live URL, deploy, dashboards
  STATE.md                   ← current phase, current topic, resume note
  INBOX.md                   ← bugs/ideas captured mid-flow
  frameworks/                ← framework guidelines (kept out of CLAUDE.md)
  work/<topic>.md            ← active work (one file, deleted at phase 6)
.env.example                 ← committed, lists secret names
.env                         ← gitignored, real values
.git/hooks/pre-commit        ← runs Test command from TESTING.md § Local testing
```

## Natural-language → doc map

The user just talks. CLAUDE.md tells Claude where each kind of statement lands:

- "test command is X" → TESTING.md § Local testing
- "deploy is X" / "smoke check is X" → TESTING.md § Live testing
- "live URL is X" / "logs are at X" → ENV.md
- "stack is X" / "scope changes to X" → PROJECT.md
- "remember to X" → INBOX.md
- "feedback on td-flow" → ~/projects/td/FEEDBACK.md
- "let's add X" / "fix the bug X" → start cycle, write .td/work/<topic>.md
- "ship it" / "we're done" → run phases 3 → 6
- "where are we" → read STATE.md
- "let's wrap" / before /clear → rewrite STATE.md as handoff

## The one slash command

```
/td-init
```

Bootstraps a new (or existing) project's `.td/` directory. Brownfield-aware. Everything after is conversational.
