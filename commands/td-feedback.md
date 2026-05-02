---
description: Send a bug report or feature idea about the td-flow framework itself to the framework repo. Does not touch the current project.
---

You are filing feedback **about td-flow itself** — something quirky, missing, or annoying about the framework. This is different from `/td-note`, which captures items about the *current project*. `/td-feedback` reaches across into the td-flow framework repo so the user can later pull and review.

The argument is the feedback text. Optional `bug:` or `idea:` prefix to classify; otherwise classify automatically.

# Step 1 — Locate the framework repo

The framework lives where `~/.claude/td-templates` symlink points. Resolve it:

```
FRAMEWORK_DIR=$(dirname "$(readlink -f ~/.claude/td-templates)")
```

If the symlink is missing, abort and tell the user: "td-flow framework not installed. Run `~/projects/td/install.sh`."

# Step 2 — Classify

Same rule as `/td-note`:

- Prefix `bug:` or `bug ` → `bug` (strip prefix).
- Prefix `idea:` or `idea ` → `idea` (strip prefix).
- Keywords `broken`, `fails`, `error`, `crash`, `wrong`, `regression`, `doesn't work`, `not working` → `bug`.
- Otherwise → `idea`.

# Step 3 — Send the feedback

Check if `gh` is on PATH **and** the framework repo has a GitHub remote:

```
cd "$FRAMEWORK_DIR" && git remote get-url origin 2>/dev/null
```

**If yes (GitHub issue path):**

```
cd "$FRAMEWORK_DIR"
gh issue create \
  --title "<bug|idea>: <first 60 chars of text>" \
  --body "<full text>

---
Reported via /td-feedback from project: <current project name from .td/PROJECT.md or cwd basename>
" \
  --label "<bug|idea>"
```

If the labels `bug` or `idea` don't exist on the repo, create them on the fly with `gh label create <name> --force`. (Skip `--force` if the gh version doesn't support it; just retry without `--force`.)

Capture the issue URL from the gh output.

**If no (offline/local fallback):**

Append to `$FRAMEWORK_DIR/FEEDBACK.md` (create it if missing):

```
- [<bug|idea>] <YYYY-MM-DD> — <text> (from project: <project name>)
```

Then commit inside the framework repo:

```
cd "$FRAMEWORK_DIR"
git add FEEDBACK.md
git -c user.email=<from git config> -c user.name=<from git config> commit -m "feedback: <bug|idea>: <first 50 chars>"
```

Do not push. The user pulls and reviews when they're ready.

# Step 4 — Tell the user

One line, with the destination so the user can find it later:

- GitHub path: `Filed [bug|idea] on td-flow: <issue URL>`
- Local path: `Filed [bug|idea] in ~/projects/td/FEEDBACK.md (no remote configured).`

Then **return to whatever flow was in progress**. Do not act on the feedback. Do not start fixing the framework.

# Rules

- This command does NOT touch the current project's `.td/`, `.git`, or `INBOX.md`. It writes to the framework repo only.
- Never start fixing the framework here. The whole point is fire-and-forget.
- If the GitHub issue creation fails (auth, network), fall back to the local file and tell the user both that the issue failed and that it was logged locally.
- Do not push the framework repo from this command — the user reviews and decides what to push.
