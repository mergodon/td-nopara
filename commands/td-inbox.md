---
description: Routine inbox check — walk open GH issues grouped by Issue Type (Epic / Bug / Feature / Task / Idea), surface sub-issue progress for Epics, then close / comment / skip each one. Repo-scoped by default.
---

You are running the routine inbox check for this repo. The job: walk every open GitHub issue, grouped by Issue Type so the highest-leverage items surface first, and help the user decide one issue at a time: **close, comment, or skip**. Repo-scoped by default — never widen to all repos here.

# Step 0 — Verify we're in a td-flow project with GH access

- Confirm `./.td/` exists. If missing: abort, "Not a td-flow project."
- Verify `gh` is authenticated and has a remote: `gh repo view --json name,owner 2>/dev/null`. If it fails: abort, "No GitHub remote or `gh` not authenticated."
- Capture the slug as `<owner>/<name>` for use in GraphQL queries below.

# Step 1 — Gather open issues via GraphQL

```
gh api graphql -H "GraphQL-Features: sub_issues" -f query='
  query($owner: String!, $name: String!) {
    repository(owner: $owner, name: $name) {
      issues(first: 50, states: OPEN, orderBy: {field: UPDATED_AT, direction: DESC}) {
        nodes {
          number
          title
          body
          url
          createdAt
          updatedAt
          author { login }
          issueType { id name color }
          subIssuesSummary { total completed percentCompleted }
        }
      }
    }
  }' -F owner=<owner> -F name=<name>
```

Parse the response. If `nodes` is empty: tell the user `Inbox empty. ✓` and exit.

# Step 2 — Identify this project's friendly name

(Same as before — used to sign comments and closures.)

1. Read `$TD_REGISTRY/SERVICES.md` (local clone first, else `gh api`). Find the row where the slug matches `<owner>/<name>`. Use its Friendly column.
2. Fall back to the first H1 heading in `.td/PROJECT.md`.
3. Final fallback: the directory basename.

Hold as `<receiver-name>` for the run.

# Step 3 — Group and sort

Bucket issues by `issueType.name`. Process buckets in this order (highest leverage first):

1. **Epic** — big planning items, often with sub-issues. Surface progress prominently.
2. **Bug** — broken things, usually want urgent attention.
3. **Feature** — scoped new work.
4. **Task** — concrete actionable items.
5. **Idea** — exploratory, low urgency.
6. **(untyped)** — issues without a type (pre-Issue-Type era or never assigned). Surface last.

Within each bucket, sort by `updatedAt` descending.

# Step 4 — Print the shape

Before walking individual issues, print a compact summary:

```
N total open. Grouped:
  Epic    (X)   <list of #N titles, one-line each, with [X/Y sub-issues] if any>
  Bug     (X)   <list>
  Feature (X)   <list>
  Task    (X)   <list>
  Idea    (X)   <list>
  (untyped) (X) <list>
```

Skip buckets that are empty.

# Step 5 — For each issue (one at a time), surface

Walk the buckets in priority order. For each issue:

**Header:**
```
#<N>  <title>
  Type: <Epic|Bug|Feature|Task|Idea|untyped>  from: <source-project>  opened <YYYY-MM-DD>
  <if Epic with sub-issues: [<completed>/<total> sub-issues closed, <percentCompleted>%]>
```

- Parse `<source-project>` from the `**From:** <name>` marker at the top of the body. If absent, label `(unmarked)`.

**Body:** print the issue body verbatim.

**Comments:** fetch via the same GraphQL query (extend it to include `comments(last: 20) { nodes { author { login } body createdAt } }`) OR fall back to `gh issue view <N> --comments` for simplicity. Show all comments inline:
```
[YYYY-MM-DD] <author or parsed source-project>: <comment body>
```

**Related commits:** `git log --grep="#<N>" --oneline -10`. Surface any.

**For Epics:** also surface sub-issues — query separately or extract from the GraphQL response (add `subIssues(first: 20) { nodes { number title state issueType { name } repository { nameWithOwner } } }` to the query). List each sub-issue as `  └─ <repo>#<N> [open|closed] <title>`.

**Recommendation** (one line, type-aware):

- **Epic** at 100% sub-issues closed → "All sub-issues closed — close the parent?"
- **Epic** older than 30 days at 0% → "Stale — still pursuing?"
- **Bug/Feature/Task** with commits referencing `#<N>` that look like a fix → "Looks resolved — close?"
- Most recent comment from another project (parsed via `From:` or author ≠ this project) → "Awaiting reply — comment?"
- **Idea** older than 60 days, untouched → "Stale idea — close?"
- Otherwise → "Pending — leave open?"

# Step 6 — Walk per issue (one at a time, apply before moving on)

For each issue, wait for the user to say one of: `close` / `comment` / `skip` / freeform.

**On `close`:**
1. Ask "Closing comment? (yes / no)". Wait.
2. If yes: draft a short closing comment (one sentence ideally, two max), append `— <receiver-name>`, confirm.
3. Run:
   - With comment: `gh issue close <N> --comment "<drafted text>"`
   - Without: `gh issue close <N>`

**On `comment`:**
1. Draft based on discussion + user intent (ask for the gist if not obvious), append `— <receiver-name>`, confirm.
2. Run: `gh issue comment <N> --body "<drafted text>"`

**On `skip`:** continue.

**On freeform / "create a new issue":** the user can ask to file a new issue mid-walk — handle conversationally (resolve type, dedupe check, GraphQL create), then resume the walk where it was.

Apply each action *before* moving to the next issue. Don't batch.

# Step 7 — Summary

```
Inbox reviewed: <total> issues. <closed> closed. <commented> commented on. <skipped> left open.
```

# Rules

- **Repo-scoped only.** Never widen to all repos here — separate explicit trigger ("all repos") per `CLAUDE.md § Cross-repo`.
- **Always sign comments and closures** with `— <receiver-name>` (project-soul rule). Never address GH usernames in cross-repo prose.
- **Never auto-close, never auto-post.** Always show drafted text and confirm.
- **One issue at a time.** No batching.
- **Don't commit anything** — closures and comments are GH-side only.
- **GraphQL header `sub_issues`** required for the `subIssuesSummary` field while the feature is in preview. The `gh api graphql` call includes it inline.
- **If GraphQL errors** (rate limit, auth, schema drift on the preview field), surface the error and stop. Fall back to `gh issue list --json` for a degraded-mode listing without type grouping if the user insists on continuing.
- **Outbound issues** (filed by this project into others) are out of scope here. Future concern.
