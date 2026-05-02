---
description: Print the current state of the project — position, last action, next step, blocker.
---

You are showing the user where they stand. This command is read-only — never modify files.

# Step 1 — Read

- `.td/STATE.md`
- `.td/flow/` listing (filenames only)
- `.td/INBOX.md` (count `[bug]` and `[idea]` lines)
- `git status --short` (uncommitted changes)
- `git log --oneline -5` (last 5 commits)
- `git rev-list --count origin/main..HEAD` (local commits ahead of remote, if any)

If `.td/STATE.md` doesn't exist, tell the user to run `/td-init` and stop.

# Step 2 — Print

Format the output as a single tight block:

```
Project: <name>
Currently: <STATE.md "Currently" line>
Position: <STATE.md "Position" line>
Status: <STATE.md "Status" line>
Last action: <STATE.md "Last action" line>
Next: <STATE.md "Next" line>
Blocker: <STATE.md "Blocker" line>

Flow files: <count> (<list of NN-names if BIG, or "fix.md" if SMALL, or "—" if none>)
Inbox: <total> items (<bugs> bugs, <ideas> ideas)
Uncommitted: <count> files
Local commits ahead: <count>

Recent commits:
  <abbrev hash> <subject>
  <abbrev hash> <subject>
  ...
```

# Rules

- Do not edit anything.
- If anything looks inconsistent (e.g., STATE says "idle" but flow files exist), flag it as a single warning line at the bottom — do not auto-fix.
