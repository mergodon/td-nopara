---
description: Bootstrap td-flow in the current directory. Brownfield-aware. Detects stack and pre-fills WORKWAY.md framework awareness. Optional --template <name> to start from a saved starter.
---

You are initializing td-flow. After this runs, the user just talks. The other slash commands are `/td-clear` (mid-project context reset) and `/td-close` (project/phase wrap). Shipping pieces is conversational — no slash command.

The argument may be `--template <name>` to start from a saved template at `~/projects/td-flow/templates/<name>/` instead of the default `~/.claude/td-templates/`. If `<name>` doesn't exist, abort and list available templates.

# Step 0 — Detect existing td-flow or td-flow-like conventions

If any of these are present, we're migrating, not bootstrapping. Don't re-ask the user for things existing files already answer.

**td-flow v2 detected** — `.td/TESTING.md` and/or `.td/ENV.md` exist:
- Read `.td/TESTING.md` and `.td/ENV.md`. Map their values into the v3 `WORKWAY.md` template:
  - `## Local testing` block in TESTING → `## Local testing` in WORKWAY (Test command, Dev server, Local URL, Pre-ship checklist)
  - `## Live testing` block in TESTING → `## Production / Ship` in WORKWAY (Live URL, Deploy, Smoke command, Logs) and `## Local UAT` if any manual checks were captured
  - `.td/ENV.md` content → spread across `## Production / Ship` and `## Notes` as appropriate
  - `.td/frameworks/*.md` content → `## Framework specifics` (one subsection per framework)
- Rename `.td/INBOX.md` → `.td/BACKLOG.md` (preserve content, drop `[bug]`/`[idea]` tags).
- If `.td/flow/<NN>-<name>.md` files exist (v1 piece files): consolidate into `.td/work/<topic>.md` if a flow is in progress; otherwise delete.
- Tell the user what got migrated where.
- Skip Step 2 (ask for gaps); jump to Step 6 (commit).

**GSD-1 / GSD legacy detected** — `.planning/` exists, OR root `CLAUDE.md` contains HTML markers like `<!-- GSD:project-start -->` or `<!-- GSD:stack-start -->`:
- Read `.planning/` content (PROJECT.md, STATE.md, roadmap.md, etc. — GSD's old structure). Map values into the v3 docs:
  - `.planning/PROJECT.md` "What this is" + "Core Value" + "Requirements" → `.td/PROJECT.md`.
  - `.planning/STATE.md` content → `.td/STATE.md` § Resume note (prose).
  - Test commands found in CLAUDE.md fenced blocks → `.td/WORKWAY.md` § Local testing.
  - Stack info from CLAUDE.md GSD markers → `.td/PROJECT.md` Stack section.
  - `.planning/research/*` (e.g. STACK.md tables) → `.td/WORKWAY.md` § Framework specifics.
- Strip GSD HTML markers from CLAUDE.md before overwriting with the canonical contract.
- After migration, ask: "Delete `.planning/`? (its content is now in `.td/`)." If yes, `git rm -r .planning/`.
- Tell the user what got migrated.

**Brownfield ad-hoc convention detected** — any of `.claude/agreements/`, `ARCHITECTURE.md`, `BLOCKS.md` exist (and not GSD):
- Read `.claude/agreements/*.md`. Most agreements are universal td-flow rails (cadence, push-after-commit, run-commands) — they're already in CLAUDE.md and don't need preservation. Project-specific ones (branding, uat-style) → append as items in `WORKWAY.md` § Notes.
- Read `ARCHITECTURE.md`. Keep it at root as-is (it's a stable doc the user already maintains); link to it from `.td/PROJECT.md`.
- Read `BLOCKS.md`. If active blocks remain (unchecked status), keep `BLOCKS.md` at root as the multi-block roadmap and reference it from `.td/PROJECT.md` "Active scope". If all blocks are complete, archive it (rename to `BLOCKS-archive.md` or leave as-is — ask the user).
- Read existing root `CLAUDE.md`. Extract: project description (`## What this is` / similar) → `.td/PROJECT.md`; stack section → `.td/PROJECT.md`; common commands → `WORKWAY.md` § Local testing or § Production / Ship as appropriate; everything else → `.td/PROJECT.md` (it's content, not contract).
- Overwrite root `CLAUDE.md` with the canonical td-flow contract.
- Read existing `.gitignore`, `package.json` etc. for stack signals (still run Step 1 detection for things not in existing docs).
- Tell the user what got migrated where, then jump to Step 4 (framework specifics — fill any gaps not covered by existing docs).

**Already td-flow v3** — `.td/PROJECT.md` AND `.td/WORKWAY.md` exist:
- Abort: "Project already initialized as td-flow v3. Remove `.td/` to re-init."

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
5. **Existing docs.** `README.md`, root `CLAUDE.md`, `AGENTS.md`, `ARCHITECTURE.md`, `BLOCKS.md`, `.cursor/`, `.windsurfrules`.
6. **Existing td-flow state.** Already handled in Step 0.
7. **Existing root `CLAUDE.md`** (only relevant if Step 0 didn't already migrate it): if present and not the td-flow contract, save the current content under a heading `## Preserved (pre-td-flow)` inside `.td/WORKWAY.md` § Framework specifics, then overwrite root `CLAUDE.md` with the canonical contract. Tell the user where the preserved content went.

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

**For WORKWAY.md § Production / Ship:**
- Live URL (or "none" if not deployed)?
- Deploy method (e.g. "auto on push", `npm run deploy`, "manual")?

# Step 3 — Write the docs

Copy templates from `~/.claude/td-templates/` (or `~/projects/td-flow/templates/<name>/` if `--template <name>` was passed):

- `CLAUDE.md` → root, exactly as the template
- `.td/PROJECT.md` → fill placeholders
- `.td/WORKWAY.md` → fill placeholders for Local testing, Local UAT, Production / Ship
- `.td/STATE.md` → fill placeholders, set `Last:` to today
- `.td/BACKLOG.md` → as-is
- `.td/frameworks/.gitkeep` → empty (the dir is for rare overflow; default home for framework awareness is `WORKWAY.md` § Framework specifics)
- **No `## Cross-repo` scaffold in `PROJECT.md`.** The section is opt-in per project — the user adds it only when there's a real cross-repo relationship to declare. New projects start without it. The convention is documented in root `CLAUDE.md § Cross-repo`.
- `.gitignore` → merge with existing
- `.env.example` → only if no `.env.example` exists

# Step 4 — Pre-fill framework specifics

For each framework detected in Step 1, append a section under `.td/WORKWAY.md` § Framework specifics. Examples:

- **Laravel + Boost** detected:
  ```
  ### Laravel + Boost
  - MCP server registered via `.mcp.json` (gitignored, regenerated by `boost:install`).
  - Boost Docs API: 17k Laravel docs, semantic search.
  - Boost regenerates `CLAUDE.md` / `AGENTS.md` / `junie/` / `boost.json` on each `boost:install` — they're gitignored.
  - If Boost overwrites root `CLAUDE.md`: restore from `~/.claude/td-templates/CLAUDE.md` and tell the user.
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

If `.git/` exists, copy `~/projects/td-flow/hooks/pre-commit` to `.git/hooks/pre-commit` and `chmod +x`. The hook reads `Test command` from `.td/WORKWAY.md` § Local testing.

If `.git/` doesn't exist, ask: "Init a git repo now?" If yes, `git init`, then install the hook.

# Step 6 — First commit

```
git add CLAUDE.md .td/ .gitignore .env.example
git commit -m "chore: td-flow init"
```

If a remote is configured, ask: "Push to `origin/main` now?" If yes, push.

# Step 7 — Tell the user what they got

Short summary:

- Files created
- Frameworks detected and pre-noted in WORKWAY.md
- Pre-commit hook installed
- Git: init/exists/pushed
- How to use from here: just talk. Say what you want to build, fix, or change. I'll start the rhythm.

# Save-as-template path

This command also handles the inverse: when the user says "save this as a `<name>` template" (no slash command needed), I:

1. Verify `.td/PROJECT.md` exists.
2. Copy `.td/*` to `~/projects/td-flow/templates/<name>/td/` (anonymized — strip user-specific values: project_name, live_url, db credentials, etc., back to placeholders).
3. Copy current root `CLAUDE.md` to `~/projects/td-flow/templates/<name>/CLAUDE.md` only if it differs from the canonical (it shouldn't, but check).
4. Commit the framework repo: `chore: save <name> template`.
5. Tell the user: "Saved as `<name>`. Future `/td-init --template <name>` will start from this shape."

# Rules

- Never overwrite existing `CLAUDE.md` without preserving its content into `.td/WORKWAY.md` § Framework specifics first.
- Never overwrite `.gitignore`. Merge.
- Never overwrite `.env.example` if one exists.
- Abort if `.td/PROJECT.md` already exists.
- Use the user's actual answers — do not invent values.
- After init, do not start the rhythm. Wait for the user's first action-shaped statement.
