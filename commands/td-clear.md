---
description: Mid-project context reset. Save state, push, ready for /clear. Project continues — this is a checkpoint, not a wrap.
---

You are checkpointing the current session so the user can `/clear` and the next session picks up cold. The project is not done — it's mid-flight. Keep it fast: state handoff, prune obvious junk, push. Optimization, code review, restructuring — out of scope. If something invites that, surface it as a backlog item or a future topic and move on.

# Step 1 — Audit current state

- Read `.td/STATE.md`, `.td/work/` listing, `.td/PROJECT.md`.
- `git status --short` — uncommitted changes? If yes: stop, ask the user "Commit them as a checkpoint, stash, or discard?" and wait. Do not proceed until working tree is clean.
- `git log origin/main..HEAD --oneline` — local commits ahead of remote.

# Step 2 — Quick code sanity check (not a review)

Skim recent changes (`git log -p -1` or `git diff origin/main..HEAD` if local commits exist). Look for ONLY these:

- Accidentally committed secrets (`.env` values, tokens, keys).
- Obvious leftovers (commented-out blocks, dead `if false`, debug prints).

If found, surface as one line and ask the user. **Don't refactor, don't optimize, don't restructure** — that's a separate topic, not part of clear.

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

# Step 4 — Light prune (only obvious dead docs)

Walk `.td/` for content git already covers:

- A `.td/work/<topic>.md` for a topic that's been shipped (its commits are in `git log`) → delete.
- Resolved blockers in `.td/STATE.md` → clear them out.
- Backlog items that have shipped → delete the line.

Don't restructure. Don't second-guess `WORKWAY.md` content. The deeper cleanup is `/td-close`.

# Step 5 — Update STATE.md as a handoff

Rewrite `.td/STATE.md` so a fresh conversation picks up cold. Top section is field-shaped; Resume note is free-form prose — as long as it needs to be:

```
Project:  <name>
Topic:    <current topic, or "idle">
Phase:    <whatever describes where we are — pick a word that fits>
Blocker:  <one-line if any, else "none">
Last:     <YYYY-MM-DD HH:MM> — <one-line summary>

## Resume note

<Plain prose. Can be 2 lines or 30. Whatever the next session needs to pick up cold:
what we were doing, what's done, what's pending, gotchas, key file paths, the
test command and where it lives, any context7 findings worth keeping. If we're
in the middle of planning a multi-step thing, this is where the plan lives.>
```

Resume note is the load-bearing part. During execution I'll skim it; for fresh-context orientation I'll read it fully. Don't artificially cap it.

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
- Don't run the full doc audit here — that's `/td-close`. Stay fast.
