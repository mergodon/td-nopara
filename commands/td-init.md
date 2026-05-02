---
description: Bootstrap td-flow in the current directory. Brownfield-aware — maps existing files, asks for gaps.
---

You are initializing the td-flow framework in the current directory. This is the entry point for every new project.

# Step 1 — Map what's here

Look at the current directory and detect:

1. **Git state.** Is `.git` present? What's the remote? What's the default branch?
2. **Stack signals.** Check for: `package.json`, `Cargo.toml`, `pyproject.toml`, `composer.json`, `Gemfile`, `go.mod`, `next.config.*`, `vite.config.*`, `astro.config.*`, `wrangler.toml`, `Dockerfile`, framework-specific configs.
3. **Existing docs.** `README.md`, `CLAUDE.md`, `AGENTS.md`, `.cursor/`, `.windsurfrules`, etc.
4. **Test commands.** Read `scripts` from `package.json` / equivalent. Note `test`, `dev`, `build`, `deploy`.
5. **Existing td-flow state.** `.td/` directory? `CLAUDE.md` already td-flow style? **If `.td/PROJECT.md` exists, abort: this project is already initialized — tell the user to remove `.td/` first if they want to re-init.**
6. **Existing CLAUDE.md.** If present and not the td-flow template: **do not overwrite.** Save it to `.td/frameworks/preserved-claude.md` and tell the user — they'll review during cleanup.

Print a brief map of findings to the user (5–10 lines).

# Step 2 — Ask for the gaps

Ask the user the following in one message, as bullets they can answer inline. Skip any you confidently inferred from Step 1.

- What is this project, in 1–2 sentences?
- Who is it for, in one sentence?
- What's the live URL (or "not deployed yet")?
- What's the deploy command or method (e.g., "`git push` auto-deploys", "`npm run deploy`", "manual")?
- What's the test command (e.g., `npm test`, `cargo test`, "no tests yet")?
- What's the dev server command and local URL (e.g., `npm run dev`, `http://localhost:3000`)?
- What's the first thing in active scope (one bullet)?

# Step 3 — Write the files

Copy the templates from the framework repo at `~/.claude/td-templates/` (or `/Users/mergodon/projects/td/templates/` if symlink missing) into the current directory, filling placeholders:

- `CLAUDE.md` → root (do not modify the template)
- `.td/PROJECT.md` → fill placeholders
- `.td/TESTING.md` → fill placeholders
- `.td/ENV.md` → fill placeholders
- `.td/STATE.md` → fill placeholders, set `Last action` to today's date
- `.td/INBOX.md` → copy as-is (empty inbox)
- `.td/frameworks/.gitkeep` → empty file
- `.gitignore` → merge with existing (do not clobber)
- `.env.example` → only if no `.env.example` exists; otherwise leave alone

# Step 4 — Install pre-commit hook

If `.git/` exists, install the pre-commit hook from `~/.claude/td-templates/hooks/pre-commit` to `.git/hooks/pre-commit` and `chmod +x` it. The hook reads the **Test command** from `.td/TESTING.md` and runs it; non-zero exit blocks the commit.

If `.git/` doesn't exist, ask: "Init a git repo now?" If yes, `git init`, then install the hook.

# Step 5 — First commit

Stage and commit:

```
git add CLAUDE.md .td/ .gitignore .env.example
git commit -m "chore: td-flow init"
```

If a `.td/INBOX.md` template was created, it's part of `.td/` and gets included in this commit.

If the user already had a remote configured, ask: "Push to `origin/main` now?" If yes, push.

# Step 6 — Tell the user what they got

Print a short summary:

- Files created / updated
- Pre-commit hook installed (or not, with reason)
- Git: initialized / already present / pushed
- Next steps: `/td-feature <name>` for a feature, `/td-fix <description>` for a fix, `/td-status` to check state
- Reminder: if a framework writes to `CLAUDE.md`, run `/td-cleanup`

# Rules

- **Never overwrite an existing `CLAUDE.md`** without preserving it to `.td/frameworks/preserved-claude.md` first.
- **Never overwrite an existing `.gitignore`** — merge.
- **Never overwrite `.env.example`** if one exists.
- **Abort if `.td/PROJECT.md` already exists.** Tell the user to remove `.td/` to re-init.
- Use the user's actual answers — do not invent values to fill placeholders.
