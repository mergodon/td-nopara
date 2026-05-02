---
description: Capture a bug or feature idea into .td/INBOX.md without breaking the current flow.
---

You are appending a one-line note to the project's inbox. **Do not break the current flow.** Do not switch to fixing the noted item — just record it and return.

The argument is the note text. It may be prefixed with `bug:` or `idea:` to classify; otherwise classify automatically.

# Step 1 — Locate the inbox

Read `.td/INBOX.md`. If it doesn't exist:
- If `.td/` exists: create `.td/INBOX.md` from the template at `~/.claude/td-templates/td/INBOX.md`.
- If `.td/` doesn't exist: abort. Tell the user to run `/td-init` first.

# Step 2 — Classify

If the argument starts with `bug:` or `bug ` (case-insensitive) → `bug`. Strip the prefix.
If the argument starts with `idea:` or `idea ` → `idea`. Strip the prefix.
Otherwise, classify by content:
- Mentions of `broken`, `fails`, `error`, `crash`, `wrong`, `regression`, `404`, `500`, `doesn't work`, `not working` → `bug`
- Anything else → `idea`

If you can't tell and the text is ambiguous, default to `idea`. Don't ask the user — the whole point is zero friction.

# Step 3 — Append

Append one line to `.td/INBOX.md`:

```
- [<bug|idea>] <YYYY-MM-DD> — <text>
```

If the file ends with the placeholder `(empty)`, replace that line with the new entry. Otherwise append at the end of the file.

Keep the order: append at the bottom (chronological). Do not group, sort, or reformat existing lines.

# Step 4 — Commit

Stage and commit:

```
git add .td/INBOX.md
git commit -m "chore: inbox — <bug|idea>: <first 50 chars of text>"
git push origin main
```

This commit is intentionally outside any active flow. It's safe to do mid-feature because INBOX.md is independent of `.td/flow/`.

If the pre-commit hook fails (project tests broken because of unrelated work), tell the user and stop — don't bypass.

# Step 5 — Tell the user

One line: "Noted as [bug|idea]. Inbox: N items." Then **return to whatever flow was in progress** — do not act on the note.

# Rules

- Never modify `.td/STATE.md` or `.td/flow/*` from this command.
- Never start fixing the noted item, even if it looks easy.
- One line per note. Long descriptions get truncated; the user can edit `INBOX.md` directly later if more detail is needed.
- Inbox commits do not touch `.td/PROJECT.md` "Active scope" — items move to scope only via `/td-feature` or `/td-fix`.
