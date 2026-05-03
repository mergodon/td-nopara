---
description: Wrap the project (or a major phase). Full doc audit, structure check, prune everything git already covers, validate PROJECT.md against reality, push.
---

You are closing the project (or a major phase). The work is done — shipped, live if it has a live, tested. This is the deeper cleanup that `/td-clear` skips: walk every doc, validate it against current code and `git log`, prune anything redundant, restructure if drift has crept in. End with a clean, minimal `.td/` that an outsider could read in 2 minutes and understand the project.

If state shows clearly mid-flight (active `Topic`, `work/<topic>.md` files, unfinished plan in Resume note), still run — projects-per-hour is normal here. But surface in Step 1: "This looks mid-flight — are you wrapping the whole thing, or did you mean `/td-clear`?" and wait for the answer.

# Step 1 — Confirm intent and audit state

- Read `.td/STATE.md`, `.td/PROJECT.md`, `.td/WORKWAY.md`, `.td/BACKLOG.md`, every `.td/work/*.md`.
- `git status --short` — uncommitted? If yes: stop, ask "Commit, stash, or discard?" Wait.
- `git log origin/main..HEAD --oneline` — local commits ahead of remote.
- If STATE shows mid-flight: ask the user "wrapping the whole project, or did you mean `/td-clear`?" Wait.

# Step 2 — Code sanity sweep

Skim the working tree and recent commits for:

- Accidentally committed secrets (`.env` values, tokens, keys).
- Obvious leftovers: commented-out blocks, dead `if false`, debug prints, `console.log`, `dd()`.
- TODO/FIXME comments. Surface them as one line each — user decides: park to BACKLOG, fix now, or leave.

Don't refactor. Don't optimize. Surface, don't act.

# Step 3 — Squash local-only commits (if any)

If 2+ commits ahead of `origin/main`, offer to squash. Same rules as `/td-clear`:

```
git reset --soft origin/main
git commit -m "<message>"
```

Never squash commits already on `origin/main`. Never force-push.

# Step 4 — Validate PROJECT.md against reality

PROJECT.md describes what this project is. Drift is normal across many sessions — fix it now.

- **Stack section** — does it still match the dependency files (`package.json`, `composer.json`, etc.)? Update if drifted.
- **Active scope** — anything listed there that's actually shipped? Move it to "Shipped". Anything that's been quietly abandoned? Ask the user before deleting.
- **What this is / Who for** — re-read in light of what actually got built. If the one-liner no longer fits the project, propose a new one and ask.

# Step 5 — Validate WORKWAY.md against reality

- **Local testing** — does `Test command` still work? Run it. Does `Dev server` start? If a command is listed but the script no longer exists in `package.json` etc., flag it.
- **Local UAT** — is the manual check description still accurate?
- **Production / Ship** — live URL still up? Smoke command still works?
- **Framework specifics** — anything noted here that's no longer relevant (e.g. a framework was removed)? Prune.
- **Notes** — content that's now in committed code or covered by `git log`? Delete.

# Step 6 — Prune `.td/work/`

For every `.td/work/<topic>.md`:

- If the topic is shipped (commits in `git log` for `<topic>`): delete the file.
- If the topic was abandoned: ask the user "delete or move to BACKLOG?"
- If still in progress: this contradicts a "wrap" close — re-confirm with the user.

After this step, `.td/work/` should be empty (or near-empty).

# Step 7 — Prune BACKLOG.md

- Lines describing work that's shipped → delete.
- Lines that no longer make sense (referenced obsolete code, etc.) → delete.
- Keep genuinely-still-parked items.

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

If the user said in Step 1 they're wrapping a phase (not the whole project), use a different `Topic` and `Phase` to reflect that — but the Resume note still summarizes what just wrapped, not what's coming next. The next session writes the next plan.

# Step 9 — Commit the cleanup

One commit, explicit paths:

```
git add .td/ <any other touched docs>
git commit -m "chore: close <project-or-phase-name>"
```

If nothing changed in Steps 4–8, skip this commit (don't make empty commits).

# Step 10 — Push

```
git push origin main
```

If push is rejected, surface and stop.

# Step 11 — Tell the user

One sentence: `Closed. <N> commits pushed. <.td/ prune summary>. Safe to /clear.`

If anything was surfaced for user decision in earlier steps and they deferred, repeat the list as a second line — they can pick up next session.

# Rules

- Working tree clean before pushing. Never push with silently stashed changes.
- Never force-push. Squashing is for local-only commits.
- This command IS allowed to delete docs and rewrite STATE/PROJECT/WORKWAY content — that's the point. But never delete `CLAUDE.md`, never delete the five canonical doc files (PROJECT/WORKWAY/STATE/BACKLOG remain even when minimal).
- Don't invent values when fixing drift. If reality doesn't tell us, ask.
- If the user defers any decision, leave it and continue — don't block the close on optional cleanup.
