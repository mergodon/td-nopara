# Architecture

td-flow's own architecture — the framework eats its own dog food, so this file exists to capture the load-bearing whys behind the framework itself.

## System shape

Three layers, no compiled code:

1. **Source of truth** — this git repo at `~/projects/td-flow/`. Public on GitHub (`mergodon/td-flow`).
2. **Distribution** — `install.sh` symlinks `commands/*.md` → `~/.claude/commands/`, `skill/` → `~/.claude/skills/td-flow`, `templates/` → `~/.claude/td-templates`. Idempotent, runs on every pull.
3. **Per-project artifacts** — each consuming project carries root `CLAUDE.md` (copy of canonical) + `.td/` directory with the six canonical docs. Nothing in `.td/` is generated; it's all human-curated markdown.

`hooks/pre-commit` is symlinked into each consuming project's `.git/hooks/` to enforce pre-ship checks. AWK extracts the Test command from WORKWAY.md.

## Key components

- **`CLAUDE.md`** (root) — the contract. Same content as `templates/CLAUDE.md`; both must update in lockstep.
- **`commands/`** — seven slash command markdown files (`td-init`, `td-clear`, `td-close`, `td-refresh`, `td-mailbox`, `td-incident`, `td-park`). Each is the procedure Claude follows when invoked.
- **`skill/SKILL.md`** — a thin pointer that signals to Claude Code "this directory has td-flow; load context on demand."
- **`templates/td/`** — starting shape for `/td-init` to copy: PROJECT, WORKWAY, ARCHITECTURE, STATE, BACKLOG, DEBUG.
- **`hooks/pre-commit`** — symlinked into consuming projects, runs the Test command from WORKWAY.md before any `feat:`/`fix:` commit lands.
- **`install.sh`** — idempotent symlink installer. Prunes stale symlinks (catches retired commands).

## Important decisions

### Markdown over code

No engine to maintain, no version skew across machines, no breaking changes to manage. The whole framework is text that Claude reads. Adding a feature usually means editing a slash command's procedure, not shipping new code. Cost: no automated testing of behavior beyond "does the bash + AWK still parse?" — but the framework is self-validating because this repo IS a td-flow project; if the commands break, they break on me first.

### GitHub Issues as memory, no custom DB

The `**From:** <project>` body marker on every cross-repo filing + per-project `.td/PROJECT.md § Cross-repo` registry replaces any tracker repo, inbox service, or external DB. Two retired alternatives validated this:

- **td-bus** (shipped + retired in one day, v3.6 → v3.7) — Turso/libsql database with a Python CLI. Reinventing GH Issues for a solo dev violated CLAUDE.md's "GitHub is the memory" principle.
- **`$TD_REGISTRY` private companion registry repo** (v3.8 → v4.1) — separate repo for user-specific metadata, friendly-name lookups, etc. Retired entirely when friendly-name resolution collapsed to "PROJECT.md H1 → directory basename." No registry repo needed at all.

The current model: every cross-repo filing carries a `**From:** <project>` marker; outbound queries bound by the `.td/PROJECT.md § Cross-repo` list filter on that marker. Two pieces, both human-curated, both small.

### Public framework, private filings

The framework repo (`mergodon/td-flow`) is public so it can be forked. User-specific data lives in each project's own (potentially private) repo, not in the framework. The framework defines *conventions*; consuming projects supply the *content*.

### Minimum-dependency for cross-repo

No tracker Epic, no sub-issue linkage required for one-off cross-repo CRs. The body marker + per-project registry is the entire mechanism. Sub-issue linkage stays for *real* planning Epics with cross-repo children — that's a legit GitHub-native use case (progress bar, native UI), separate from the outbound tracking problem.

### Six canonical docs (not five)

ARCHITECTURE.md was added 2026-05-20 as the sixth standard doc (this file). Reason: code is the structure, but rationale (the *why* of decisions, the load-bearing parts, the surprises) dies first when context-switches stretch. A new idea can hurt an existing decision if the rationale isn't documented. The doc is rationale-focused, not structural — diagrams stay out.

### `templates/CLAUDE.md` and root `CLAUDE.md` kept conceptually distinct (no symlink)

They contain identical content but represent different roles: **root `CLAUDE.md` governs *this* framework project** (rules that apply while working on td-flow itself); **`templates/CLAUDE.md` is what `/td-init` copies into NEW projects** (the contract for consuming projects). A symlink would fuse them at the structural level forever — losing the option to have framework-self-referential rules in root that don't belong in the template. Cost of the current arrangement: must edit both files in lockstep when adding/changing rules. Mitigated by the doc-hygiene pass at `/td-close` catching drift. **Don't propose symlinking these again** — the conceptual distinction is load-bearing even when content matches.

### Framework self-update: detect at close, act at refresh

`/td-close` Step 11 only *detects* whether the installed framework is behind (`fetch` + `rev-list`, read-only) and nudges — it never pulls or installs. `/td-refresh` Phase 0 is where the framework actually updates: `install.sh` re-runs unconditionally (idempotent), `git pull` runs only on confirmation and only as a fast-forward.

The split is deliberate. A close must never be blocked or noised up by an unrelated framework update, and pulling another repo mid-close touches its lifecycle. `install.sh` is safe to automate because it's idempotent; `git pull` is not (dirty trees, conflicts, non-ff) so it stays confirm-first. **Don't collapse this** — making `/td-close` auto-update, or `/td-refresh` auto-pull without confirmation, reintroduces exactly the failure modes the split avoids.

## What's load-bearing

- **Friendly-name resolution: PROJECT.md H1 → directory basename.** Every cross-repo flow (filing, comments, signatures) depends on this. Changing the H1 changes the project's identity. If a project renames, every existing `**From:** <old-name>` filing becomes invisible to `/td-mailbox` outbound. Doc the rename in PROJECT.md and re-file if needed.
- **`.td/PROJECT.md § Cross-repo`** — bounds `/td-mailbox` outbound search. Missing entries cause real visibility gaps (filings won't surface in outbound). `/td-refresh` Phase 3 catches drift mechanically.
- **`**From:** <project>` body marker** — sole identifier of "this is ours" for outbound queries. Every cross-repo filing must carry it. CLAUDE.md § Cross-repo enforces.
- **`templates/CLAUDE.md` ↔ root `CLAUDE.md` lockstep** — they're separate files with identical content. The template is what `/td-init` copies into new projects; the root is canonical. Any edit to one must mirror to the other or `/td-refresh` Phase 1 will surface drift across the portfolio.
- **`install.sh` idempotency** — every machine pulls + re-runs `install.sh`. Non-idempotent install would break multi-machine sync.

## Surprises

### This repo IS a td-flow project

The framework eats its own dog food. So `/td-clear`, `/td-close`, `/td-mailbox`, etc. all work *here*. New conventions get tested on the framework's own development before they hit any other project. If a command doesn't work on td-flow, it doesn't work anywhere.

### Slash commands and skills are the same files

Claude Code loads slash commands from `~/.claude/commands/` and skills from `~/.claude/skills/`. For td-flow, the slash command markdown files are *also* the skill documentation — they're shared via the `commands/` directory and the skill loader. The `skill/SKILL.md` file is just a thin pointer.

### "Don't run `/init`" is a real footgun

Claude Code's built-in `/init` generates a codebase-snapshot CLAUDE.md and overwrites the contract. CLAUDE.md § Framework guidelines warns explicitly. `/td-init` is the td-flow equivalent and is the only one to use here.

### v4.1 collapsed 8 commands to 7

`/td-inbox` + `/td-outbox` → `/td-mailbox` (unified walk in both directions). The earlier separation was symmetric-looking but cost more than it saved: two commands, two summary states, two contexts to remember. Single command, single summary, one walk.

## When to update this doc

- After a significant architectural shift (new doc joins the canonical six, new layer in the distribution model, retirement of a major subsystem).
- At `/td-close` — the doc hygiene pass prompts review.
- After `/td-incident` if a fire surfaces something load-bearing not yet documented.
- When a "new idea" risks breaking an existing decision — add the existing decision to § Important decisions before the new idea ships.

Don't update for routine changes — `git log` covers the diff history. This doc is for *decisions that shape what's allowed to change*.
