---
name: td-flow
description: Solo-developer project framework. Conversational interface, structured docs in .td/. Use when the user mentions td-flow, /td-init, /td-clear, /td-close, /td-refresh, /td-mailbox, /td-health, /td-incident, /td-park, or asks how this project works. After /td-init, the user just talks — Claude orchestrates.
---

# td-flow

Same shape every project. Conversational interface. Four standard docs. Eight slash commands.

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
4. **Test** — follow `.td/WORKWAY.md` (Local testing → Local UAT → Live).
5. **Ship** — push to `origin/main` when green.
6. **Close** — review, validate, prune redundant docs, push.

GitHub is the work memory. Big meaningful pushes. No duplication.

## Files in every project

```
CLAUDE.md                ← td-flow contract; managed by /td-refresh
.td/
  PROJECT.md             ← what / who / stack / scope
  WORKWAY.md             ← Local testing + Local UAT + Live + Framework specifics
  STATE.md               ← current phase, current topic, blocker, resume note
  BACKLOG.md             ← session-scoped parking
  work/<topic>.md        ← active work scratch, deleted at close
  DEBUG.md  (optional)   ← troubleshooting reference, created on demand
.env.example             ← committed
.env                     ← gitignored
.git/hooks/pre-commit    ← runs Test command from WORKWAY.md § Local testing
```

## The slash commands

```
/td-init                    # bootstrap or migrate (brownfield-aware)
/td-init --template <name>  # bootstrap from a saved template (e.g. laravel)
/td-clear                   # mid-project: doc-sync + STATE handoff + prune + push. Before /clear.
/td-close                   # wrap project (or phase): full doc audit + prune + push.
/td-refresh                 # sync the project with the framework — auto-merge canonical CLAUDE.md.
/td-mailbox                 # unified cross-repo walk: inbound + outbound in one pass.
/td-health                  # proactive production health check — run .td/health.sh, report.
/td-incident                # live production fire mode — focus, diagnose, fix or park.
/td-park                    # flush BACKLOG.md to GH Issues (with type + dedupe) mid-session.
```

Shipping individual pieces is conversational: tests pass → commit → push to `origin/main`. No slash command.

Migration: `/td-init` detects existing td-flow v1/v2 or brownfield repos with ad-hoc patterns (`.claude/agreements/`, `BLOCKS.md` and similar) and maps them to the current shape without re-asking.

For the routing map, nudges, drift signals, and commit conventions — read root `CLAUDE.md`.
