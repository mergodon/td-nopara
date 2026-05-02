---
description: Review, validate, cleanup, and push before context reset. Run this before /clear so the next session picks up cold.
---

You are wrapping the current session for context reset. The goal: leave the repo and `.td/STATE.md` so a fresh conversation reading them picks up without questions. Anything git already remembers gets removed from the docs.

# Step 1 — Audit current state

- Read `.td/STATE.md`, `.td/work/` listing, `.td/PROJECT.md`.
- `git status --short` — uncommitted changes? If yes: stop, ask the user "Commit them as a checkpoint, stash, or discard?" and wait. Do not proceed until working tree is clean.
- `git log origin/main..HEAD --oneline` — local commits ahead of remote.

# Step 2 — Review the code

Skim recent changes (`git diff origin/main..HEAD` or, if all pushed, `git log -p -1`). Confirm:

- Tests still green (run `WORKWAY.md § Local testing → Test command`).
- No half-done branches in code (TODO without context, dead `if false`, commented-out blocks).
- No accidentally committed secrets (.env values, tokens, keys).

If anything looks wrong, surface it as one line and ask the user how to handle it. Do not auto-fix.

# Step 3 — Squash local-only commits (if any)

If 2+ commits are ahead of `origin/main`, ask: "Squash these N local commits into one? Suggested message: `<message>`."

Suggested message format:

- Inside an active topic mid-piece: `feat(<topic>): <one-line> (checkpoint)`
- Otherwise: ask the user for a one-line message.

If confirmed:

```
git reset --soft origin/main
git commit -m "<message>"
```

Never squash commits already on `origin/main`. Never force-push.

# Step 4 — Remove redundant docs

Walk `.td/` looking for content that git already covers:

- A `.td/work/<topic>.md` for a topic that's been shipped (its commits are in `git log`) → delete.
- One-off settings flags noted in `.td/WORKWAY.md` § Notes that are already in committed code → delete the note.
- Resolved blockers in `.td/STATE.md` → clear them out.
- Backlog items that have shipped → delete the line.

The principle: if `git log` or the current code holds the answer, the doc doesn't need to repeat it.

# Step 5 — Update STATE.md as a handoff

Rewrite `.td/STATE.md` so a fresh conversation can pick up cold:

```
Project:  <name>
Topic:    <current topic, or "idle">
Phase:    <Plan | Work | Test | Ship | idle>
Blocker:  <one-line if any, else "none">
Last:     <YYYY-MM-DD HH:MM> — <one-line summary of where we left off>

## Resume note

<2–4 lines of plain prose: what we were doing, what's done, what's pending, any gotchas the next session needs>
```

Resume note is the load-bearing part. Write it as if briefing yourself in two weeks.

# Step 6 — Push

```
git push origin main
```

If push is rejected (network, auth, divergence), surface the error and stop.

# Step 7 — Tell the user

One sentence: `Cleared. <N> commits pushed. STATE handoff written. Safe to /clear.`

# Rules

- Working tree must be clean before pushing. Never push with uncommitted changes silently stashed.
- Never force-push. Squashing is for local-only commits.
- If the user says "discard" for uncommitted changes, ask explicit confirmation — destructive.
- This command is the only place we rewrite recent local history. Day-to-day shipping never does.
