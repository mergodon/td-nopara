---
description: Detect framework pollution in CLAUDE.md and relocate it to .td/frameworks/. Manual only.
---

You are cleaning framework-injected content out of `CLAUDE.md`. Frameworks like Laravel Boost, Next.js codegen, etc. sometimes append guidelines to `CLAUDE.md` — those belong in `.td/frameworks/<name>.md`.

# Step 1 — Diff against the canonical template

Compare the project's `CLAUDE.md` against the canonical template at `~/.claude/td-templates/CLAUDE.md` (or `/Users/mergodon/projects/td/templates/CLAUDE.md`).

Identify any blocks present in the project file that are NOT in the canonical template. These are framework injections.

If there are no differences, tell the user: "CLAUDE.md is clean. Nothing to relocate." and stop.

# Step 2 — Identify framework names

For each detected block, infer the source framework. Look for telltale signs:

- "Laravel Boost", "artisan", "blade" → laravel-boost
- "Next.js", "App Router", `app/` → nextjs
- "Tailwind", `tailwind.config` → tailwind
- "shadcn", "components/ui" → shadcn
- Otherwise, ask the user: "What framework injected this block? (one-word name)"

# Step 3 — Show the user the plan

Print, as bullets, what you'll do. Example:

```
Detected pollution in CLAUDE.md:
- Lines 82–164: Laravel Boost guidelines → .td/frameworks/laravel-boost.md
- Lines 165–198: shadcn instructions → .td/frameworks/shadcn.md

Will restore CLAUDE.md to the canonical template.
```

Wait for the user's "go" before modifying anything.

# Step 4 — Move the content

For each block:

- If `.td/frameworks/<name>.md` does not exist, create it with the block content.
- If it exists, append the new block under a `## Update <YYYY-MM-DD>` heading.

Then restore `CLAUDE.md` to the canonical template content.

# Step 5 — Commit

```
git add CLAUDE.md .td/frameworks/
git commit -m "chore: relocate <framework> guidelines out of CLAUDE.md"
git push origin main
```

If multiple frameworks were relocated in one run, list them in the commit message: `chore: relocate laravel-boost, shadcn guidelines out of CLAUDE.md`.

# Step 6 — Tell the user

Brief summary: which frameworks were moved, where they live now, and a reminder that Claude reads `.td/frameworks/<name>.md` when working with that framework.

# Rules

- Manual only — never auto-trigger.
- Always show the plan before modifying.
- Never delete content. Always relocate.
- Preserve the canonical CLAUDE.md exactly. If you're not sure what's canonical, ask the user.
