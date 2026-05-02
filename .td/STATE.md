# State

Project:  td-flow
Topic:    idle
Phase:    idle
Blocker:  none
Last:     2026-05-03 — v3 shipped, repo eats its own dog food (`.td/` set up for the framework itself)

## Resume note

td-flow is a minimal solo-developer framework hosted at `mergodon/td-nopara`. It went through three iterations in two days (v1 → v2 → v3). The current shape is stable and worth using before more changes.

**The contract** — `CLAUDE.md` at root (universal across projects). The conversation is the interface. Three slash commands: `/td-init`, `/td-ship`, `/td-close`. Everything else is conversational.

**The five docs** — `.td/PROJECT.md`, `.td/WORKWAY.md`, `.td/STATE.md`, `.td/BACKLOG.md`, `.td/work/<topic>.md`. WORKWAY.md is the workhorse — locked sections (Local testing, Local UAT, Live, Framework specifics, Notes) so any natural-language statement has an unambiguous home.

**Key decisions made this session:**

1. **CLAUDE.md stays at root.** Don't move, don't proxy, don't loader-pattern. Frameworks like Laravel Boost may overwrite it; that's an edge case fixed by hand, not engineered around.
2. **Three slash commands only.** `/td-init` (bootstrap or migrate), `/td-ship` (local checks → commit → push), `/td-close` (cleanup docs + update STATE + push, before `/clear`).
3. **No rigid rhythm.** The shape is plan → work → test → ship → close, but depth is picked from context. Sometimes one edit and one line; sometimes a multi-step plan with a backlog. Constants: read STATE on every fresh context, capture state in STATE, follow WORKWAY for testing.
4. **WORKWAY.md folded TESTING + ENV + frameworks/.** One file, locked sections. Multi-stack supported via H3 subsections (`### Python`, `### C++`).
5. **Resume note uncapped.** Multi-step plans live there. During execution it's skim-only; for fresh-context orientation it's read in full.
6. **Migration paths in `/td-init`:** detects existing td-flow v1/v2, GSD-1 (`.planning/`, HTML markers), and rgb-buddy-2 conventions (`.claude/agreements/`, `ARCHITECTURE.md`, `BLOCKS.md`); maps to v3 without re-asking.
7. **Save-as-template path** (conversational, not a slash command): user says "save this as a `<name>` template" → I anonymize `.td/*` into `~/projects/td/templates/<name>/`. `/td-init --template <name>` starts from there. Not yet exercised on a real template.
8. **No GSD.** `.planning/`, the BIG/SMALL split, the 6-phase model, and the GSD attribution in principles all dropped. The framework is its own thing.

**rgb-* projects not yet migrated:**
- `rgb-buddy-2` (TypeScript/Tampermonkey) — already has rgb-buddy-2-style convention; `/td-init` should map cleanly. Best first migration test.
- `rgb-hh-processor` (C++/PHP) — multi-stack; tests `WORKWAY.md` Framework specifics with H3 subsections.
- `rgb-pipelines` / `rgb-handprocessing` (Python + GSD legacy) — best test of the GSD `.planning/` migration path.
- `rgb-vps` (Ansible) — no real CLAUDE.md; tests greenfield-ish init on infra repos.

**The first thing the next session should do:** validate the framework on a real project. Pick `rgb-buddy-2` (lowest risk, the convention is closest to v3) — `cd ~/projects/rgb-buddy-2 && claude` → `/td-init`. Watch for friction in: brownfield detection, agreement migration, framework-specifics population. File anything quirky as `.td/BACKLOG.md` items in *this* repo via natural language ("feedback on td-flow: …").

**What's deliberately deferred** (see BACKLOG.md): smoke test script for the framework itself, research/context7 in-rhythm integration, subagent path, ARCHITECTURE.md decision, template extraction.

**What I shouldn't do at start of next session:** redesign the framework. v3 is stable; the right next step is using it, not iterating. If something feels wrong on a real project, capture as a backlog item and keep using.
