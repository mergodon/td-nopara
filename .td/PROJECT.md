# td-flow

## What this is

The **td-flow** framework itself: a minimal, file-based, repo-portable working agreement for solo development. Same shape every project, conversational interface, structured docs in `.td/`, GitHub commits as memory. Three slash commands (`/td-init`, `/td-clear`, `/td-close`) — everything else is conversational.

## Who it's for

Mate (solo developer working with Claude). Used across `mergodon/rgb-*` projects and any future repos.

## Stack & choices

- Markdown-only — no compiled code, no npm package, no CLI binary.
- Bash for `install.sh` and the pre-commit hook.
- AWK for extracting the test command from `WORKWAY.md` § Local testing.
- Cross-project requests ride on GitHub Issues + `gh` CLI. No custom DB, no schema, no inbox service.
- Hosted at `mergodon/td-nopara` (private). Cloned to `~/projects/td/` on each machine.
- Distributed as symlinks into `~/.claude/commands/`, `~/.claude/skills/td-flow`, and `~/.claude/td-templates` via `install.sh`.

## Active scope

(none — v3.7 shipped; awaiting first real-project `/td-init` + first real cross-repo issue to surface what's actually missing)

## Shipped

- v1 (initial scaffold, 10 slash commands, BIG/SMALL split)
- v2 (collapsed to 7 commands, 6-phase cycle, locked TESTING.md sections)
- v3 (3 slash commands: init/ship/close; conversational interface; WORKWAY.md folds testing+env+frameworks; multi-stack; GSD legacy migration; uncapped Resume note)
- v3.1 (renamed `/td-ship`→conversational; `/td-close` split into `/td-clear` (mid-project handoff) and `/td-close` (project/phase wrap))
- v3.2 (sharpened "Who does what"; added first-message warm-up nudge; added Drift signals section; SKILL.md slimmed to thin pointer; install.sh prunes stale command symlinks)
- v3.3 (added Fold-and-delete rule for `work/<topic>.md` scratch; added "Digging into history" section with git log recipe)
- v3.4 (made the four bypassed rituals explicit: "lets do it" as meaningful-work trigger, "Before I commit a piece" pre-ship + STATE-update + fold-and-delete bundle, and `/init` never-run warning)
- v3.5 (BACKLOG/PROJECT cleanup: dropped auto-test-suite item; rgb-buddy-2 set as next-session move for UAT + first-real-project validation; explicit self-validation rationale via drift signals + Before-I-commit bundle)
- v3.6 (td-bus shipped: opt-in cross-project messaging on a shared Turso/libsql DB. Single-file Python CLI, schema, `/td-bus-init` slash command, installer wired `~/bin/td-bus`. **Retired same day in v3.7** after reviewing GitHub Projects v2 / Issues — reinventing GH Issues for a solo dev violated CLAUDE.md's own "GitHub is the memory. Don't duplicate." principle.)
- v3.7 (td-bus retired in favor of GitHub Issues + per-project `## Cross-repo` registry in `.td/PROJECT.md`. Deleted `bin/td-bus`, `bus-schema.sql`, `commands/td-bus-init.md`, bus blocks in `install.sh` + `README.md`. Added cross-repo workflow + warm-up `gh issue list` to root + template `CLAUDE.md`. `## Cross-repo` is opt-in per project — no scaffold. Live Turso DB untouched; `turso db destroy td-bus-<you>` when ready.)

## Out of scope (for now)

- Research / context7 deep integration in the rhythm — useful, deferred. Currently context7 is a tool I can use ad-hoc; not built into the cycle.
- Subagents for parallel pieces — useful, deferred. Will revisit when a real project has 4+ truly independent pieces.
- npm package / CLI / Electron studio (the gsd-2 mistake). Never.
- Automated test suite for the framework itself — explicitly dropped 2026-05-05. We validate project-by-project as we use td-flow on real `rgb-*` repos. Drift signals + "Before I commit a piece" ritual are the self-validation.
