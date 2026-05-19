# td-flow

## What this is

The **td-flow** framework itself: a minimal, file-based, repo-portable working agreement for solo development. Same shape every project, conversational interface, structured docs in `.td/`, GitHub commits as memory. Three slash commands (`/td-init`, `/td-clear`, `/td-close`) — everything else is conversational.

## Who it's for

Solo developers working with Claude Code. Originally built for one user's portfolio; anyone can fork it and pair it with their own private registry (see § Stack & choices / `$TD_REGISTRY` pattern).

## Stack & choices

- Markdown-only — no compiled code, no npm package, no CLI binary.
- Bash for `install.sh` and the pre-commit hook.
- AWK for extracting the test command from `WORKWAY.md` § Local testing.
- Cross-project requests ride on GitHub Issues + `gh` CLI. No custom DB, no schema, no inbox service.
- **Public methodology + private registry split.** This repo (`mergodon/td-flow`) is public — it holds the methodology, slash commands, templates, install scripts. Anything user/portfolio-specific (friendly-name → GH-slug registry, outbound-issue logs) lives in a separate **private** companion repo discovered via the `$TD_REGISTRY` env var. Forkers create their own private registry repo by the same pattern.
- Cloned to `~/projects/td-flow/` on each machine.
- Distributed as symlinks into `~/.claude/commands/`, `~/.claude/skills/td-flow`, and `~/.claude/td-templates` via `install.sh`.

## Active scope

(none — v4.0 shipped; awaiting first real-project `/td-init` + first real outside-fork to surface what the published methodology actually needs)

## Cross-repo

- `mergodon/td-registry` — private companion registry; we file naming-convention updates, SERVICES.md schema requests, NAMING.md edits.

## Shipped

- v1 (initial scaffold, 10 slash commands, BIG/SMALL split)
- v2 (collapsed to 7 commands, 6-phase cycle, locked TESTING.md sections)
- v3 (3 slash commands: init/ship/close; conversational interface; WORKWAY.md folds testing+env+frameworks; multi-stack; GSD legacy migration; uncapped Resume note)
- v3.1 (renamed `/td-ship`→conversational; `/td-close` split into `/td-clear` (mid-project handoff) and `/td-close` (project/phase wrap))
- v3.2 (sharpened "Who does what"; added first-message warm-up nudge; added Drift signals section; SKILL.md slimmed to thin pointer; install.sh prunes stale command symlinks)
- v3.3 (added Fold-and-delete rule for `work/<topic>.md` scratch; added "Digging into history" section with git log recipe)
- v3.4 (made the four bypassed rituals explicit: "lets do it" as meaningful-work trigger, "Before I commit a piece" pre-ship + STATE-update + fold-and-delete bundle, and `/init` never-run warning)
- v3.5 (BACKLOG/PROJECT cleanup: dropped auto-test-suite item; first real-project validation set as next-session move; explicit self-validation rationale via drift signals + Before-I-commit bundle)
- v3.6 (td-bus shipped: opt-in cross-project messaging on a shared Turso/libsql DB. Single-file Python CLI, schema, `/td-bus-init` slash command, installer wired `~/bin/td-bus`. **Retired same day in v3.7** after reviewing GitHub Projects v2 / Issues — reinventing GH Issues for a solo dev violated CLAUDE.md's own "GitHub is the memory. Don't duplicate." principle.)
- v3.7 (td-bus retired in favor of GitHub Issues + per-project `## Cross-repo` registry in `.td/PROJECT.md`. Deleted bus CLI, schema, slash command, and `install.sh` blocks. Added cross-repo workflow + warm-up `gh issue list` to root + template `CLAUDE.md`. `## Cross-repo` is opt-in per project — no scaffold. Inbox-scope guardrail: current repo by default, cross-repo opt-in via explicit triggers. Identity-agnostic queries — REPO is the unit, not GH user.)
- v3.8 (public/private split: SERVICES.md (and future user-specific data) moved out of this repo into a private companion registry repo discovered via `$TD_REGISTRY`. The framework repo flipped back to public so the methodology can be shared/forked; user data stays private. Pattern: public framework + per-user private registry.)
- v4.0 (public-identity milestone: GH repo renamed `mergodon/td-nopara` → `mergodon/td-flow`; local clone path renamed `~/projects/td/` → `~/projects/td-flow/`. Friendly name, project name, GH slug, and local path now all line up. Doc refs reconciled across `td-flow` + `td-registry`; downstream-project reconcile guidance updated in README. No surface change to commands, skill, or contract.)

## Out of scope (for now)

- Research / context7 deep integration in the rhythm — useful, deferred. Currently context7 is a tool I can use ad-hoc; not built into the cycle.
- Subagents for parallel pieces — useful, deferred. Will revisit when a real project has 4+ truly independent pieces.
- npm package / CLI / Electron studio (the gsd-2 mistake). Never.
- Automated test suite for the framework itself — explicitly dropped 2026-05-05. We validate project-by-project as we use td-flow on real projects. Drift signals + "Before I commit a piece" ritual are the self-validation.
