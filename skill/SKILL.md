---
name: td-flow
description: Solo-developer project framework. Conversational interface, structured docs in .td/. Use when the user mentions td-flow, /td-init, /td-clear, /td-close, /td-refresh, /td-inbox, /td-incident, /td-park, or asks how this project works. After /td-init, the user just talks — Claude orchestrates.
---

# td-flow

Same shape every project. Conversational interface. Five docs. Seven slash commands.

The contract — including the "Who does what" matrix, the routing map ("where things go"), nudges, drift signals, and commit conventions — lives in root `CLAUDE.md`. This skill exists to surface the rhythm when context is heavy or `CLAUDE.md` isn't loaded yet. **Read root `CLAUDE.md` for anything specific.**

## When to engage

- The user runs `/td-init` and asks how to proceed.
- The user mentions td-flow, the rhythm, or any of the structured docs.
- The user asks "where are we" or "how do I test this" and `.td/` exists.
- The user says "save this as a `<name>` template" — copy the current `.td/` shape (anonymized) to `~/projects/td-flow/templates/<name>/`.
- The user mentions a framework polluting `CLAUDE.md` (Boost, etc.) — restore from canonical, log salvage into `.td/WORKWAY.md` § Framework specifics.

## The rhythm (plan → work → test → ship → close)

1. **Plan** — single-shot or multi-step. Multi-step plans live in `.td/work/<topic>.md`.
2. **Park** — out-of-scope items I notice → `.td/BACKLOG.md`.
3. **Work** — implement.
4. **Test** — follow `.td/WORKWAY.md` (Local testing → Local UAT → Production / Ship).
5. **Ship** — push to `origin/main` when green.
6. **Close** — review, validate, prune redundant docs, push.

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

## The slash commands

```
/td-init                    # bootstrap or migrate (brownfield-aware)
/td-init --template <name>  # bootstrap from a saved template (e.g. laravel)
/td-clear                   # mid-project: STATE handoff + light prune + push. Before /clear.
/td-close                   # wrap project (or phase): full doc audit + prune + push.
/td-refresh                 # review deltas between this project's CLAUDE.md and canonical.
/td-inbox                   # walk open GH issues (grouped by Issue Type): close, comment, or skip.
/td-incident                # live production fire mode — focus, diagnose, fix or park.
/td-park                    # flush BACKLOG.md to GH Issues (with type + dedupe) mid-session.
```

Shipping individual pieces is conversational: tests pass → commit → push to `origin/main`. No slash command.

Migration: `/td-init` detects existing td-flow v1/v2, GSD-style legacy planning conventions, or brownfield repos with ad-hoc patterns (`.claude/agreements/`, `ARCHITECTURE.md`, `BLOCKS.md` and similar) and maps them to v3 without re-asking.

For the routing map, nudges, drift signals, and commit conventions — read root `CLAUDE.md`.
