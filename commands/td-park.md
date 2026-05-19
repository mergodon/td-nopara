---
description: Flush BACKLOG.md to GitHub Issues (with appropriate type) line-by-line. Standalone mid-session declutter — no /td-close ceremony.
---

You are flushing `.td/BACKLOG.md` to GitHub Issues. Walk each line, suggest a type, dedupe against existing open issues, and either ship the work now, sync the line to GH with the chosen type, or drop it. After the walk, BACKLOG lines that were synced/dropped are removed; lines the user said "skip" on stay.

This command is the standalone version of the BACKLOG-flush step that also runs as part of `/td-close`. Use it mid-session when BACKLOG bloats and you want to declutter without the full close ceremony.

# Step 0 — Verify

- Confirm `./.td/BACKLOG.md` exists. If missing: abort, "No BACKLOG.md in this project."
- Confirm `gh` is authenticated with a remote: `gh repo view --json name,owner 2>/dev/null`. If fails: abort.
- Capture `<owner>/<name>` for GraphQL.

# Step 1 — Read BACKLOG

Read the BACKLOG.md file. Strip the markdown header + preamble + format-comment. Collect the bullet lines (entries shaped like `- YYYY-MM-DD — <description>` or just `- <description>`).

If the working list is empty (or only `(empty)` placeholder): tell the user `BACKLOG empty. ✓ Nothing to flush.` and exit.

# Step 2 — Cache Issue Type IDs (one query)

```
gh api graphql -f query='
  query { organization(login: "mergodon") { issueTypes(first: 20) { nodes { id name } } } }'
```

Parse the response. Build a map: `Idea` → `<id>`, `Task` → `<id>`, `Bug` → `<id>`, `Epic` → `<id>`. Hold for the run. Don't hard-code IDs — they vary across orgs and can rotate when an Issue Type is renamed.

(IDs may differ across orgs — always query fresh per run; cache is run-scoped, not session-scoped.)

# Step 3 — Determine this project's friendly name

Same procedure as `/td-mailbox` Step 1: first H1 heading in `.td/PROJECT.md`, fall back to directory basename. Hold as `<sender-name>` (used as the `**From:**` marker if the issue ends up being a self-park — distinguishes work this project parked vs work others filed).

# Step 4 — For each BACKLOG line, walk

For each line (in BACKLOG order):

1. **Print the line:** `Line N: <text>`

2. **Suggest a Type** based on the line's phrasing. Show the trigger phrase explicitly so the user can spot a bad suggestion.

   | Trigger in the line | Suggested Type |
   |---|---|
   | "fix" / "broken" / "error" / "bug" | `Bug` |
   | "add" / "build" / "implement" / "support" / "rename" / "update" / "refactor" / "remove" / a clear concrete verb | `Task` |
   | "what if" / "maybe" / "idea:" / vague / unsure-of-scope / could-do | `Idea` |
   | "plan to" / "across multiple repos" / "epic:" / multi-piece | `Epic` |

   **When the phrasing doesn't clearly fit a category, default to `Idea`** — not `Task`. Vague *is* the signal: `Idea` is the right home for "not sure yet, browse later." Don't force-fit a `Task` just because it's the most generic action type.

   Tell the user: `Suggested: Type: <X> (trigger: "<phrase from line>"). Accept? (or change to <other> / it's an Idea / it's an Epic / drop / fix it now)`

   Examples:
   - Line "remove unused imports in auth.ts" → trigger "remove", suggest `Task` (concrete verb + specific target).
   - Line "remove all the legacy stuff somehow" → vague hedge ("somehow"), suggest `Idea`.
   - Line "checkout 500s on iOS Safari only" → trigger "500s" matches "error", suggest `Bug`.
   - Line "maybe explore using SSE for live updates" → trigger "maybe explore", suggest `Idea`.

3. **Dedupe check.** Before creating, search open issues for similar content:
   ```
   gh issue list --state open --search "<2-3 key words from the line>"
   ```
   If results: show them as candidates, ask: "Looks similar to #<N> <title>. Update that one (add a comment) or create a new one?"
   
   If user picks "update": run `gh issue comment <N> --body "<additional context from the BACKLOG line> — <sender-name>"`, then continue.

4. **Apply the user's choice:**

   - **Ship now** → drop the slash command flow; pick up the work conversationally. (User is saying "this is the next piece" — start the rhythm on this line.)
   
   - **Sync to GH with Type X** → create the issue via GraphQL:
     ```
     gh api graphql -H "GraphQL-Features: sub_issues" -f query='
       mutation($repoId: ID!, $title: String!, $body: String!, $typeId: ID!) {
         createIssue(input: { repositoryId: $repoId, title: $title, body: $body, issueTypeId: $typeId }) {
           issue { number url }
         }
       }' -F repoId=<repo-node-id> -F title="<line text>" -F body="**From:** <sender-name>\n\n<line text + any context>" -F typeId="<cached type ID>"
     ```
     Get the `<repo-node-id>` once per run from `gh api graphql -f query='query { repository(owner: "<owner>", name: "<name>") { id } }'`.
     
     Print: `Created <repo>#<N> (Type: X)`.
     
     Remove the BACKLOG line from the working list.
   
   - **Drop** → ask "Sure? This deletes the line without preserving it." If confirmed, remove from working list. (If the user expresses hesitation, default to "sync as Idea" instead — softer than dropping.)
   
   - **Skip** → leave the line in BACKLOG (stays for next flush attempt).

# Step 5 — Rewrite BACKLOG.md

After the walk, rewrite `.td/BACKLOG.md` containing only the lines the user marked "skip." If all lines were synced/dropped/shipped, the body becomes `(empty)` (with the preamble preserved).

# Step 6 — Tell the user

```
Flushed: <total walked> lines. <N> synced to GH. <D> dropped. <S> shipped (rhythm started). <K> skipped (still in BACKLOG).
```

If `<S>` > 0 and the user shipped one mid-walk, surface a reminder: "You shipped <line>; remaining BACKLOG lines weren't walked. Run `/td-park` again when ready to continue, or commit-and-resume."

# Rules

- **Never auto-create.** Always confirm Type + dedupe candidate before the mutation.
- **Always include the `**From:**` marker** in the issue body — same project-soul rule from cross-repo. Even self-parks deserve the marker so the receiver (next session's `/td-inbox`) sees `From: <this-project>` and knows the source.
- **GraphQL mutation requires the `sub_issues` header** for issue creation while in preview (even though sub_issues aren't used here, the header keeps the API surface consistent across our commands).
- **Don't touch BACKLOG.md until the walk completes** — if the user interrupts mid-walk (Ctrl-C, error), nothing is lost. Only the final rewrite mutates the file.
- **Don't commit BACKLOG.md** — `/td-park` is doc-hygiene; the user can commit the cleaned BACKLOG alongside other work when ready. (Exception: at `/td-close`, the close command commits.)
- **If a "ship now" interrupts the walk**, set STATE.Topic to that line's content + start the rhythm. Other BACKLOG lines wait for next invocation.
- **Optional filter argument:** `/td-park ideas` walks only lines that match the Idea heuristic. `/td-park bugs` walks only Bug-shaped lines. Useful for triaging by type when BACKLOG is heavy.
