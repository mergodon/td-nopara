# td-flow

## What this is

The **td-flow** framework itself: a minimal, file-based, repo-portable working agreement for solo development. Same shape every project, conversational interface, structured docs in `.td/`, GitHub commits as memory. Three slash commands (`/td-init`, `/td-clear`, `/td-close`) — everything else is conversational.

## Who it's for

Mate (solo developer working with Claude). Used across `mergodon/rgb-*` projects and any future repos.

## Stack & choices

- Markdown-only — no compiled code, no npm package, no CLI binary.
- Bash for `install.sh` and the pre-commit hook.
- AWK for extracting the test command from `WORKWAY.md` § Local testing.
- Hosted at `mergodon/td-nopara` (private). Cloned to `~/projects/td/` on each machine.
- Distributed as symlinks into `~/.claude/commands/`, `~/.claude/skills/td-flow`, and `~/.claude/td-templates` via `install.sh`.

## Active scope

(none — v3 just shipped; awaiting first real-project test)

## Shipped

- v1 (initial scaffold, 10 slash commands, BIG/SMALL split)
- v2 (collapsed to 7 commands, 6-phase cycle, locked TESTING.md sections)
- v3 (3 slash commands: init/ship/close; conversational interface; WORKWAY.md folds testing+env+frameworks; multi-stack; GSD legacy migration; uncapped Resume note)
- v3.1 (renamed `/td-ship`→conversational; `/td-close` split into `/td-clear` (mid-project handoff) and `/td-close` (project/phase wrap))
- v3.2 (sharpened "Who does what"; added first-message warm-up nudge; added Drift signals section; SKILL.md slimmed to thin pointer; install.sh prunes stale command symlinks)
- v3.3 (added Fold-and-delete rule for `work/<topic>.md` scratch; added "Digging into history" section with git log recipe)

## Out of scope (for now)

- Research / context7 deep integration in the rhythm — useful, deferred. Currently context7 is a tool I can use ad-hoc; not built into the cycle.
- Subagents for parallel pieces — useful, deferred. Will revisit when a real project has 4+ truly independent pieces.
- npm package / CLI / Electron studio (the gsd-2 mistake). Never.
- Automated test suite for the framework itself — backlog (see BACKLOG.md).
