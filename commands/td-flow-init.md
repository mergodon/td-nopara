---
description: Bootstrap td-flow in the current directory. Brownfield-aware. Detects stack and pre-fills WORKWAY.md framework awareness.
---

You are initializing td-flow. After this runs, the user just talks. The other slash commands are `/td-flow-clear` (mid-project context reset) and `/td-flow-close` (project/phase wrap). Shipping pieces is conversational — no slash command.

# Step 0 — Detect existing td-flow or td-flow-like conventions

If any of these are present, we're migrating, not bootstrapping. Don't re-ask the user for things existing files already answer.

**td-flow v2 detected** — `.td/TESTING.md` and/or `.td/ENV.md` exist (legacy `.td/` dir name, pre-v7.0):
- Read `.td/TESTING.md` and `.td/ENV.md`. Map their values into the current `WORKWAY.md` template:
  - `## Local testing` block in TESTING → `## Local testing` in WORKWAY (Test command, Dev server, Local URL, Pre-ship checklist)
  - `## Live testing` block in TESTING → `## Live` in WORKWAY (Live URL, Deploy, Smoke command, Logs) and `## Local UAT` if any manual checks were captured
  - `.td/ENV.md` content → spread across `## Live` and `## Notes` as appropriate
  - `.td/frameworks/*.md` content → `## Framework specifics` (one subsection per framework)
- Rename `.td/INBOX.md` → `.td-flow/BACKLOG.md` (preserve content, drop `[bug]`/`[idea]` tags) — the migration also renames the dir from `.td/` to `.td-flow/` and creates a `.td → .td-flow` compat symlink (the v7.0 rename; see `/td-flow-refresh`'s migration phase).
- If `.td/flow/<NN>-<name>.md` files exist (v1 piece files): consolidate into `.td-flow/work/<topic>.md` if a flow is in progress; otherwise delete.
- Tell the user what got migrated where (including the dir rename + compat symlink).
- Skip Step 2 (ask for gaps); jump to Step 6 (commit).

**Brownfield ad-hoc convention detected** — any of `.claude/agreements/`, `BLOCKS.md` exist:
- Read `.claude/agreements/*.md`. Most agreements are universal td-flow rails (cadence, push-after-commit, run-commands) — they're already in CLAUDE.md and don't need preservation. Project-specific ones (branding, uat-style) → append as items in `WORKWAY.md` § Notes.
- Read `BLOCKS.md`. If active blocks remain (unchecked status), keep `BLOCKS.md` at root as the multi-block roadmap and reference it from `.td-flow/PROJECT.md` "Active scope". If all blocks are complete, rename it to `BLOCKS-archive.md` (non-destructive, still in tree) and mention what you did in the Step 7 summary.
- Read existing root `CLAUDE.md`. Extract: project description (`## What this is` / similar) → `.td-flow/PROJECT.md`; stack section → `.td-flow/PROJECT.md`; common commands → `WORKWAY.md` § Local testing or § Live as appropriate; everything else → `.td-flow/PROJECT.md` (it's content, not contract).
- Write root `CLAUDE.md` as the one-line `@import` template (copy `templates/CLAUDE.md`) — the contract is imported, not copied.
- Read existing `.gitignore`, `package.json` etc. for stack signals (still run Step 1 detection for things not in existing docs).
- Tell the user what got migrated where, then jump to Step 4 (framework specifics — fill any gaps not covered by existing docs).

**Already a td-flow project** — `.td-flow/PROJECT.md` AND `.td-flow/WORKWAY.md` exist:
- Abort: "Project already initialized as td-flow. Remove `.td-flow/` to re-init."

If none of the above match: proceed with normal Step 1.

# Step 1 — Map what's already here

Detect:

1. **Git state.** `.git` present? Remote? Default branch?
2. **Stack signals.** Check `package.json`, `Cargo.toml`, `pyproject.toml`, `composer.json`, `Gemfile`, `go.mod`, `next.config.*`, `vite.config.*`, `astro.config.*`, `wrangler.toml`, `Dockerfile`, `manifest.json` (Tampermonkey/extension), `artisan` script.
3. **Frameworks specifically:**
   - `composer.json` has `laravel/laravel` → Laravel
   - `composer.json` has `laravel/boost` → Laravel Boost (note: it auto-regenerates CLAUDE.md/AGENTS.md/junie/.mcp.json/boost.json — gitignore those)
   - `next.config.*` → Next.js
   - `vite.config.*` with `vite-plugin-monkey` → Tampermonkey userscript
   - `wrangler.toml` → Cloudflare Workers/Pages
   - `tailwind.config.*` → Tailwind
   - `components/ui/` directory → shadcn
4. **Test commands.** Read scripts from `package.json` or equivalent. Note `test`, `dev`, `build`, `deploy`.
5. **Existing docs.** `README.md`, root `CLAUDE.md`, `AGENTS.md`, `BLOCKS.md`, `.cursor/`, `.windsurfrules`.
6. **Existing td-flow state.** Already handled in Step 0.
7. **Existing root `CLAUDE.md`** (only relevant if Step 0 didn't already migrate it): if present and not already a td-flow `@import`, save the current content under a heading `## Preserved (pre-td-flow)` inside `.td-flow/WORKWAY.md` § Framework specifics, then write root `CLAUDE.md` as the one-line `@import` template. Tell the user where the preserved content went.

Print a 5–10 line map of findings.

# Step 2 — Ask for the gaps (small set)

Group by destination so the user knows where each answer lands. Skip any answered confidently from Step 1.

**For PROJECT.md:**
- What is this project, in 1–2 sentences?
- Who is it for?
- First thing in active scope (one bullet)?

**For WORKWAY.md § Local testing:**
- Test command (e.g. `npm test`, `cargo test`, "none")?
- Dev server command + local URL?

**For WORKWAY.md § Local UAT:**
- Can I exercise the UI / endpoints myself, or does the user run it manually? (e.g. Tampermonkey userscripts → user; Laravel API → I can curl).
- One sentence on what UAT looks like.

**For WORKWAY.md § Live:**
- Live URL (or "none" if not deployed)?
- Deploy method (e.g. "auto on push", `npm run deploy`, "manual")?

# Step 3 — Write the docs

Source templates from `~/.claude/td-templates/`. State-dir scaffolds live at `~/.claude/td-templates/td-flow/`:

- `CLAUDE.md` → root: copy `~/.claude/td-templates/CLAUDE.md` (a one-line `@import` of the canonical contract). It imports `~/.claude/td-flow-contract.md` — confirm that exists; if it doesn't, td-flow isn't fully installed, so tell the user to run `~/projects/td-flow/install.sh`, then continue.
- `mkdir -p .td-flow/work .td-flow/frameworks` — create the state dir + subdirs
- `.td-flow/PROJECT.md` → copy from `~/.claude/td-templates/td-flow/PROJECT.md`, fill placeholders
- `.td-flow/WORKWAY.md` → copy from `~/.claude/td-templates/td-flow/WORKWAY.md`, fill placeholders for Local testing, Local UAT, Live
- `.td-flow/STATE.md` → copy from `~/.claude/td-templates/td-flow/STATE.md`, fill placeholders, set `Last:` to today
- `.td-flow/BACKLOG.md` → copy from `~/.claude/td-templates/td-flow/BACKLOG.md` as-is
- `.td-flow/frameworks/.gitkeep` → empty (the dir is for rare overflow; default home for framework awareness is `WORKWAY.md` § Framework specifics)
- **`.td → .td-flow` compat symlink** — `ln -s .td-flow .td` (creates the v7.0 transition safety net so any user-side tooling, IDE bookmarks, scripts, or `.gitignore` entries that hardcoded `.td/` keep resolving). The symlink stays until v8.0 drops it from new scaffolds.
- **No `## Cross-repo` scaffold in `PROJECT.md`.** The section is opt-in per project — the user adds it only when there's a real cross-repo relationship to declare. New projects start without it. The convention is documented in root `CLAUDE.md § Cross-repo`.
- `.gitignore` → merge with existing
- `.env.example` → only if no `.env.example` exists

# Step 4 — Pre-fill framework specifics

For each framework detected in Step 1, append a section under `.td-flow/WORKWAY.md` § Framework specifics. Examples:

- **Laravel + Boost** detected:
  ```
  ### Laravel + Boost
  - MCP server registered via `.mcp.json` (gitignored, regenerated by `boost:install`).
  - Boost Docs API: 17k Laravel docs, semantic search.
  - Boost regenerates `CLAUDE.md` / `AGENTS.md` / `junie/` / `boost.json` on each `boost:install` — they're gitignored.
  - If Boost overwrites root `CLAUDE.md`: restore the one-line `@import` (from `~/.claude/td-templates/CLAUDE.md`) and tell the user.
  ```
  Also append to `.gitignore`:
  ```
  # Laravel Boost auto-regenerated artifacts (per Laravel docs)
  AGENTS.md
  junie/
  boost.json
  .mcp.json
  ```

- **Next.js**, **Vite**, **Tampermonkey/userscript**, **Cloudflare Workers**: short paragraph each on what they bring and any deploy quirks.

Do not invent specifics — only write what's true based on detected files. Use `WebFetch` or `context7` if the user later asks me to research a framework deeper.

# Step 5 — Install pre-commit hook

If `.git/` exists, copy `~/projects/td-flow/hooks/pre-commit` to `.git/hooks/pre-commit` and `chmod +x`. The hook reads `Test command` from `.td-flow/WORKWAY.md` § Local testing.

If `.git/` doesn't exist, ask: "Init a git repo now?" If yes, `git init`, then install the hook.

# Step 6 — First commit

This commit only adds the td-flow scaffolding — no project code — so it commits `--no-verify`, skipping the pre-commit hook Step 5 just installed. Without that, on a project whose deps or test setup aren't ready yet, the hook's `Test command` would block the bootstrap commit.

```
git add CLAUDE.md .td-flow/ .gitignore .env.example
git commit --no-verify -m "chore: td-flow init"
```

If a remote is configured, ask: "Push to `origin/main` now?" If yes, push.

# Step 7 — Tell the user what they got

Short summary:

- Files created (highlight: root `CLAUDE.md` is a one-line `@import` of the canonical contract — every td-flow rule loads automatically from `~/.claude/td-flow-contract.md` next session, no per-project drift)
- Frameworks detected and pre-noted in WORKWAY.md
- Pre-commit hook installed (reads `Test command` from `.td-flow/WORKWAY.md § Local testing`)
- Git: init/exists/pushed
- How to use from here: just talk. Say what you want to build, fix, or change. I'll start the rhythm. The 10 slash commands (`/td-flow-init`, `/td-flow-clear`, `/td-flow-complex-clear`, `/td-flow-close`, `/td-flow-refresh`, `/td-flow-mailbox`, `/td-flow-health`, `/td-flow-incident`, `/td-flow-park`, `/td-flow-snapshot`) are listed in the contract — everything else is conversational.

# Rules

- Never overwrite existing `CLAUDE.md` without preserving its content into `.td-flow/WORKWAY.md` § Framework specifics first.
- Never overwrite `.gitignore`. Merge.
- Never overwrite `.env.example` if one exists.
- Abort if `.td-flow/PROJECT.md` already exists.
- Use the user's actual answers — do not invent values.
- After init, do not start the rhythm. Wait for the user's first action-shaped statement.
