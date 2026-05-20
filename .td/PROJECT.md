# td-flow

## What this is

The **td-flow** framework itself: a minimal, file-based, repo-portable working agreement for solo development. Same shape every project, conversational interface, structured docs in `.td/`, GitHub commits as memory. Seven slash commands (`/td-init`, `/td-clear`, `/td-close`, `/td-refresh`, `/td-mailbox`, `/td-incident`, `/td-park`) — everything else is conversational.

## Who it's for

Solo developers working with Claude Code. Originally built for one user's portfolio; anyone can fork it for their own.

## Stack & choices

- Markdown-only — no compiled code, no npm package, no CLI binary.
- Bash for `install.sh` and the pre-commit hook.
- AWK for extracting the test command from `WORKWAY.md` § Local testing.
- Cross-project requests ride on GitHub Issues + `gh` CLI. No custom DB, no schema, no inbox service.
- **Tracker-free outbound.** Per-project `.td/PROJECT.md § Cross-repo` lists connected repos; `**From:** <project>` body marker on every cross-repo filing identifies the source. `/td-mailbox` does one bounded search across declared repos — no separate registry repo, no tracker Epic, no in-repo tracking infrastructure beyond the human-curated list and the body marker.
- Cloned to `~/projects/td-flow/` on each machine.
- Distributed as symlinks into `~/.claude/commands/`, `~/.claude/skills/td-flow`, and `~/.claude/td-templates` via `install.sh`.

## Active scope

(none — v4.2 + v4.3 shipped; awaiting first real outside-fork and a real-project hit on the newer conventions to surface anything the dogfood missed)

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
- v4.1 (`/td-mailbox` shipped + tracker model proposed-then-reverted in one day; landed on minimum-dependency design: per-project `.td/PROJECT.md § Cross-repo` list bounds the outbound search, `**From:** <project>` body marker identifies our filings, sub-issues stay for real planning Epics. Plus: mechanical stack-reality-check + doc hygiene at `/td-clear` and `/td-close`; close-as-stale recommendation for outbound; `Feature` Issue Type retired; **`$TD_REGISTRY` private companion registry concept retired entirely** — the friendly-name lookup collapsed to PROJECT.md H1 → directory basename, no separate registry repo needed. Net effect across these changes: 8 slash commands → 7, materially simpler model.)
- v4.2 (ARCHITECTURE.md added as sixth standard `.td/` doc — rationale-focused, not structural. Hooks across the lifecycle: `/td-init` scaffolds it, `/td-clear` heads-up on drift, `/td-close` hygiene-pass review, `/td-refresh` Phase 4 existence check, `/td-incident` close-out captures architectural learnings. Plus: `/td-mailbox` gained `start` (inbound) verb to activate an issue as the current Topic with auto `Closes #N` staging; `/td-clear` + `/td-close` gained mailbox awareness (snapshot + open-Bug/Task gate). Then a same-session simplification pass: dropped `/td-mailbox` outbound `status` sub-menu, consolidated `/td-clear` heads-ups into one block, collapsed `/td-incident` close-out's 3 prompts into one prefix-routed capture, fixed `/td-refresh` Step 1 short-circuit bug, halved CLAUDE.md slash-commands list, restructured CLAUDE.md § Cross-repo for sharper structure. Explicit user call: `templates/CLAUDE.md` and root `CLAUDE.md` kept conceptually distinct — no symlink, mirrored edits per session.)
- v4.3 (framework self-update: `/td-close` gained Step 11 — a read-only check after a successful close that nudges if the local td-flow repo is behind `origin/main`, never pulls. `/td-refresh` gained Phase 0 (new Step 0) — syncs the framework *before* the project refresh: re-runs `install.sh` unconditionally (idempotent — catches stale symlinks independent of repo state), offers a confirm-first `--ff-only` pull if behind. Both resolve the framework repo via the running command's symlink target — clone-path-independent. Design split: detect-at-close, act-at-refresh — see ARCHITECTURE.md § Important decisions. Triggered by a real miss this session — `/td-incident` was absent from `~/.claude/commands/` because `install.sh` hadn't been re-run after the command was added.)

## Out of scope (for now)

- Research / context7 deep integration in the rhythm — **decided against** 2026-05-20 (closed #7 as not-planned). The MCP is already wired up and ad-hoc use is already documented in CLAUDE.md. A formal "research phase" would add ceremony for every piece — anti the three-lines-beats-abstraction instinct.
- Subagents for implementation fan-out — **decided against** 2026-05-20 (closed #8 as not-planned). The Agent tool exists in the harness and research fan-out (Explore agents) is already documented; implementation fan-out can't be made fully safe (contract leaks, semantic conflicts past file-level isolation, partial-failure rollback). Coordination cost outweighs speedup for a solo dev where speed isn't the bottleneck. Revisit only with a real concrete case.
- npm package / CLI / Electron studio (the gsd-2 mistake). Never.
- Automated test suite for the framework itself — explicitly dropped 2026-05-05. We validate project-by-project as we use td-flow on real projects. Drift signals + "Before I commit a piece" ritual are the self-validation.
