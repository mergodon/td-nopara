---
description: Append a bug or feature idea about the td-flow framework itself to its FEEDBACK.md doc. Does not touch the current project.
---

You are filing feedback **about td-flow itself** — something quirky, missing, or annoying about the framework. This is different from `/td-note`, which captures items about the *current project*. Feedback goes to a single doc in the framework repo.

The argument is the feedback text. Optional `bug:` or `idea:` prefix to classify; otherwise classify automatically.

# Step 1 — Locate the framework repo

```
FRAMEWORK_DIR=$(dirname "$(readlink -f ~/.claude/td-templates)")
```

If the symlink is missing, abort: "td-flow framework not installed. Run `~/projects/td/install.sh`."

# Step 2 — Classify

- Prefix `bug:` or `bug ` → `bug` (strip prefix).
- Prefix `idea:` or `idea ` → `idea` (strip prefix).
- Keywords `broken`, `fails`, `error`, `crash`, `wrong`, `regression`, `doesn't work`, `not working` → `bug`.
- Otherwise → `idea`.

# Step 3 — Append to FEEDBACK.md

If `$FRAMEWORK_DIR/FEEDBACK.md` doesn't exist, create it from the template at `$FRAMEWORK_DIR/templates/FEEDBACK.md`.

Read the current project's name from `.td/PROJECT.md` (the first `# heading`), or fall back to the cwd basename if not in a td-flow project.

Append one line under the appropriate section (`## Open` or `## Bugs`):

```
- [<bug|idea>] <YYYY-MM-DD> — <text> (from: <project_name>)
```

If the section ends with the placeholder `(empty)`, replace that line with the new entry.

# Step 4 — Commit and push

```
cd "$FRAMEWORK_DIR"
git add FEEDBACK.md
git commit -m "feedback: <bug|idea>: <first 50 chars>"
git push origin main 2>/dev/null || true
```

If push fails because no remote is configured or auth is missing, that's fine — leave the commit local. Do not surface the push failure as an error; just note it.

# Step 5 — Tell the user

One line, with location:

- If pushed: `Filed [bug|idea] in mergodon/td-nopara FEEDBACK.md and pushed.`
- If local-only: `Filed [bug|idea] locally in ~/projects/td/FEEDBACK.md (not pushed).`

Then **return to whatever flow was in progress**. Do not act on the feedback. Do not start fixing the framework.

# Rules

- Never touch the current project's `.td/` or git.
- Never start fixing the framework here.
- One line per entry. Detail can be added by editing FEEDBACK.md directly later.
