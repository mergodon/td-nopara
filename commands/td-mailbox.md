---
description: Unified cross-repo work check — walks inbound issues (filed INTO this repo, grouped by Issue Type) and outbound issues (filed FROM this repo into others, tracked via GitHub sub-issues), one item at a time. Replaces /td-inbox + /td-outbox.
---

You are running the unified mailbox check. The job: walk every cross-repo work item — both directions — and help the user decide one issue at a time. Inbound first (highest leverage), then outbound.

The outbound side uses **GitHub's native sub-issue mechanism**: every cross-repo issue filed FROM this project lives as a sub-issue of some parent in this repo (an existing Epic if it belongs to one, else the auto-created **outbound tracker Epic**). One aggregate query across all parents in this repo returns the canonical outbound set — no org-wide search, no From-marker filtering, exact membership.

# Step 0 — Verify we're in a td-flow project with GH access

- Confirm `./.td/` exists. If missing: abort, "Not a td-flow project."
- Verify `gh` is authenticated and has a remote: `gh repo view --json name,owner 2>/dev/null`. If it fails: abort, "No GitHub remote or `gh` not authenticated."
- Capture the slug as `<owner>/<name>` for use in the queries below.

# Step 1 — Identify this project's friendly name

Used to sign comments and closures, and as the body marker value when creating the outbound tracker.

1. Read `$TD_REGISTRY/SERVICES.md` (local clone first, else `gh api`). Find the row where the slug matches `<owner>/<name>`. Use its Friendly column.
2. Fall back to the first H1 heading in `.td/PROJECT.md`.
3. Final fallback: directory basename.

Hold as `<project-name>` for the run.

# Step 2 — Gather inbound + outbound (run both queries; can be parallel)

**Inbound** — every open issue in this repo, grouped later by Issue Type:

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
          comments(last: 20) { nodes { author { login } body createdAt } }
          subIssues(first: 20) {
            nodes {
              number
              title
              state
              url
              updatedAt
              author { login }
              repository { nameWithOwner }
              issueType { name }
              comments(last: 5) { nodes { author { login } body createdAt } }
            }
          }
        }
      }
    }
  }' -F owner=<owner> -F name=<name>
```

This single query gives us **both directions**:
- The `nodes` array IS the inbound list (after filtering — see Step 3).
- The `nodes[].subIssues.nodes` array, filtered to entries where `repository.nameWithOwner != "<owner>/<name>"`, IS the outbound list. Each cross-repo child knows its parent (the issue it was nested under).

# Step 3 — Filter the tracker out of the inbound view

The outbound tracker Epic itself lives in this repo. Skip it from the inbound walk by detecting the body sentinel:

```
<!-- td-mailbox-tracker -->
```

Any issue whose body contains that string is the tracker — exclude it from inbound bucketing. It's mailbox infrastructure, not real planning work. (It DOES contribute to the outbound list via its sub-issues — which is the point.)

# Step 4 — First-run backfill check (only if no tracker exists yet)

If no issue in the inbound query has the tracker sentinel AND outbound returns 0 cross-repo children: the project either has never filed cross-repo, or it filed cross-repo before adopting the tracker model. Run a quick backfill check:

```
gh api graphql -f query='
  query($q: String!) {
    search(query: $q, type: ISSUE, first: 100) {
      issueCount
      nodes { ... on Issue { number title url state body repository { nameWithOwner } } }
    }
  }' -F q="org:<owner> \"<project-name>\" type:issue"
```

Filter results client-side: keep only issues whose body begins with `**From:** <project-name>` AND `repository.nameWithOwner != "<owner>/<name>"`.

If matches exist: tell the user `Found N legacy cross-repo filings without parent linkage. Backfill these now? [y/n]`. On `y`:
1. Create the outbound tracker Epic (see Step 4a below) — capture its node id.
2. For each legacy issue: `addSubIssue` (Step 4b mutation shape) to attach it to the tracker.
3. Re-run the Step 2 inbound+outbound query to get the fresh aggregate.

If matches are zero: no backfill needed; proceed to Step 5.

## Step 4a — Create the outbound tracker Epic (only when about to attach the first child)

Don't create until needed (a child wants to be attached and there's no Epic to put it under). Mutation:

```
# Need: Epic type id, repo id
gh api graphql -f query='
  mutation($repoId: ID!, $typeId: ID!) {
    createIssue(input: {
      repositoryId: $repoId,
      title: "Outbound CRs (tracking)",
      issueTypeId: $typeId,
      body: "<!-- td-mailbox-tracker -->\n\nAuto-generated outbound CR tracker. Sub-issues here are cross-repo issues filed from this project that don'\''t belong to a specific Epic. /td-mailbox uses this to assemble the outbound view. Do not close."
    }) {
      issue { number title id url }
    }
  }' -F repoId=<repo-node-id> -F typeId=<Epic-type-id>
```

Get the Epic type id via:
```
gh api graphql -f query='query { organization(login: "<owner>") { issueTypes(first: 20) { nodes { id name } } } }'
```
(filter for `name == "Epic"`).

## Step 4b — Attach a sub-issue (used by backfill and by the conversational "file an issue for X" routing)

```
gh api graphql -H "GraphQL-Features: sub_issues" -f query='
  mutation($parent: ID!, $child: ID!) {
    addSubIssue(input: { issueId: $parent, subIssueId: $child }) {
      issue { subIssuesSummary { total completed percentCompleted } }
      subIssue { number title repository { nameWithOwner } }
    }
  }' -F parent=<tracker-or-epic-node-id> -F child=<child-issue-node-id>
```

Error handling:
- `NOT_FOUND` → the parent or child ID is wrong; surface and stop.
- `VALIDATION` with "duplicate" / "only one parent" → child is already attached somewhere; safe to ignore for backfill (already tracked).

# Step 5 — Bucket and print the summary

**Inbound** — bucket by `issueType.name`, in this order (highest leverage first):
1. **Epic** — surface sub-issue progress prominently
2. **Bug**
3. **Feature**
4. **Task**
5. **Idea**
6. **(untyped)** — issues with no type

Within each bucket, sort by `updatedAt` descending.

**Outbound** — bucket the cross-repo children by intent state. Determine "us" vs "them" by parsed sign-off in comment text (a comment ending with `— <project-name>` is ours).
- **Awaiting reply** — `state: OPEN`, last comment is from someone OTHER than us (or no comments yet).
- **Pending action** — `state: OPEN`, last comment is from us (they need to act).
- **Recently closed** — `state: CLOSED`, `closedAt` within last 30 days.

Print compact summary:

```
Mailbox: <N inbound> inbound + <M outbound> outbound

📥 Inbound (this repo) — by Issue Type
  Epic    (X)   <#N — title [Y/Z sub-issues if any]>, ...
  Bug     (X)   <#N — title>, ...
  Feature (X)   ...
  Task    (X)   ...
  Idea    (X)   ...
  (untyped) (X) ...

📤 Outbound (filed elsewhere) — by intent state
  Awaiting reply (X)  <repo#N — title>, ...
  Pending action (X)  ...
  Recently closed (X) ...
```

Skip buckets that are empty. If both directions are empty:
```
Mailbox empty. ✓
  Inbound:  no open issues in this repo
  Outbound: no cross-repo children under any parent
```
And exit.

# Step 6 — Walk inbound, one issue at a time

For each issue in priority order:

**Header:**
```
#<N>  <title>
  Type: <Epic|Bug|Feature|Task|Idea|untyped>  from: <source-project>  opened <YYYY-MM-DD>
  <if Epic with sub-issues: [<completed>/<total> sub-issues closed, <percentCompleted>%]>
```

Parse `<source-project>` from the `**From:** <name>` marker at the top of the body. If absent, label `(unmarked)`.

**Body:** print verbatim.

**Comments:** print inline from the comments already fetched in Step 2:
```
[YYYY-MM-DD] <author or parsed source-project>: <comment body>
```

**Related commits:** `git log --grep="#<N>" --oneline -10`. Surface any.

**For Epics:** also surface sub-issues (from `subIssues.nodes` in Step 2). List each as:
```
  └─ <repo>#<N> [open|closed] <title>
```

**Recommendation** (one line, type-aware):
- **Epic** at 100% sub-issues closed → "All sub-issues closed — close the parent?"
- **Epic** older than 30 days at 0% → "Stale — still pursuing?"
- **Bug/Feature/Task** with commits referencing `#<N>` that look like a fix → "Looks resolved — close?"
- Most recent comment from another project → "Awaiting reply — comment?"
- **Idea** older than 60 days, untouched → "Stale idea — close?"
- Otherwise → "Pending — leave open?"

**Wait for: `close` / `comment` / `skip` / freeform.**

**On `close`:**
1. Ask "Closing comment? (yes / no)". Wait.
2. If yes: draft a short closing comment, append `— <project-name>`, confirm.
3. Run:
   - With comment: `gh issue close <N> --comment "<text>"`
   - Without: `gh issue close <N>`

**On `comment`:**
1. Draft based on discussion + user intent (ask for the gist if not obvious), append `— <project-name>`, confirm.
2. Run: `gh issue comment <N> --body "<text>"`

**On `skip`:** continue.

**On freeform / "create a new issue":** handle conversationally (resolve type, dedupe check, GraphQL create; if cross-repo, also `addSubIssue` to the tracker per Step 4b), then resume the walk where it was.

Apply each action *before* moving on. Don't batch.

# Step 7 — Walk outbound, one issue at a time

In bucket order (Awaiting reply → Pending action → Recently closed). For each cross-repo child:

**Header:**
```
<repo>#<N>  [<state>]  Type: <Bug|Feature|Task|Idea|Epic|untyped>
Title: <title>
Filed: <createdAt>  Updated: <updatedAt>
URL: <url>
Tracked under: <parent issue from this repo, e.g. "#1 Outbound CRs (tracking)" or "#7 Auth refactor Epic">
```

**Body:** print verbatim.

**Recent comments:** print the last 5 from `comments.nodes` (already fetched in Step 2). Mark ours (`— <project-name>` sign-off) vs theirs.

**Recommendation** (one line):
- **Awaiting reply, > 14 days old, no movement** → "Long-pending — gentle ping?"
- **Awaiting reply, recently created** → "They haven't had time yet — leave?"
- **Pending action, ball is with them** → "Acknowledge or check back later?"
- **Recently closed, last comment is theirs** → "Verify the resolution matched your ask?"
- **Recently closed, you commented after close** → "Already verified — skip."

**Wait for: `comment` / `verify` / `reopen` / `skip` / `acknowledge` / freeform.**

**On `comment`:** draft based on discussion + user intent, append `— <project-name>`, confirm, then `gh issue comment <N> --repo <slug> --body "<text>"`.

**On `verify`:** add a closing-verification comment (`Confirmed — works as expected. — <project-name>`) OR skip if the user just wants visual confirmation. No state change unless asked.

**On `reopen`:** confirm twice (destructive — reopens someone else's issue). `gh issue reopen <N> --repo <slug>`. Add a comment explaining why.

**On `skip` / `acknowledge`:** continue.

# Step 8 — Single end-summary

```
Mailbox walked: <T> reviewed total.
  Inbound:  <C> closed, <Co> commented on, <S> skipped.
  Outbound: <Co> commented on, <V> verified, <R> reopened, <S> skipped.
```

No more cross-pointer line — both directions are in this one walk now.

# Rules

- **Single command for both directions.** Don't suggest the user run a second command for the other side — this IS both.
- **The `**From:** <project>` body marker stays on every new cross-repo filing.** Sub-issue parent linkage handles sender-side queries; the body marker is the human-readable identifier for `gh issue view` and any non-GraphQL surface, and gives the receiver a stable "from project X" signal regardless of which GH account opened the issue.
- **Always sign comments and closures with `— <project-name>`** (project-soul rule). Never address GH usernames in cross-repo prose.
- **Never auto-close, never auto-post.** Always show drafted text and confirm.
- **One issue at a time.** No batching.
- **GraphQL preview headers** required: `GraphQL-Features: sub_issues` for `subIssuesSummary`, `subIssues`, `parent`, `addSubIssue`. Inline in each query/mutation.
- **If GraphQL errors** (rate limit, auth, schema drift): surface the error and stop. Fall back to `gh issue list --json` for a degraded-mode inbound listing without type grouping if the user insists.
- **Cross-org outbound is unsupported** — sub-issue linkage is org-scoped. Same scope limit as before; not a regression.
- **Tracker filtering is by body sentinel**, not by title. Titles get edited.
- **Backfill happens on first-run only.** Subsequent runs detect the tracker exists (sentinel match) and skip Step 4.
