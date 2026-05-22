---
description: Flush BACKLOG.md to GitHub Issues — consolidate related lines first, then create the issues in one batched pass. Standalone mid-session declutter — no /td-close ceremony.
---

You are flushing `.td/BACKLOG.md` to GitHub Issues. Read every line, consolidate lines that describe the same work, then present the whole proposed issue set as ONE digest — the user reviews and adjusts in a single pass, and you create the batch. No line-by-line interrogation, no blind 1:1 line→issue mapping.

This is the **canonical BACKLOG-flush procedure**. `/td-close` Step 3 runs it too — pointing here rather than re-describing it.

# Step 0 — Verify

- Confirm `./.td/BACKLOG.md` exists. If missing: abort, "No BACKLOG.md in this project."
- Confirm `gh` is authenticated with a remote: `gh repo view --json name,owner 2>/dev/null`. If fails: abort.
- Capture `<owner>/<name>` for GraphQL.

# Step 1 — Read BACKLOG

Read the BACKLOG.md file. Strip the markdown header + preamble + format-comment. Collect the bullet lines (entries shaped like `- YYYY-MM-DD — <description>` or just `- <description>`), numbered 1..L in BACKLOG order — those line numbers are how the digest (Step 5) and the user (`skip line <n>`) reference individual lines.

If the working list is empty (or only `(empty)` placeholder): tell the user `BACKLOG empty. ✓ Nothing to flush.` and exit.

# Step 2 — Cache Issue Type IDs (one query)

```
gh api graphql -f query='
  query($owner: String!) { organization(login: $owner) { issueTypes(first: 20) { nodes { id name } } } }' -F owner=<owner>
```

Use the `<owner>` captured in Step 0 — don't hardcode any org name. Parse the response. Build a map: `Idea` → `<id>`, `Task` → `<id>`, `Bug` → `<id>`, `Epic` → `<id>`. Hold for the run. Don't hard-code IDs — they vary across orgs and can rotate when an Issue Type is renamed.

(IDs may differ across orgs — always query fresh per run; cache is run-scoped, not session-scoped.)

# Step 3 — Determine this project's friendly name

Same procedure as `/td-mailbox` Step 1: first H1 heading in `.td/PROJECT.md`, fall back to directory basename. Hold as `<sender-name>` (used as the `**From:**` marker if the issue ends up being a self-park — distinguishes work this project parked vs work others filed).

# Step 4 — Consolidate

Before mapping anything to issues, look at all the lines **together** and group them. A BACKLOG accumulated across a work session is rarely a clean 1:1 list — it has duplicates, near-duplicates, and clusters of small things that are really one piece of work. Don't map blindly.

Cluster the lines into a proposed **issue set**:

- **Duplicate / near-duplicate lines** — the same item captured twice (often on different days) → one issue.
- **Facets of one piece** — several small lines that touch the same area or add up to one coherent chunk of work (e.g. three small cleanups in the same module) → one issue, the source lines folded into its body as a checklist.
- **A line that's actually several issues** — rare, but if one line bundles unrelated asks, propose splitting it.
- **Standalone lines** — most lines stay as their own issue.

Every merge must be **visible and vetoable** — the digest (Step 5) shows which source lines feed each proposed issue, so the user can unmerge anything grouped wrong. Never silently fold two lines together.

Hold the proposed issue set: each entry is `{ title, source-line(s), folded body }`.

# Step 5 — Suggest types, dedupe, build the digest

For each proposed issue:

1. **Suggest a Type** from the phrasing of its source line(s):

   | Trigger in the line | Suggested Type |
   |---|---|
   | "fix" / "broken" / "error" / "bug" | `Bug` |
   | "add" / "build" / "implement" / "support" / "rename" / "update" / "refactor" / "remove" / a clear concrete verb | `Task` |
   | "what if" / "maybe" / "idea:" / vague / unsure-of-scope / could-do | `Idea` |
   | "plan to" / "across multiple repos" / "epic:" / multi-piece | `Epic` |

   When the phrasing doesn't clearly fit a category, default to `Idea` — not `Task`. Vague *is* the signal: `Idea` is the right home for "not sure yet, browse later." A grouped issue (several lines folded in) usually reads as `Task` (one concrete chunk) or `Epic` (decomposes into sub-issues).

2. **Dedupe check** against existing open issues:
   ```
   gh issue list --state open --search "<2-3 key words>"
   ```
   If a similar issue exists, note it as a candidate in the digest — the user may want to comment on the existing one instead of creating a new issue.

Then print the **digest** — the whole proposed set as one lettered list:

```
BACKLOG: <L> lines → <I> proposed issues<if merges: " (<M> merges)">

  A. <Type>  <title>
       ← line(s) <n>[, <n>…]<if merged: "  (<one-line why merged>)">
       <if dedupe hit: "dedupe: similar to open #<N> <title> — comment there instead?">
  B. …

Reply to adjust — retype any ("B→Task"), unmerge ("split D"), merge more
("merge A+C"), drop, "ship A now", or "skip line <n>" to leave a line in
BACKLOG. Otherwise I create A–<last> as shown.
```

Skip the dedupe line for issues with no candidate. Skip the merge-count note if there were no merges.

# Step 6 — One decision point

Wait for the user's single reply. They may:

- **Accept as-is** ("go", "looks good", "create them") → proceed to Step 7 with the proposed set.
- **Adjust** — retype, unmerge, merge further, drop an issue, reword a title. Apply all adjustments to the proposed set. If the changes are large, re-print the corrected digest once for a final confirm; if small, just proceed.
- **Ship now** ("ship A now") — drop the flush; pick up that issue's work conversationally (the user is saying "this is the next piece"). The other proposed issues are NOT created — re-run `/td-park` when ready. Note this in the summary.
- **Skip a line** — that BACKLOG line stays; it's excluded from the created set.

Don't walk the issues one at a time. One digest, one reply, then act.

# Step 7 — Execute the batch

For every confirmed issue in the set, create it via GraphQL:

```
gh api graphql -H "GraphQL-Features: sub_issues" -f query='
  mutation($repoId: ID!, $title: String!, $body: String!, $typeId: ID!) {
    createIssue(input: { repositoryId: $repoId, title: $title, body: $body, issueTypeId: $typeId }) {
      issue { number url }
    }
  }' -F repoId=<repo-node-id> -F title="<title>" -F body="**From:** <sender-name>\n\n<folded body>" -F typeId="<cached type ID>"
```

Get `<repo-node-id>` once per run: `gh api graphql -f query='query { repository(owner: "<owner>", name: "<name>") { id } }'`.

The body opens with the `**From:** <sender-name>` marker, then the source content — for a merged issue, fold the source lines into a short checklist so nothing is lost.

For a "comment on existing #N instead" decision: `gh issue comment <N> --body "<context from the line(s)> — <sender-name>"`.

Print each result: `Created <repo>#<N> (Type: X)` or `Commented on #<N>`.

# Step 8 — Rewrite BACKLOG.md

After the batch, rewrite `.td/BACKLOG.md` containing only the lines the user marked "skip" (plus any lines a "ship now" interruption never reached). If every line was synced/dropped/shipped, the body becomes `(empty)` (preamble preserved).

# Step 9 — Tell the user

```
Flushed: <L> lines → <N> issues created<if merges: ", <M> merges">. <D> dropped. <C> commented onto existing. <S> shipped (rhythm started). <K> skipped (still in BACKLOG).
```

If `<S>` > 0: "You shipped <issue>; the rest of the set wasn't created. Run `/td-park` again when ready."

# Rules

- **Never auto-create.** The digest + one confirmation gates the whole batch. Within that, no per-issue interrogation.
- **Every merge is visible.** The digest always shows which source lines feed each issue. Never silently fold lines together — the user can unmerge anything.
- **Always include the `**From:**` marker** in the issue body — same project-soul rule from cross-repo. Even self-parks deserve the marker so the receiver (next session's `/td-mailbox` inbound walk) sees `From: <this-project>` and knows the source.
- **GraphQL mutation requires the `sub_issues` header** for issue creation while in preview (even though sub_issues aren't used here, the header keeps the API surface consistent across our commands).
- **Don't touch BACKLOG.md until the batch completes** — if the user interrupts (Ctrl-C, error), nothing is lost. Only the final rewrite mutates the file.
- **Don't commit BACKLOG.md** — `/td-park` is doc-hygiene; the user can commit the cleaned BACKLOG alongside other work when ready. (Exception: at `/td-close`, the close command commits.)
- **If a "ship now" interrupts**, set STATE.Topic to that issue + start the rhythm. The rest of the set waits for the next invocation.
- **Optional filter argument:** `/td-park ideas` flushes only Idea-shaped lines; `/td-park bugs` only Bug-shaped lines. Useful for triaging by type when BACKLOG is heavy.
