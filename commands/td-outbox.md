---
description: Walk issues this project filed into other repos (cross-repo outbox view). Searches org-wide via the **From:** marker and surfaces current state + recent activity. Complement to /td-inbox.
---

You are walking the outbound side of this project's cross-repo work — issues filed FROM this project INTO other repos. The mechanism is the `**From:** <project>` marker in issue bodies; we search org-wide for that marker and show current state + recent activity.

This is the complement to `/td-inbox` (which is repo-scoped, inbound only — the inverse direction).

# Step 0 — Verify

- Confirm `./.td/` exists. If missing, abort: "Not a td-flow project."
- Verify `gh` is authenticated.
- Capture `<owner>/<name>` for the current repo.

# Step 1 — Determine this project's friendly name

Same procedure as `/td-inbox`:

1. Read `$TD_REGISTRY/SERVICES.md` (local clone first, else `gh api`). Find the row matching this repo's slug. Use its Friendly column.
2. Fall back to the first H1 heading in `.td/PROJECT.md`.
3. Final fallback: directory basename.

Hold as `<sender-name>`. This is the marker value to search for.

# Step 2 — Query org-wide via GraphQL search

GitHub's `gh search issues` mishandles colons inside exact-phrase queries; use GraphQL directly:

```
gh api graphql -f query='
  query($q: String!) {
    search(query: $q, type: ISSUE, first: 100) {
      issueCount
      nodes {
        ... on Issue {
          number
          title
          body
          state
          url
          createdAt
          updatedAt
          author { login }
          repository { nameWithOwner }
          issueType { name }
          comments(last: 5) {
            nodes { author { login } body createdAt }
          }
        }
      }
    }
  }' -F q="org:<owner> \"<sender-name>\" type:issue"
```

This does a loose org-wide search for the project name as an exact phrase. False positives possible — filtered in the next step.

# Step 3 — Filter by From: marker (client-side)

For each returned issue, check the body begins with the canonical marker:

```
^\*\*From:\*\* <sender-name>\b
```

(That's literal `**From:** <sender-name>` allowing extra whitespace or a newline after.) Keep only issues whose body matches.

Exclude issues whose `repository.nameWithOwner` equals this repo (those are inbound for us, not outbound).

After filtering, the remaining list is the canonical outbox: issues this project sent into other repos.

# Step 4 — Group by intent state

Bucket the filtered issues into three groups:

- **Awaiting reply** — `state: OPEN`, last comment is from someone OTHER than us, OR no comments yet (still untriaged by the receiver).
- **Pending action** — `state: OPEN`, last comment is from us (we already replied; they need to act).
- **Recently closed** — `state: CLOSED`, `closedAt` within last 30 days. Worth verifying the close matched intent.

Determine "us" vs "them" by author + by parsed sign-off in comment text. A comment ending with `— <sender-name>` is ours.

# Step 5 — Print summary

```
Outbox for <sender-name>: <total filtered> issues.
  Awaiting reply (X):   <list of repo#N — title>
  Pending action (Y):   <list of repo#N — title>
  Recently closed (Z):  <list of repo#N — title>
```

If `total filtered` is 0: `Outbox empty. ✓` and exit.

# Step 6 — Walk each issue (one at a time)

In bucket order (Awaiting reply first → Pending action → Recently closed), walk each issue. For each:

**Header:**
```
<repo>#<N>  [<state>]  Type: <Bug|Feature|Task|Idea|Epic|untyped>
Title: <title>
Filed: <createdAt>  Updated: <updatedAt>
URL: <url>
```

**Body:** print the issue body verbatim.

**Recent comments:** print the last 5 comments inline with `[YYYY-MM-DD] <author>: <body>` format. Mark ours (`— <sender-name>` sign-off) vs theirs.

**Recommendation** (one line):

- **Awaiting reply, > 14 days old, no movement** → "Long-pending — gentle ping?"
- **Awaiting reply, recently created** → "They haven't had time yet — leave?"
- **Pending action, ball is with them** → "Acknowledge or check back later?"
- **Recently closed, last comment is theirs** → "Verify the resolution matched your ask?"
- **Recently closed, you commented after close** → "Already verified — skip."

Wait for the user to say one of: `comment` / `verify` / `reopen` / `skip` / `acknowledge` / freeform.

**On `comment`:** draft a comment based on the discussion + the user's intent, append `— <sender-name>` sign-off, confirm, then `gh issue comment <N> --repo <slug> --body "<text>"`.

**On `verify`:** add a closing-verification comment ("Confirmed — works as expected. — <sender-name>") OR skip if the user just wants visual confirmation. No state change unless asked.

**On `reopen`:** confirm twice (destructive — reopens someone else's issue). `gh issue reopen <N> --repo <slug>`. Add a comment explaining why.

**On `skip` / `acknowledge`:** continue.

# Step 7 — Summary

```
Outbox walked: <T> reviewed. <C> commented on. <V> verified. <R> reopened. <S> skipped.
```

# Rules

- **Read-mostly by default.** This command writes only via `gh issue comment` and (rarely) `gh issue reopen` — both confirmed.
- **Cross-repo writes always sign as `— <sender-name>`** (project-soul rule).
- **30-day window for recently-closed** keeps the list manageable. Use `/td-outbox --all` to see older closures (or query the URL directly).
- **Don't widen the From-marker filter** to author or assignee — those are GH identity, which varies across machines. The body marker is the canonical identifier.
- **Don't auto-comment, don't auto-reopen, don't auto-close.** Always show drafted text and confirm.
- **If GraphQL search returns 0** but the user expects outbound issues exist, the From-marker might use different formatting (e.g., older issues without the marker, or filed by hand without the convention). Fall back to: ask the user for any known issue numbers to inspect manually.
- **The mergodon-org search is org-scoped.** Cross-org outbox (filing into someone else's org) isn't supported — those issues are out of scope for this command.
