---
description: Wrap the project (or a major phase). Park all leftover BACKLOG + work files to GitHub Issues, mechanical stack-reality-check vs PROJECT.md, doc hygiene pass across all .td/ docs (including the load-bearing Cross-repo registry), push.
---

You are closing the project (or a major phase). The work is done — shipped, live if it has a live, tested. This is the deeper cleanup that `/td-clear` skips: park leftover thinking to GitHub, walk every doc, validate it against current code and `git log`, prune anything redundant, restructure if drift has crept in. End with a clean, minimal `.td/` that an outsider could read in 2 minutes and understand the project.

If state shows clearly mid-flight (active `Topic`, `work/<topic>.md` files, unfinished plan in Resume note), still run — projects-per-hour is normal here. But surface in Step 2: "This looks mid-flight — are you wrapping the whole thing, or did you mean `/td-clear`?" and wait for the answer.

# Step 1 — Update memory

Before anything else, scan the session for things worth keeping in the auto-memory system (`~/.claude/projects/.../memory/`). Closing a project is the highest-value moment to capture — the full arc is visible. Look for:

- Decisions made that future sessions should know about (feedback, preferences, project choices)
- Technical facts discovered that aren't obvious from the code
- Anything the user explicitly said to remember

Update existing memory files rather than creating duplicates. If nothing new was learned, skip silently.

# Step 2 — Confirm intent and audit state

- Read `.td/STATE.md`, `.td/PROJECT.md`, `.td/WORKWAY.md`, `.td/BACKLOG.md`, every `.td/work/*.md`.
- `git status --short` — uncommitted? If yes: stop, ask "Commit, stash, or discard?" Wait.
- `git log origin/main..HEAD --oneline` — local commits ahead of remote.
- If STATE shows mid-flight: ask the user "wrapping the whole project, or did you mean `/td-clear`?" Wait.
- **Unresolved-issue gate.** Fetch open issues in this repo (same query as `/td-mailbox` Step 2). Filter to `Bug` + `Task` only — Epics are planning surfaces (track via their Task/Bug children, not the parent itself); Ideas are long-tail by design and don't gate a close. Also fetch awaiting-reply outbound (informational only, no gate — same shape as `/td-mailbox` Step 4).

  If any open Bug or Task exists, surface and ask:

  ```
  Open work this project still has:
    Bug   (X)   #<N> — <title>
    Task  (X)   #<N> — <title>

  Outbound awaiting reply (FYI, doesn't block):
    <repo>#<N> — <title>

  Continue close? (yes / abort)
  ```

  Wait. `yes` → proceed to Step 3. `abort` → stop, exit. User can `/td-mailbox` separately to triage, then re-run `/td-close`.

  If no open Bug/Task exists, skip this prompt silently. The outbound FYI alone isn't enough to gate — surface it as a one-liner heads-up and continue.

# Step 3 — Park leftovers to GitHub

Walk every leftover thinking surface and route it: ship-now (the user picks it up as the next piece — close aborts and the rhythm resumes), sync to GitHub Issues (with Type), or drop.

**Two sources to walk, in order:**

1. **`.td/BACKLOG.md` line-by-line** — same procedure as `/td-park` Step 4 (type suggestion from phrasing, dedupe against open issues, sync via `gh api graphql createIssue` with the chosen Type ID and `**From:** <sender-name>` marker).

2. **`.td/work/<topic>.md` files** — for each work file:
   - Check `git log --grep="<topic>" --oneline` — is the topic shipped? If yes: ask "Topic looks shipped — delete this work file?" (the standard outcome for finished work).
   - If unshipped: ask "Ship now / Park to GH as Type X / Drop?" The work file's content becomes the GH issue body (Symptom/Context/Hypothesis/Fix structure for incidents; freeform for plans).
     - `Bug` for incident work files
     - `Epic` for planning work files that decompose into sub-issues
     - `Task` for everything else (single-chunk work, catch-all)
   - If parked: same `gh api graphql createIssue` mutation, work file content as body, `**From:** <sender-name>` marker.
   - If dropped: confirm, then delete.

After this step:
- `.td/BACKLOG.md` is empty (`(empty)` placeholder restored).
- `.td/work/` is empty (or near-empty if the user said "ship now" on something).
- Any synced items are tracked in GitHub Issues with the right Type.

# Step 4 — Code sanity sweep

Skim the working tree and recent commits for:

- Accidentally committed secrets (`.env` values, tokens, keys). If found: stop and confirm with the user.
- Obvious leftovers: commented-out blocks, dead `if false`, debug prints, `console.log`, `dd()`.
- TODO/FIXME comments in code. Surface them as one line each — user decides:
  - **fix now** — the rhythm resumes briefly to fix
  - **create GH issue** as `Idea` or `Task` (direct creation via `gh api graphql`, since BACKLOG is now empty)
  - **leave** — TODO stays in code, untracked

Don't refactor. Don't optimize. Surface, don't act.

# Step 5 — Squash local-only commits (if any)

If 2+ commits ahead of `origin/main`, offer to squash. Same rules as `/td-clear`:

```
git reset --soft origin/main
git commit -m "<message>"
```

Never squash commits already on `origin/main`. Never force-push.

# Step 6 — Stack reality check (mechanical)

Dependency files are authoritative for what's installed; `PROJECT.md § Stack` and `WORKWAY.md § Framework specifics` describe what the project *says* it is. Diff them — this is the most common drift, and mechanical to detect. Don't trust memory or what previous sessions wrote; read the files now.

Detect which stack files are present, and for each one read its declared top-level dependencies (names + major versions only — not transitive, not exact patch versions):

- **Node**: `package.json` → `dependencies`, `devDependencies`
- **PHP**: `composer.json` → `require`, `require-dev`
- **Python**: `pyproject.toml` (`[project.dependencies]` or `[tool.poetry.dependencies]`), or `requirements.txt`
- **Ruby**: `Gemfile`
- **Go**: `go.mod` (`require` block)
- **Rust**: `Cargo.toml` `[dependencies]`

Read `PROJECT.md § Stack` and `WORKWAY.md § Framework specifics`. Surface each mismatch as ONE LINE for the user to act on:

```
[stack drift] composer.json: livewire/livewire ^4.0  →  PROJECT.md says Livewire 3. Bump PROJECT.md? (y/n/edit)
[stack drift] composer.json: sentry/sentry-laravel ^4.5  →  PROJECT.md § Stack doesn't mention Sentry. Add? (y/n)
[stack drift] PROJECT.md: "Tailwind"  →  no tailwindcss in package.json. Remove from PROJECT.md? (y/n)
```

Walk one mismatch at a time, apply the user's choice in-place. Focus on the human-curated layer (frameworks, choices, "why we picked this") — don't paste the whole dep list into PROJECT.md; the dep file IS the dep list.

If no stack files exist (pure-markdown repo, etc.): say so out loud (`no stack files detected, skipping mechanical check`) and continue.

# Step 7 — Doc hygiene pass

The next conversation will load whatever these docs say and assume it's true. So: **keep what matters and is not derivable; clear everything else.**

Apply this filter to every `.td/` doc:

- **Keep** if all three hold: (a) it matters for next session, (b) it's not derivable from code or `git log`, (c) we actually know it to be true.
- **Clear** if: it's speculative ("might want to..."), it duplicates what `git log` or the codebase already says, or it's a placeholder that was never filled in.

Walk doc by doc, surface decisions as one-liners:

- **PROJECT.md § Active scope** — anything actually shipped? Move to "Shipped". Anything quietly abandoned? Ask before deleting.
- **PROJECT.md § What this is / Who for** — re-read against what actually got built. If the one-liner no longer fits, propose a new one and ask.
- **PROJECT.md § Stack** — drift items from Step 6 already handled. Now check: is anything here just a copy of the dep file? Prune to the human-curated layer.
- **PROJECT.md § Cross-repo** — load-bearing for `/td-mailbox` outbound. Run the same drift check `/td-refresh` Phase 3 does: org-wide `**From:**` marker search → diff observed vs declared → propose add/remove per delta. Apply confirmed deltas inline. (Or defer: tell the user "Cross-repo drift check available via `/td-refresh` if you want to handle separately.")
- **ARCHITECTURE.md** — if it exists, walk § Important decisions / § What's load-bearing / § Surprises against `git log` since last edit. Surface one line per check: "Anything decided this session worth recording in § Important decisions?" / "Anything shipped that's now load-bearing for downstream code?" / "Any counterintuitive choice in the diff that future-you would misread?" Don't auto-write — prompt + wait. If the doc doesn't exist and the project has shipped non-trivial decisions, surface: "No ARCHITECTURE.md — want to create one from template? (yes / not yet)". Skip if the project is genuinely small.
- **WORKWAY.md § Local testing** — does `Test command` still exist in `package.json` / equivalent? Run it. If removed, flag.
- **WORKWAY.md § Local UAT / Production / Ship** — live URL still up? Smoke command works? Anything that reads as guesswork ("probably deploys via...") → verify or clear.
- **WORKWAY.md § Framework specifics** — anything for a framework we removed? Prune.
- **WORKWAY.md § Notes** — content now in committed code or covered by `git log`? Delete.
- **BACKLOG.md** — handled in Step 3 (flushed to GH). Should be empty.
- **work/** — handled in Step 3. Should be empty (or near-empty).

Don't invent values when fixing drift. If reality doesn't tell us, ask the user.

# Step 8 — Prune STATE.md to "closed" shape

After this command, STATE should signal "nothing pending". Rewrite it minimally:

```
Project:  <name>
Topic:    idle
Phase:    closed (<YYYY-MM-DD>)
Blocker:  none
Last:     <YYYY-MM-DD HH:MM> — closed.

## Resume note

<One short paragraph: what got built, where it lives, what to know if you come
back later. Not a changelog — git is the changelog. Just enough that a future
session knows whether to /td-init fresh or pick up from here.>
```

If the user said in Step 2 they're wrapping a phase (not the whole project), use a different `Topic` and `Phase` to reflect that — but the Resume note still summarizes what just wrapped, not what's coming next. The next session writes the next plan.

# Step 9 — Commit the cleanup

One commit, explicit paths:

```
git add .td/ <any other touched docs>
git commit -m "chore: close <project-or-phase-name>"
```

If nothing changed in Steps 6–8, skip this commit (don't make empty commits).

Note: items synced to GitHub Issues in Step 3 didn't touch the working tree (they were GH-side mutations), so the close commit captures only doc changes here. The `.td/BACKLOG.md` going from filled to empty IS a working-tree change and ships in this commit.

# Step 10 — Push

```
git push origin main
```

If push is rejected, surface and stop.

# Step 11 — Tell the user

Two parts:

**One sentence summary line:** `Closed. <N> commits pushed. <P> items parked to GitHub. <.td/ prune summary>.`

**One short paragraph:** What got built and shipped, any meaningful decisions made, and the single most important thing to know if someone (or a future session) picks this up later. Not a changelog — git has that. Just the things that aren't obvious from reading the code.

# Rules

- Working tree clean before pushing. Never push with silently stashed changes.
- Never force-push. Squashing is for local-only commits.
- This command IS allowed to delete docs and rewrite STATE/PROJECT/WORKWAY content — that's the point. But never delete `CLAUDE.md`, never delete the canonical doc files (PROJECT/WORKWAY/STATE/BACKLOG remain even when minimal — BACKLOG goes back to `(empty)` placeholder, not deleted).
- Don't invent values when fixing drift. If reality doesn't tell us, ask.
- If the user defers any decision, leave it and continue — don't block the close on optional cleanup.
- **Step 3 (park leftovers) is the first writer-side step** — it creates GitHub issues. After it runs, the project's parked thinking lives on GitHub, not in local docs. Subsequent steps then prune the now-redundant local state.
