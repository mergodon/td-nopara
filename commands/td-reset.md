---
description: Squash local-only commits, write a clean handoff into STATE.md, push. Run before /clear.
---

You are preparing this project for a fresh context window. Goal: leave the repo and `.td/STATE.md` so that a new conversation reading them picks up cold without questions.

# Step 1 — Audit

- Read `.td/STATE.md` and `.td/flow/` to understand current position.
- `git status --short` — any uncommitted changes? If yes, ask the user: "Commit them as a checkpoint, stash, or discard?" Wait for an answer. Do not proceed until working tree is clean.
- `git log origin/main..HEAD --oneline` — list local commits ahead of remote.

# Step 2 — Squash local-only commits (if any)

If two or more commits are ahead of `origin/main`, ask the user: "Squash these N local commits into one? Suggested message: `<message>`." 

The suggested message should match the commit format from `CLAUDE.md`:

- If we're inside a BIG flow, mid-piece: `feat(<feature>): <NN> <piece-name> (checkpoint)`
- If we're inside a SMALL flow: `fix: <description> (checkpoint)`
- Otherwise: ask the user for a one-line message

If the user confirms:

```
git reset --soft origin/main
git commit -m "<message>"
```

Never squash commits that are already on `origin/main`. Never force-push.

# Step 3 — Rewrite STATE.md as a handoff

Write `.td/STATE.md` so a new conversation can pick up without context. Include:

```
Project: <name>
Currently: <unchanged from before, or refined>
Position: <piece NN of N, or "—" for SMALL>
Status: <ready / in-progress / blocked>
Last action: <YYYY-MM-DD HH:MM> — <one-line summary of where we left off>
Next: <one-line — what the next conversation should do first>
Blocker: <one-line if any, else "none">

## Open threads
<up to 3 short notes the next session needs to know>

## Resume note
<2–4 lines of plain prose: what we were doing, what's done, what's pending, any gotchas>
```

The Resume note is the key part. Write it as if briefing yourself in 2 weeks.

# Step 4 — Push

```
git push origin main
```

If push is rejected, surface the error and stop.

# Step 5 — Tell the user

One sentence: "Reset done. Local squashed (or no-op), STATE handoff written, pushed. Safe to `/clear`."

# Rules

- Working tree must be clean before pushing. Never push with uncommitted changes silently stashed.
- Never force-push. Squashing is for local-only commits.
- If the user says "discard" for uncommitted changes, ask for explicit confirmation since it's destructive.
- This command is the only place we rewrite recent local history. `/td-ship` never does.
