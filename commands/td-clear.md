---
description: Mid-project context reset. Sync the .td/ docs to this session, write the STATE handoff, push — ready for /clear. Project continues; a checkpoint, not a wrap.
---

You are checkpointing the current session so the user can `/clear` and the next session picks up cold. The project is not done — it's mid-flight. Keep it fast: sync the `.td/` docs to what this session did, write the STATE handoff, prune obvious junk, push. Optimization, code review, restructuring, exhaustive doc audits — out of scope (that's `/td-close`). If something invites that, surface it as a backlog item or a future topic and move on.

# Step 1 — Update memory

Before anything else, scan the session for things worth keeping in the auto-memory system (`~/.claude/projects/.../memory/`). Look for:

- Decisions made that future sessions should know about (feedback, preferences, project choices)
- Technical facts discovered that aren't obvious from the code
- Anything the user explicitly said to remember

Update existing memory files rather than creating duplicates. If nothing new was learned, skip silently — don't create empty updates.

# Step 2 — Audit current state

- Read `.td/STATE.md`, `.td/work/` listing, `.td/PROJECT.md`.
- `git status --short` — uncommitted changes? If yes: stop, ask the user "Commit them as a checkpoint, stash, or discard?" and wait. Do not proceed until working tree is clean.
- `git log origin/main..HEAD --oneline` — local commits ahead of remote.

# Step 3 — Quick code sanity check (not a review)

Skim recent changes (`git log -p -1` or `git diff origin/main..HEAD` if local commits exist). Look for ONLY these:

- Accidentally committed secrets (`.env` values, tokens, keys).
- Obvious leftovers (commented-out blocks, dead `if false`, debug prints).

If found, surface as one line and ask the user. **Don't refactor, don't optimize, don't restructure** — that's a separate topic, not part of clear.

# Step 4 — Squash local-only commits (if any)

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

# Step 5 — Park anything before clearing

Ask the user: **"Anything to add to the backlog before we clear?"**

Wait for the answer. If they name something, append it to `.td/BACKLOG.md` as `- YYYY-MM-DD — <item>`. If they say nothing or no, continue immediately.

This is a single question — don't prompt for elaboration or turn it into a planning session.

# Step 6 — Sync the docs to this session, then prune

Before `/clear` wipes the conversation, make sure the `.td/` docs reflect what this session actually did — the next session loads them cold and treats them as true.

**Doc-sync.** Scan this session for anything that changed what a doc should say and isn't in it yet, and write it now:

- Scope moved — something shipped, or added to / dropped from active scope → `PROJECT.md § Active scope` / `§ Shipped`.
- Stack changed this session — a dependency added, removed, or major-version bumped → `PROJECT.md § Stack`. (Quick check: `git log --since="<STATE.Last date>" --name-only -- package.json composer.json pyproject.toml requirements.txt Gemfile go.mod Cargo.toml 2>/dev/null | sort -u`.)
- A durable framework gotcha, test-command change, deploy detail, or env quirk surfaced → `WORKWAY.md`.

This is **session-scoped** — only what changed *this session*, which you have the context for. It is not the exhaustive whole-doc audit; that's `/td-close`. In-the-moment routing (`CLAUDE.md § Where things go`) stays primary — this is the backstop for things that drifted through the work without a clean action-shaped statement. Anything genuinely ambiguous → note it in the Resume note (Step 7) for `/td-close` or the next session; don't block the checkpoint on it.

**Light prune.** Walk `.td/` for content git already covers:

- A `.td/work/<topic>.md` for a topic that's been shipped (its commits are in `git log`) → delete.
- Resolved blockers in `.td/STATE.md` → clear them out.
- Backlog items that have shipped → delete the line.

**Mailbox snapshot** (status read, always renders unless mailbox is empty). Fetch open issues in this repo and cross-repo filings (same shape as `/td-mailbox` Steps 2+4). Inbound counts **Bugs and Tasks only** — Ideas and Epics aren't handoff to-dos, so they stay out of the snapshot. Format:

```
[mailbox] 📥 <N> inbound (<Bug/Task breakdown>), 📤 <M> outbound (<state-breakdown>)
```

Examples: `[mailbox] 📥 3 inbound (1 Bug, 2 Task), 📤 0 outbound` | `[mailbox] empty`. Skip outbound segment if `.td/PROJECT.md § Cross-repo` is missing. No Bugs/Tasks inbound and no outbound → `[mailbox] empty`.

Don't restructure, and don't re-audit doc content that didn't change this session — the exhaustive doc audit is `/td-close`.

# Step 7 — Update STATE.md as a handoff

Rewrite `.td/STATE.md` so a fresh conversation picks up cold. The next context will load this and assume it's true — so the filter is sharp: **keep what matters and isn't derivable; clear everything else.**

- **Keep** in-flight specifics the next session can't reconstruct: current decision, current blocker, mid-thinking, the gotcha you just hit.
- **Clear** speculation ("we might want to..."), anything `git log` already says, or claims you haven't actually verified.
- **Mailbox snapshot** from Step 6 always renders at the very top of the Resume note (status read, not noise).

Top section is field-shaped; Resume note is free-form prose — as long as it needs to be:

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

# Step 8 — Push

```
git push origin main
```

If push is rejected (network, auth, divergence), surface the error and stop.

# Step 9 — Tell the user

One sentence: `Cleared. <N> commits pushed. STATE handoff written. Safe to /clear.`

# Rules

- Working tree must be clean before pushing. Never push with uncommitted changes silently stashed.
- Never force-push. Squashing is for local-only commits.
- If the user says "discard" for uncommitted changes, ask explicit confirmation — destructive.
- This command is the only place we rewrite recent local history. Day-to-day shipping never does.
- Don't run the full doc audit here — that's `/td-close`. Stay fast.
- Don't run cross-repo registry drift checks here — that's `/td-close` Step 7. Stay fast.
