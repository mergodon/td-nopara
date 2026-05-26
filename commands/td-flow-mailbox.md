---
description: Unified cross-repo work check — gathers inbound issues (filed INTO this repo, grouped by Issue Type) and outbound issues (filed FROM this repo into others, scoped by .td/PROJECT.md § Cross-repo and identified by the **From:** body marker), presents both directions as one batched digest with a recommended action each, and executes your decisions in a single pass. Replaces /td-inbox + /td-outbox.
---

You are running the unified mailbox check. The job: gather every cross-repo work item — both directions — present them as ONE digest with a recommended action each, take the user's decisions in a single pass, then execute the batch. No walking issues one at a time.

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

Also read `.td/STATE.md` and parse the `Topic:` line. If it's not `idle` and matches a `Closes #<N>` reference in the Resume note (or a `.td/work/<slug>.md` exists referencing an inbound issue), hold the matched issue number as `<active-issue>`. It surfaces as an `[● ACTIVE]` marker in the digest header — so the very first thing /td-flow-mailbox tells you is what's already in flight before you start picking up new things.

# Step 2 — Inbound query (open issues in this repo)

```
gh api graphql -H "GraphQL-Features: sub_issues" -f query='
  query($owner: String!, $name: String!) {
    repository(owner: $owner, name: $name) {
      issues(first: 50, states: OPEN, orderBy: {field: UPDATED_AT, direction: DESC}) {
        nodes {
          id number title body url createdAt updatedAt
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

This gives the inbound list directly. Epics with cross-repo sub-issues show their children inline (for planning context).

**Sub-issue rollup lag.** An Epic's `subIssuesSummary` lags a child issue's close — observed stale for up to ~1 min before the count catches up. If an Epic shows progress that looks one behind a just-closed child, it's lag, not a miscount; it corrects on the next run. (Same eventual-consistency caveat as the search-index lag in Step 4.)

Then, for each inbound issue, gather related commits — `git log --grep="#<N>" --oneline -10`. Hold the results: they drive the digest recommendation ("looks resolved — close?") and render in the `show N` drill-down.

# Step 3 — Read the cross-repo registry

Read `.td/PROJECT.md § Cross-repo`. It's the human-curated list of repos this project files into (slug + optional one-line context per repo).

- **Section missing or empty:** the project hasn't declared any cross-repo relationships. Outbound is empty. Skip Step 4; in the digest, say `Outbound: no cross-repo registry declared in PROJECT.md § Cross-repo`.
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

Keep only matching issues. That set IS the outbound list. If no matches: outbound is empty; note it in the digest.

**Search index lag.** GitHub's search index lags newly-created issues by a few seconds — observed up to ~5s in testing. A filing made *right before* `/td-flow-mailbox` may not appear in this run; it'll show on the next. If the user expects something to appear and it doesn't, suggest re-running after a few seconds, or fetch the specific issue directly via `repository.issue(number: N)`.

Also fetch closed-recently candidates for the "Recently closed (last 30 days)" bucket — re-run the search with `state:closed` and filter by `closedAt > now - 30d`. (Optional — adds one query; skip if the user finds it noisy.)

# Step 5 — Build the digest

Bucket each direction, then print everything as ONE numbered list.

**Inbound** — bucket by `issueType.name`, in this order (highest leverage first), `updatedAt` descending within each:
1. **Epic** — surface sub-issue progress prominently
2. **Bug**
3. **Task**
4. **Idea**
5. **(untyped)**

**Exclude `Snapshot`-type issues from this bucket** — they're personal lifecycle markers (in-flight pieces you paused), not work requests to act on. They get their own dedicated section below the inbound list, with their own actions (resume/delete) and are **not numbered in the main decision list**.

**Outbound** — bucket the cross-repo matches by intent state. Determine "us" vs "them" by parsed sign-off in comment text (a comment ending with `— <project-name>` is ours).
- **Awaiting reply** — `state: OPEN`, last comment from someone OTHER than us (or no comments yet).
- **Pending action** — `state: OPEN`, last comment is from us (they need to act).
- **Recently closed** — `state: CLOSED`, `closedAt` within last 30 days (only if you ran the optional closed-state query).

**Recommendation per item** (one line — first match wins).

Inbound:
- **N == `<active-issue>`** → "your current Topic — comment progress, or close if shipped?"
- **Epic** — report-only, never a "start it" nudge. An Epic is a planning surface; its open children are the actionable work. First match wins:
  - 100% sub-issues closed → "all children done — close the parent?"
  - older than 30 days at 0% → "stale plan — still pursuing?"
  - otherwise → "planning surface — <completed>/<total> children done; pick it up via the open children."
- **Bug/Task** with commits referencing `#<N>` that look like a fix → "looks resolved — close?"
- Most recent comment from another project → "awaiting reply — comment?"
- **Idea** older than 60 days, untouched → "stale idea — close?"
- **Bug/Task** with no commits referencing it and not active → "concrete piece — start it, or leave open?"
- Otherwise → "pending — leave open?"

Outbound:
- **Awaiting reply, recently created (< 14 days)** → "they haven't had time yet — leave?"
- **Awaiting reply, 14–60 days, no movement** → "long-pending — gentle ping?"
- **Awaiting reply, > 60 days, no movement** → "stale — close as not_planned?"
- **Pending action, ball with them** → "acknowledge or check back later?"
- **Recently closed, last comment theirs** → "verify the resolution matched your ask?"
- **Recently closed, you commented after close** → "already verified — skip."

Number items continuously across inbound + outbound (so "close 3" is unambiguous). Snapshots use their issue number directly, not a list position. Print:

```
Mailbox: <I> inbound + <M> outbound + <S> snapshots
<if <active-issue> set: "  ● Active: #<N> <title> (STATE.Topic)">

📥 Inbound (this repo) — by Issue Type
  1. #<N>  <Type>  <title>   from <source-project>   <age>  <if Epic: [<c>/<t> closed, <pct>%]>
         → <recommendation>
  2. …

📤 Outbound (cross-repo — scoped by .td/PROJECT.md § Cross-repo) — by intent state
  3. <repo>#<N>  <Type>  <title>   <bucket>   <age>
         → <recommendation>
  4. …

🔖 Snapshots (your paused in-flight pieces — not work requests)
  • #<N>  [Snapshot] <slug>   branch: snapshot/<slug>   paused <age>
         resume: cd <repo-path> && git checkout snapshot/<slug> && claude --resume <session-id>
         <if >30d untouched: "→ stale — delete?">
  • …

Reply with decisions in one line — e.g. "close 1 3, comment 2, promote 4,
ping 5, verify 6, resume 18, delete 22, skip rest". Snapshots take
`resume <N>` / `delete <N>` / leave (default). `show N` expands any item.
```

`<source-project>` comes from the `**From:** <name>` marker at the top of the inbound body; if absent, label `(unmarked)`.

If both directions and snapshots are empty:
```
Mailbox empty. ✓
  Inbound:   no open issues in this repo
  Outbound:  no cross-repo filings found (scope: <list connected repos>)
  Snapshots: no paused in-flight pieces
```
And exit.

# Step 6 — One decision point

Wait for the user's single reply. They reference item numbers and an action each. Valid actions:
- **Inbound:** `start` / `comment` / `close` / `promote` / `skip`
- **Outbound:** `comment` / `ping` / `verify` / `close` / `reopen` / `acknowledge` / `skip`
- **Snapshots:** `resume <N>` / `delete <N>` / leave (default — no-op if not named)
- **`show N`** — expand item N before deciding (Step 7), then the digest stands again.
- **freeform** — e.g. "create a new issue for X", or a per-item instruction. Handle conversationally — for a new cross-repo filing, follow `CLAUDE.md`'s cross-repo routing rule (declare the target in `PROJECT.md § Cross-repo` if new, body opens `**From:** <project-name>`) — then return to the digest.

Anything not named is treated as `skip`. Don't walk the items one at a time — one digest, one reply, then Step 8.

# Step 7 — Drill-down on `show N`

When the user asks to see an item in full, render it verbose, then return to the digest (the decision point still stands — re-state "your decisions?").

**Header:**
```
#<N> (or <repo>#<N>)  <title>
  Type: <…>  from: <source-project>  opened <YYYY-MM-DD>  [<state> if outbound]
  <if N == <active-issue>: "  ● ACTIVE — your current STATE.Topic">
  <if Epic with sub-issues: [<completed>/<total> closed, <pct>%]>
```

**Body:** print verbatim.
**Comments:** print inline from the fetched comments — `[YYYY-MM-DD] <author or parsed source-project>: <body>`. Mark ours (`— <project-name>` sign-off) vs theirs.
**Related commits** (inbound): the `git log --grep` results from Step 2.
**Sub-issues** (Epics): list each `└─ <repo>#<N> [open|closed] <title>`.

The user can `show` several items before giving decisions. No action is taken in this step.

# Step 8 — Execute the batch

Process the user's decisions as a batch, not a walk.

**1. Resolve all drafts first.** For every action that needs text — inbound `comment`, inbound `close`, outbound `comment`/`ping`, outbound `verify`, outbound `close` (a withdrawal note) — draft the text now, each signed `— <project-name>`. Every inbound `close` gets a short closing comment by default; to close an issue bare, the user `drop`s its comment in the confirm below. Show ALL drafts together and confirm once:

```
About to post:
  #2  comment:  "<draft>"
  #5  ping:     "<draft>"
  #6  verify:   "<draft>"
  rgb-web#22 close: "<withdrawal draft>"
Post all? (yes / edit N / drop N)
```

**2. Run the state-changing actions** once confirmed:
- **Inbound `close`** — `gh issue close <N> --comment "<text>"` (or `gh issue close <N>` if its drafted comment was dropped).
- **Inbound `comment`** — `gh issue comment <N> --body "<text>"`.
- **Inbound `promote`** — re-type an `Idea` to `Task`. Resolve the `Task` Issue Type ID (org `issueTypes` query — same as `/td-flow-park` Step 2), then `gh api graphql -f query='mutation($id: ID!, $t: ID!) { updateIssue(input: {id: $id, issueTypeId: $t}) { issue { number } } }' -F id=<issue node id> -F t=<Task type ID>`. The issue node `id` comes from the Step 2 query. Only meaningful on an `Idea` — if the target isn't one, say so and skip it.
- **Outbound `comment` / `ping`** — `gh issue comment <N> --repo <slug> --body "<text>"`.
- **Outbound `verify`** — add a closing-verification comment (`Confirmed — works as expected. — <project-name>`), or skip the comment if the user only wanted a visual check. No state change unless asked.
- **Outbound `close`** (withdrawing our own stale ask) — `gh issue close <N> --repo <slug> --reason "not planned" --comment "<withdrawal text>"`. The `not planned` reason tells GitHub (and any parent Epic's progress bar) this wasn't an abandoned-because-done close. Never close without a comment — zero context for the receiver is rude.
- **Outbound `reopen`** — destructive (reopens someone else's issue, or reactivates a stale one we closed): confirm a second time, then `gh issue reopen <N> --repo <slug>` plus a comment explaining why.
- **Snapshot `resume <N>`** — parse the snapshot's slug from the issue title (`[Snapshot] <slug>`). Run `git checkout snapshot/<slug>`. Print the full resume line from the issue body (`cd <repo-path> && git checkout snapshot/<slug> && claude --resume <session-id>`) so the user can spawn the original conversation back in a new terminal. Don't try to switch the current Claude session — `--resume` is for a fresh `claude` invocation, not the live one.
- **Snapshot `delete <N>`** — close the issue as "not planned" with a one-line comment (`Snapshot abandoned — branch deleted. — <project-name>`), then delete the branch local + remote: `git branch -D snapshot/<slug>` and `git push origin :snapshot/<slug>`. Confirm once before the branch delete (destructive). If the branch is already gone locally, skip the local delete and proceed to remote.
- **`acknowledge` / `skip`** — no-op.

**3. Handle `start` last** (at most one per batch — a Topic is singular). If the user said `start` on an **Epic**, don't activate it — an Epic isn't a single piece of work; offer to `start` one of its open child issues instead. If `start` targets an **Idea**, promote it to `Task` first (per the `promote` handler above) — starting work commits to it, so it's no longer exploration — then activate the now-`Task`. To activate an issue:

1. Derive a kebab-case `<slug>` from the title (3–5 words, lowercase ASCII). Use it; the user can rename later if it doesn't fit.
2. Infer multi-step vs single-piece from the issue body — multi-paragraph or checklist body → multi-step (create `.td/work/<slug>.md`); short one-edit body → single-piece (STATE Resume note only).
3. Update `.td/STATE.md`:
   - `Topic: <slug>`
   - `Phase: planning` (multi-step) or `working` (single-piece)
   - `Last: YYYY-MM-DD — picked up #<N> from mailbox`
   - Append/replace Resume note line: `Active piece: #<N> <title> — Closes #<N> on ship.`
4. If multi-step: create `.td/work/<slug>.md` with a short header (`# <title>`, link to `#<N>`, the issue body folded in as initial context).
5. Tell the user: `STATE.Topic is now <slug> (<multi-step|single-piece>). First commit on this piece must include "Closes #<N>" so GitHub auto-closes the issue when it ships.`

# Step 9 — Single end-summary

```
Mailbox walked: <T> reviewed total.
  Inbound:   <St> started, <C> closed, <Co> commented on, <S> skipped.
  Outbound:  <Co> commented/pinged, <V> verified, <Cs> closed-as-stale, <R> reopened, <S> skipped.
  Snapshots: <Re> resumed, <De> deleted, <Le> left.
<if a `start` happened: "  ● STATE.Topic now <slug> (#<N>)">
<if a `resume` happened: "  ● Now on snapshot/<slug> — paste the `claude --resume` line in a new terminal to spawn the original session.">
```

# Rules

- **Single command for both directions.** Don't suggest a second command for the other side — this IS both.
- **One digest, one decision point.** Gather everything, present it once, take decisions in a single pass, execute the batch. No issue-by-issue walking.
- **Outbound scope is the cross-repo registry** in `.td/PROJECT.md § Cross-repo`. Filings into repos not declared there won't show. By design — forces honesty about cross-repo relationships. If you find yourself wanting to widen, the right move is updating PROJECT.md, not bypassing the scope.
- **The `**From:** <project>` body marker is canonical** — the only identifier of "this is ours" on the outbound side, and the human-readable source signal on the inbound side. Every cross-repo filing gets it.
- **Sub-issue linkage stays for real planning Epics.** Epics with cross-repo children show progress in the digest. That's a legit GitHub-native use case. One-off CRs don't need it.
- **Epics are reported, not actioned.** An Epic is a high-level planning surface — the actionable work is its child Bug/Task issues. `/td-flow-mailbox` shows an Epic's state and sub-issue progress for planning context; it never nudges `start` on a parent Epic. (Same stance as `/td-flow-close` Step 2, which gates a close only on Bug/Task.)
- **Always sign comments and closures with `— <project-name>`** (project-soul rule). Never address GH usernames in cross-repo prose.
- **Never auto-close, never auto-post.** All drafted text is shown and confirmed once before the batch runs.
- **GraphQL preview header** `GraphQL-Features: sub_issues` required for `subIssuesSummary` + `subIssues`. Inline on each query that uses them.
- **If GraphQL errors** (rate limit, auth, schema drift): surface the error and stop. Fall back to `gh issue list --json` for a degraded-mode inbound listing if the user insists.
- **Cross-org outbound is unsupported** by sub-issue linkage, but the From-marker search still finds it. So a cross-org CR filed with the marker WILL show in outbound if its repo is declared in PROJECT.md § Cross-repo. (Sub-issue parent linkage just won't work for that one.)
- **Snapshots are a third bucket, never numbered with inbound/outbound.** They're personal lifecycle markers (paused in-flight pieces from `/td-flow-snapshot`), not work to act on. Default behavior is leave-alone — only `resume <N>` or `delete <N>` change anything. The 30-day stale nudge is informational; the user decides.
- **Snapshot `delete` is destructive.** Branches are real work even when paused. Confirm once before the local + remote branch delete. If the snapshot's work shipped via a normal merge to main (with `Closes #<N>`), the issue auto-closed and won't appear here — no manual cleanup needed.
