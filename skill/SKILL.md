---
name: td-flow
description: Solo-developer project framework. Conversational interface, structured docs in .td/. Use when the user mentions td-flow, /td-init, or asks how this project works. After /td-init, the user just talks — Claude orchestrates.
---

# td-flow

Same shape every project. Conversational interface. Five docs. One slash command.

## When to use

- The user runs `/td-init` and asks how to proceed.
- The user mentions td-flow, the rhythm, or any of the structured docs.
- The user asks "where are we" or "how do I test this" and a `.td/` directory exists.
- The user says "save this as a `<name>` template" — copy the current `.td/` shape into `~/projects/td/templates/<name>/`.
- The user mentions a framework polluting CLAUDE.md (Boost, etc.) — restore CLAUDE.md from canonical, log relevant notes into `.td/WORKWAY.md` § Framework specifics.

## The rhythm

1. **Plan** — single-shot or multi-step. Plan goes in `.td/work/<topic>.md`.
2. **Park** — anything bigger I notice but isn't in scope → `.td/BACKLOG.md`.
3. **Work** — implement.
4. **Test** — follow `.td/WORKWAY.md` (Local testing → Local UAT → Production / Ship).
5. **Ship** — push to `origin/main` when green.
6. **Close** — review, validate, update STATE, remove redundant docs, push.

GitHub is the work memory. Big meaningful pushes. No duplication.

## Files in every project

```
CLAUDE.md                ← contract at root, user controls it
.td/
  PROJECT.md             ← what / who / stack / scope
  WORKWAY.md             ← Local testing + Local UAT + Production/Ship + Framework specifics
  STATE.md               ← current phase, current topic, blocker, resume note
  BACKLOG.md             ← parked bigger items
  work/<topic>.md        ← active work, deleted at close
.env.example             ← committed
.env                     ← gitignored
.git/hooks/pre-commit    ← runs Test command from WORKWAY.md § Local testing
```

## Where things go (natural-language → doc)

- "test command is X" / "this is how local testing works" → `.td/WORKWAY.md` § Local testing
- "this is how UAT works" → `.td/WORKWAY.md` § Local UAT
- "live URL is X" / "deploy is X" → `.td/WORKWAY.md` § Production / Ship
- "we use Laravel/Next/X" / framework gotcha → `.td/WORKWAY.md` § Framework specifics
- "stack changes to X" / "scope is X" → `.td/PROJECT.md`
- "remember to X later" / "park this" → `.td/BACKLOG.md`
- "feedback on td-flow" → `~/projects/td/FEEDBACK.md`
- "let's add X" / "fix X" → start rhythm step 1, write `.td/work/<topic>.md`
- "ship it" / "we're done" → run steps 4–6
- "save this as a `<name>` template" → copy `.td/*` (anonymized) to `~/projects/td/templates/<name>/`
- "where are we" → read STATE.md, summarize
- "let's wrap" / before /clear → run close ritual

## Nudges

- Before meaningful work: "Before I dive in, anything else on your mind that should ride along?"
- When drifting: "We're scattered — want to wrap and start fresh?"
- Before context close: cleanup ritual without being asked.

## The two slash commands

```
/td-init                    # bootstrap or migrate a project (brownfield-aware)
/td-init --template <name>  # bootstrap from a saved template (e.g. laravel)
/td-clear                   # review + validate + cleanup + push before /clear
```

Migration: `/td-init` detects existing td-flow v1/v2 or rgb-buddy-2-style conventions (`.claude/agreements/`, `ARCHITECTURE.md`, `BLOCKS.md`) and maps them to v3 without re-asking.
