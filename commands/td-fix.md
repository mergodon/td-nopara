---
description: Start a SMALL flow — write fix.md, do it, ship. No planning ceremony.
---

You are starting a SMALL flow for a fix or tweak. The argument is a short description.

# Preconditions

- `.td/` exists. If not, abort: tell the user to run `/td-init` first.
- `.td/flow/` is empty or absent. If a flow is in progress, abort.

# Step 1 — Write fix.md

Read `.td/PROJECT.md`, `.td/TESTING.md`, and `.td/INBOX.md` for context. If the fix description matches an inbox `[bug]` line, plan to delete that line as part of the fix's commit. Write `.td/flow/fix.md`:

```
# Fix: {{description}}

Goal: <one sentence — what's broken or being changed>
Plan: <one or two bullets — what you'll do>
Test: <one sentence — what proves it works>
```

Keep it tight. If you find the description requires more than 30 min of work or touches multiple surfaces, stop and suggest `/td-feature` instead.

# Step 2 — Update STATE

Rewrite `.td/STATE.md`:

```
Project: <name>
Currently: fix → "{{description}}"
Position: —
Status: ready to ship
Last action: <YYYY-MM-DD> — fix scoped
Next: /td-ship
Blocker: none

## Open threads
(none)
```

# Step 3 — Tell the user

One-line summary: "Fix scoped. Run `/td-ship` to do it."

# Rules

- No discussion phase, no reality check, no numbered pieces. SMALL is fast.
- If the work turns out bigger mid-execution, abort the SMALL flow (`/td-reset`) and start a `/td-feature`.
