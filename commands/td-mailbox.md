---
description: Unified cross-repo work check — walks inbound issues (filed INTO this repo, grouped by Issue Type) and outbound issues (filed FROM this repo into others, scoped by .td/PROJECT.md § Cross-repo and identified by the **From:** body marker), one item at a time. Replaces /td-inbox + /td-outbox.
---

You are running the unified mailbox check. The job: walk every cross-repo work item — both directions — and help the user decide one issue at a time. Inbound first (highest leverage), then outbound.

The outbound side uses **minimum-dependency** mechanics: a human-curated list of connected projects (`.td/PROJECT.md § Cross-repo`) bounds the search, and the canonical `**From:** <project>` body marker identifies our own filings. No tracker Epic. No sub-issue linkage required for one-off cross-repo CRs. Epics with cross-repo sub-issues (real planning surface) keep their sub-issue linkage — that's a separate, legitimate use case.

# Step 0 — Verify we're in a td-flow project with GH access

- Confirm `./.td/` exists. If missing: abort, "Not a td-flow project."
- Verify `gh` is authenticated and has a remote: `gh repo view --json name,owner 2>/dev/null`. If it fails: abort, "No GitHub remote or `gh` not authenticated."
- Capture the slug as `<owner>/<name>` for the queries below.

# Step 1 — Identify this project's friendly name + active Topic

Friendly name — used to sign comments and closures, and as the body marker value to filter on:

1. First H1 heading in `.td/PROJECT.md`.
2. Fall back to directory basename.

Hold as `<project-name>` for the run.

Also read `.td/STATE.md` and parse the `Topic:` line. If it's not `idle` and matches a `Closes #<N>` reference in the Resume note (or a `.td/work/<slug>.md` exists referencing an inbound issue), hold the matched issue number as `<active-issue>`. Surfaces as an `[● ACTIVE]` marker in the walk and the summary header — so the very first thing /td-mailbox tells you is what's already in flight before you start picking up new things.

# Step 2 — Inbound query (open issues in this repo)

```
gh api graphql -H "GraphQL-Features: sub_issues" -f query='
  query($owner: String!, $name: String!) {
    repository(owner: $owner, name: $name) {
      issues(first: 50, states: OPEN, orderBy: {field: UPDATED_AT, direction: DESC}) {
        nodes {
          number title body url createdAt updatedAt
          author { login }
          issueType { name }
          subIssuesSummary { total completed percentCompleted }
          comments(last: 20) { nodes { author { login } body createdAt } }
          subIssues(first: 20) {
            nodes {
              number title state url
              repository { nameWithOwner }
              issueType { name }
            }
          }
        }
      }
    }
  }' -F owner=<owner> -F name=<name>
```

This gives the inbound list directly. Epics with cross-repo sub-issues show their children inline (for planning context during the walk).

# Step 3 — Read the cross-repo registry

Read `.td/PROJECT.md § Cross-repo`. It's the human-curated list of repos this project files into (slug + optional one-line context per repo).

- **Section missing or empty:** the project hasn't declared any cross-repo relationships. Outbound is empty. Skip Step 4; in the summary, say `Outbound: no cross-repo registry declared in PROJECT.md § Cross-repo`.
- **Section present:** parse out the GH slugs (e.g., `mergodon/rgb-ggbuddy`, …). Hold as `<connected-repos>`.

The cross-repo registry IS the scope of outbound. Filings into repos not on this list won't show up — by design. If the project files into a new repo, declaring it here is the onboarding step (one-line edit in PROJECT.md).

# Step 4 — Outbound query (scoped to connected repos, filtered by From-marker)

Build a search query bounded by the connected repos:

```
q="repo:<connected-repo-1> repo:<connected-repo-2> ... \"<project-name>\" type:issue state:open"
```

Run it:

```
gh api graphql -f query='
  query($q: String!) {
    search(query: $q, type: ISSUE, first: 100) {
      nodes {
        ... on Issue {
          number title url state body createdAt updatedAt closedAt
          author { login }
          repository { nameWithOwner }
          issueType { name }
          comments(last: 5) { nodes { author { login } body createdAt } }
        }
      }
    }
  }' -F q="<bounded-query-string>"
```

(Use `gh api graphql` directly — `gh search issues` mishandles colons inside exact-phrase queries.)

For each result, an outbound match is any issue where:
- Body begins with `**From:** <project-name>\b` (canonical sender marker — excludes false-positive name matches in unrelated bodies).
- `repository.nameWithOwner` is one of the declared connected repos (the search already bounds this, but verify).

Keep only matching issues. That set IS the outbound list.

If no matches: outbound is empty; surface a one-line note in the summary.

**Search index lag.** GitHub's search index lags newly-created issues by a few seconds — observed up to ~5s in testing. A filing made *right before* `/td-mailbox` may not appear in this run; it'll show on the next. This is acceptable for the normal workflow (you don't usually run mailbox the moment after filing). If the user expects something to appear and it doesn't, suggest re-running after a few seconds, or fetch the specific issue directly via `repository.issue(number: N)`.

Also fetch closed-recently candidates if you want the "Recently closed (last 30 days)" bucket — re-run the search with `state:closed` and filter by `closedAt > now - 30d`. (Optional — adds one query; skip if the user finds it noisy.)

# Step 5 — Print the summary

**Inbound** — bucket by `issueType.name`, in this order (highest leverage first):
1. **Epic** — surface sub-issue progress prominently
2. **Bug**
3. **Task**
4. **Idea**
5. **(untyped)** — issues with no type

Within each bucket, sort by `updatedAt` descending.

**Outbound** — bucket the cross-repo matches by intent state. Determine "us" vs "them" by parsed sign-off in comment text (a comment ending with `— <project-name>` is ours).
- **Awaiting reply** — `state: OPEN`, last comment is from someone OTHER than us (or no comments yet).
- **Pending action** — `state: OPEN`, last comment is from us (they need to act).
- **Recently closed** — `state: CLOSED`, `closedAt` within last 30 days (only if you ran the optional closed-state query).

Print compact summary:

```
Mailbox: <N inbound> inbound + <M outbound> outbound
<if <active-issue> set: "  ● Active: #<N> <title> (STATE.Topic)">

📥 Inbound (this repo) — by Issue Type
  Epic    (X)   <#N — title [Y/Z sub-issues if any]>, ...
  Bug     (X)   <#N — title>, ...
  Task    (X)   ...
  Idea    (X)   ...
  (untyped) (X) ...

📤 Outbound (cross-repo, scoped by .td/PROJECT.md § Cross-repo) — by intent state
  Awaiting reply (X)  <repo#N — title>, ...
  Pending action (X)  ...
  Recently closed (X) ...
```

Skip empty buckets. If both directions are empty:
```
Mailbox empty. ✓
  Inbound:  no open issues in this repo
  Outbound: no cross-repo filings found (scope: <list connected repos>)
```
And exit.

# Step 6 — Walk inbound, one issue at a time

For each issue in priority order:

**Header:**
```
#<N>  <title>
  Type: <Epic|Bug|Task|Idea|untyped>  from: <source-project>  opened <YYYY-MM-DD>
  <if N == <active-issue>: "  ● ACTIVE — your current STATE.Topic">
  <if Epic with sub-issues: [<completed>/<total> sub-issues closed, <percentCompleted>%]>
```

Parse `<source-project>` from the `**From:** <name>` marker at the top of the body. If absent, label `(unmarked)`. The friendly name from the marker is what to use in conversation — don't bother resolving the slug unless you need to act.

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

**Recommendation** (one line, type-aware — first match wins):
- **N == <active-issue>** → "Your current Topic — comment with progress, or close if shipped?"
- **Epic** at 100% sub-issues closed → "All sub-issues closed — close the parent?"
- **Epic** older than 30 days at 0% → "Stale — still pursuing?"
- **Bug/Task** with commits referencing `#<N>` that look like a fix → "Looks resolved — close?"
- Most recent comment from another project → "Awaiting reply — comment?"
- **Idea** older than 60 days, untouched → "Stale idea — close?"
- **Bug/Task/Epic** with no commits referencing it and not active → "Concrete piece — start it, or leave open?"
- Otherwise → "Pending — leave open?"

**Wait for: `start` / `comment` / `close` / `skip` / freeform.**

**On `start`:** activate this issue as the current piece of work.
1. Propose a kebab-case `<slug>` derived from the title (3–5 words, lowercase ASCII). Confirm with user.
2. Ask: "Multi-step (planning surface → `.td/work/<slug>.md`) or single-piece (just STATE Resume note)?" If the issue body is shaped as one clear edit, default to single-piece.
3. Update `.td/STATE.md`:
   - `Topic: <slug>`
   - `Phase: planning` (multi-step) or `working` (single-piece)
   - `Last: YYYY-MM-DD — picked up #<N> from mailbox`
   - Append/replace Resume note line: `Active piece: #<N> <title> — Closes #<N> on ship.`
4. If multi-step: create `.td/work/<slug>.md` with a short header (`# <title>`, link to `#<N>`, the issue body folded in as initial context).
5. Tell user: `STATE.Topic is now <slug>. First commit on this piece must include "Closes #<N>" so GitHub auto-closes the issue when it ships.`
6. Ask: "Continue walking the mailbox, or break out to start working on #<N> now?" — wait. If `break out`, stop the walk and resume normal conversation. If `continue`, proceed.

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

**On freeform / "create a new issue":** handle conversationally (resolve type, dedupe check, GraphQL create; if cross-repo, follow the routing rule — declare in PROJECT.md § Cross-repo if new, file with `**From:** <project-name>` body marker, optionally `addSubIssue` to an Epic if it belongs to one), then resume the walk where it was.

Apply each action *before* moving on. Don't batch.

# Step 7 — Walk outbound, one issue at a time

In bucket order (Awaiting reply → Pending action → Recently closed). For each cross-repo issue:

**Header:**
```
<repo>#<N>  [<state>]  Type: <Bug|Task|Idea|Epic|untyped>
Title: <title>
Filed: <createdAt>  Updated: <updatedAt>
URL: <url>
```

**Body:** print verbatim.

**Recent comments:** print the last 5 from `comments.nodes` (already fetched in Step 4). Mark ours (`— <project-name>` sign-off) vs theirs.

**Recommendation** (one line — pick the first that fits):
- **Awaiting reply, recently created (< 14 days)** → "They haven't had time yet — leave?"
- **Awaiting reply, 14–60 days, no movement** → "Long-pending — gentle ping?"
- **Awaiting reply, > 60 days, no movement** → "Stale — close as not_planned?"
- **Pending action, ball is with them** → "Acknowledge or check back later?"
- **Recently closed, last comment is theirs** → "Verify the resolution matched your ask?"
- **Recently closed, you commented after close** → "Already verified — skip."

**Wait for: `status` / `comment` / `verify` / `close` / `reopen` / `skip` / `acknowledge` / freeform.**

**On `status`:** the "let me look closer before deciding" verb. For when you want a deeper read on where this stands before picking an action.
1. Re-fetch the issue (in case of staleness since the walk started): `gh issue view <N> --repo <slug> --json state,updatedAt,comments`.
2. Print:
   - Current state
   - Days since last activity (computed from `updatedAt`)
   - Who has the ball — `us` (last comment sign-off ends with `— <project-name>`) or `them`
   - Last 5 comments verbatim, marked `[us]` / `[them]` per sign-off
3. Suggest a next action one-liner — `chase` (gentle nudge comment), `update` (post status from our side), `verify`, `withdraw` (close as stale), or `leave`.
4. Re-prompt the same menu (`status / comment / verify / close / reopen / skip`) — user picks. `chase` and `update` route to `comment` with appropriate drafted text; `withdraw` routes to `close` (not_planned reason).

**On `comment`:** draft based on discussion + user intent, append `— <project-name>`, confirm, then `gh issue comment <N> --repo <slug> --body "<text>"`.

**On `verify`:** add a closing-verification comment (`Confirmed — works as expected. — <project-name>`) OR skip if the user just wants visual confirmation. No state change unless asked.

**On `close`:** for our own stale outbound — we're withdrawing the ask. Draft a short comment explaining why (e.g., "Withdrawing — no longer needed; superseded by X. — <project-name>"), confirm, then close with `not planned` reason:
```
gh issue close <N> --repo <slug> --reason "not planned" --comment "<drafted text>"
```
The `not planned` reason tells GitHub (and any parent Epic's progress bar, if this was Epic-attached) this wasn't an abandoned-because-done close. Don't use `close` without a comment — leaving zero context for the receiver is rude.

**On `reopen`:** confirm twice (destructive — reopens someone else's issue, or reactivates a stale one we closed). `gh issue reopen <N> --repo <slug>`. Add a comment explaining why.

**On `skip` / `acknowledge`:** continue.

# Step 8 — Single end-summary

```
Mailbox walked: <T> reviewed total.
  Inbound:  <St> started, <C> closed, <Co> commented on, <S> skipped.
  Outbound: <Sc> status-checked, <Co> commented on, <V> verified, <Cs> closed-as-stale, <R> reopened, <S> skipped.
<if walk ended early via `break out`: "  (walk broken out at #<N> — STATE.Topic now <slug>)">
```

# Rules

- **Single command for both directions.** Don't suggest a second command for the other side — this IS both.
- **Outbound scope is the cross-repo registry** in `.td/PROJECT.md § Cross-repo`. Filings into repos not declared there won't show. By design — forces honesty about cross-repo relationships. If you find yourself wanting to widen, the right move is updating PROJECT.md, not bypassing the scope.
- **The `**From:** <project>` body marker is canonical** — it's the only identifier of "this is ours" on the outbound side, and it's the human-readable source signal on the inbound side. Every cross-repo filing gets it.
- **Sub-issue linkage stays for real planning Epics.** Epics with cross-repo children show progress in the inbound walk. That's a legit GitHub-native use case. One-off CRs don't need it.
- **Always sign comments and closures with `— <project-name>`** (project-soul rule). Never address GH usernames in cross-repo prose.
- **Never auto-close, never auto-post.** Always show drafted text and confirm.
- **One issue at a time.** No batching.
- **GraphQL preview header** `GraphQL-Features: sub_issues` required for `subIssuesSummary` + `subIssues`. Inline on each query that uses them.
- **If GraphQL errors** (rate limit, auth, schema drift): surface the error and stop. Fall back to `gh issue list --json` for a degraded-mode inbound listing if the user insists.
- **Cross-org outbound is unsupported** by sub-issue linkage, but the From-marker search still finds it. So a cross-org CR filed with the marker WILL show in outbound if its repo is declared in PROJECT.md § Cross-repo. (Sub-issue parent linkage just won't work for that one.)
