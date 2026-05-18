---
description: Routine inbox check — walk open GH issues in this repo, surface new comments and related commits, then close / comment / skip each one. Repo-scoped by default.
---

You are running the routine inbox check for this repo. The job: walk every open GitHub issue in this repo, surface what's there (body, comments, any commits that reference it), and help the user decide one issue at a time: **close, comment, or skip**. Repo-scoped by default — never widen to all repos here.

# Step 0 — Verify we're in a td-flow project with GH access

- Confirm `./.td/` exists. If missing: abort, "Not a td-flow project."
- Verify `gh` is authenticated and the repo has a remote — `gh repo view --json name 2>/dev/null`. If it fails: abort, "No GitHub remote or `gh` not authenticated."

# Step 1 — Gather open issues

```
gh issue list --state open --json number,title,body,createdAt,updatedAt,author,url --jq 'sort_by(.updatedAt) | reverse'
```

If the list is empty: tell the user `Inbox empty. ✓` and exit. Don't write anything, don't commit anything.

# Step 2 — Identify the current project's friendly name

Resolve the receiver's friendly name (used to sign comments and closures, per `CLAUDE.md § Cross-repo` project-soul rule):

1. Read `$TD_REGISTRY/SERVICES.md` (local clone first, else `gh api`). Find the row where the slug matches `mergodon/<this-repo>`. Use its Friendly column.
2. Fall back to the first H1 heading in `.td/PROJECT.md`.
3. Final fallback: the basename of the current directory.

Hold this as `<receiver-name>` for the rest of the run.

# Step 3 — For each issue, surface

Walk the issue list most-recent-first. For each, gather and display:

**Header line:**
```
#<N>  <title>  (from: <source-project>, opened <YYYY-MM-DD>)
```

- Parse `<source-project>` from the `**From:** <name>` marker at the top of the issue body, per the project-soul framing. If no marker, label as `(unmarked)`.

**Body:** print the issue body verbatim.

**Comments:** `gh issue view <N> --comments` — show all comments inline as:
```
[YYYY-MM-DD] <author or parsed source-project>: <comment body>
```

**Related commits:** `git log --grep="#<N>" --oneline -10` — any commits in this repo that reference the issue number. Surface if any.

**Recommendation** (one line):
- If commits referencing `#<N>` look like a fix or include `Closes #<N>` syntax that didn't auto-close → "Looks resolved — close?"
- If the most recent comment is from another project (parsed via `From:` or author ≠ this project) → "Awaiting reply — comment?"
- If neither signal fires → "Pending — leave open?"

# Step 4 — Walk per issue (one at a time, apply before moving on)

For each issue, wait for the user to say one of: `close` / `comment` / `skip` / freeform.

**On `close`:**
1. Ask "Closing comment? (yes / no)". Wait.
2. If yes: draft a short closing comment based on the discussion (one sentence ideally, two max). Append the sign-off: `— <receiver-name>`. Show to the user, confirm.
3. Run:
   - With comment: `gh issue close <N> --comment "<drafted text>"`
   - Without comment: `gh issue close <N>`

**On `comment`:**
1. Draft a comment based on the discussion + the user's intent (ask the user for the gist if it's not obvious). Append `— <receiver-name>`. Show to the user, confirm.
2. Run: `gh issue comment <N> --body "<drafted text>"`

**On `skip`:** continue to the next issue.

**On freeform:** interpret as best you can — usually "I want to do X" maps to one of the three. If genuinely unclear, ask.

Apply the action *before* moving to the next issue. Don't batch.

# Step 5 — Summary

After the last issue:

```
Inbox reviewed: <total> issues. <closed> closed. <commented> commented on. <skipped> left open.
```

# Rules

- **Repo-scoped only.** Never widen to all repos here — that's a separate explicit trigger ("all repos" / "global inbox") per `CLAUDE.md § Cross-repo`.
- **Always sign comments and closures** with `— <receiver-name>` (the project-soul rule). Never address GH usernames in the body.
- **Never auto-close, never auto-post.** Always show drafted text and confirm before sending.
- **Don't commit anything in this command** — closures and comments don't touch the working tree. This is purely a GH-side operation.
- **One issue at a time.** No batching, no parallel walks. The user's attention is the bottleneck; respect it.
- **If `gh` errors mid-walk** (rate limit, auth, network), stop and surface the error. Don't retry silently.
- **Outbound issues (filed by this project into others)** are out of scope here. That's a future concern — for now, the user invokes `gh search issues --author @me --state open` explicitly when they want it.
