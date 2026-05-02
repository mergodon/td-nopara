---
description: Bootstrap td-flow in the current directory. Brownfield-aware — maps existing files, asks for gaps, writes the structured docs.
---

You are initializing td-flow in the current directory. This is the only slash command in td-flow; everything else is conversational. After this runs, the user just talks and you follow the contract in `CLAUDE.md`.

# Step 1 — Map what's already here

Look around the current directory and detect:

1. **Git state.** Is `.git` present? Remote URL? Default branch?
2. **Stack signals.** `package.json`, `Cargo.toml`, `pyproject.toml`, `composer.json`, `Gemfile`, `go.mod`, `next.config.*`, `vite.config.*`, `astro.config.*`, `wrangler.toml`, `Dockerfile`. Note language and framework.
3. **Test commands.** Read `scripts` from `package.json` / equivalent. Note `test`, `dev`, `build`, `deploy`.
4. **Existing docs.** `README.md`, `CLAUDE.md`, `AGENTS.md`, `.cursor/`, `.windsurfrules`.
5. **Existing td-flow state.** If `.td/PROJECT.md` already exists, abort: "This project is already initialized. Remove `.td/` first if you want to re-init."
6. **Existing CLAUDE.md.** If present and not the td-flow contract: do not overwrite. Save it as `.td/frameworks/preserved-claude.md`. Tell the user.

Print a brief 5–10 line map of findings.

# Step 2 — Ask for the gaps

Ask in one message, as bullets the user can answer inline. Skip any answered confidently from Step 1. Group by destination doc so the user knows where each answer lands.

**For PROJECT.md:**
- What is this project, in 1–2 sentences?
- Who is it for, in one sentence?
- First thing in active scope (one bullet)?

**For TESTING.md § Local testing:**
- Test command (e.g. `npm test`, `cargo test`, "none")?
- Dev server command and local URL (e.g. `npm run dev` / `http://localhost:3000`)?
- One manual local check before shipping (e.g. "load the homepage, no console errors")?

**For TESTING.md § Live testing:**
- Live URL (or "none" if not deployed)?
- Deploy method (e.g. "auto on push to main", `npm run deploy`, "manual")?
- One smoke check after shipping (or "none")?
- Where the logs are (command or URL, or "none")?

# Step 3 — Write the docs

Copy templates from `~/.claude/td-templates/` into the current directory, filling placeholders:

- `CLAUDE.md` → root, exactly as the template (do not modify)
- `.td/PROJECT.md` → fill placeholders
- `.td/TESTING.md` → fill placeholders for both Local and Live sections
- `.td/ENV.md` → fill placeholders
- `.td/STATE.md` → fill placeholders, set `Last:` to today's date
- `.td/INBOX.md` → copy as-is
- `.td/frameworks/.gitkeep` → empty file
- `.gitignore` → merge with existing (do not clobber)
- `.env.example` → only if no `.env.example` exists

Use the user's actual answers — do not invent values.

# Step 4 — Install pre-commit hook

If `.git/` exists, copy `~/.claude/td-templates/../hooks/pre-commit` (i.e. `~/projects/td/hooks/pre-commit`) to `.git/hooks/pre-commit` and `chmod +x` it. The hook reads § Local testing → Test command from `.td/TESTING.md`.

If `.git/` doesn't exist, ask: "Init a git repo now?" If yes, `git init`, then install the hook.

# Step 5 — First commit

```
git add CLAUDE.md .td/ .gitignore .env.example
git commit -m "chore: td-flow init"
```

If a remote is configured, ask: "Push to `origin/main` now?" If yes, push.

# Step 6 — Tell the user what they got

Print a short summary:

- Files created/updated
- Pre-commit hook installed (or not, with reason)
- Git: initialized / already present / pushed
- How to use from here: just talk. Say what you want to build, fix, or change. Say "where are we" anytime. Say "let's wrap" before `/clear`.
- One reminder: if a framework writes to CLAUDE.md (Laravel Boost etc.), tell Claude — they'll move it to `.td/frameworks/`.

# Rules

- Never overwrite an existing `CLAUDE.md` without preserving it to `.td/frameworks/preserved-claude.md`.
- Never overwrite `.gitignore`. Merge.
- Never overwrite `.env.example` if one exists.
- Abort if `.td/PROJECT.md` already exists.
- Use the user's answers — do not invent values.
- After init, do not start a cycle. Wait for the user to say what they want to do.
