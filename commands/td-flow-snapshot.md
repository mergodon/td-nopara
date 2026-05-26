---
description: Snapshot the current in-flight piece — commit current state to a `snapshot/<slug>` branch, file a Snapshot-type GitHub issue with the resume command, reset STATE to idle. Use when pivoting (incident, other priority) or when stepping away mid-flight. Resume by checking out the branch and running the `claude --resume` line from the issue. Optional `<reason>` argument.
---

You are taking a snapshot of the current in-flight piece so that pivoting (incident, other priority work, stepping away for the day) loses nothing. The snapshot mechanic is **lean by design**: a branch (git-native state), a GitHub issue (visible tracker), and the literal `claude --resume <session-id>` command (Claude Code's native session resume). No bespoke save-state magic.

Optional argument: `/td-flow-snapshot <reason>` — short phrase recorded in the commit message and issue body. Defaults to `user-requested` (or `incident-pivot` when invoked by `/td-flow-incident`).

# Step 0 — Verify

- Confirm `./.td/` exists. If missing: abort, "Not a td-flow project."
- Confirm `$CLAUDE_CODE_SESSION_ID` is set. If missing: abort, "No Claude Code session ID in env — can't capture resume command."
- Verify `gh` is authenticated with a remote: `gh repo view --json name,owner 2>/dev/null`. Capture `<owner>/<name>`.
- Read `.td/STATE.md`. Parse `Topic:` line. **If `Topic == idle`: abort, "Nothing in flight to snapshot."**

# Step 1 — Resolve identifiers

**Topic slug** — `STATE.Topic` is normally already kebab-case. If it carries an `incident:` prefix (from `/td-flow-incident`'s mode marker), strip the prefix. Lowercase ASCII, replace any non-`[a-z0-9-]` with `-`. Hold as `<slug>`.

**Project friendly name** — same rule as `/td-flow-park` Step 3: first H1 in `.td/PROJECT.md`, fall back to directory basename. Hold as `<project-name>`.

**Original branch** — `git rev-parse --abbrev-ref HEAD`. Hold as `<original-branch>` (typically `main`; we'll return here after snapshot).

**Repo path** — `pwd`. Hold as `<repo-path>` (used in the resume command).

**Transcript path** — derive: `~/.claude/projects/$(pwd | tr '/' '-')/${CLAUDE_CODE_SESSION_ID}.jsonl`. Hold as `<transcript-path>`. Sanity check that the file exists; if not, still include the path in the issue body but note "(transcript file not found at snapshot time — Claude Code session may not have flushed yet)".

**Original STATE fields** — from `.td/STATE.md`, hold the current values of `Topic:`, `Phase:`, `Last:` lines as `<original-topic>`, `<original-phase>`, `<original-last>`. They're used in Step 6's issue body to freeze the STATE at the snapshot moment. Capture them **before** Step 7 rewrites STATE.

**Reason** — the optional argument, or `user-requested` if none.

# Step 2 — Cache Snapshot Issue Type ID

```
gh api graphql -f query='
  query($owner: String!) { organization(login: $owner) { issueTypes(first: 20) { nodes { id name } } } }' -F owner=<owner>
```

Find the node with `name: "Snapshot"`. Hold as `<snapshot-type-id>`. If no Snapshot type exists in the org: abort, "Org `<owner>` has no `Snapshot` Issue Type. Create it at https://github.com/organizations/<owner>/settings/issue-types and re-run."

Also resolve `<repo-node-id>`: `gh api graphql -f query='query { repository(owner: "<owner>", name: "<name>") { id } }'`. Held for `createIssue` in Step 6.

# Step 3 — Capture work file content (for issue body)

If `.td/work/<slug>.md` exists, read its full content — held as `<work-file-content>` for the issue body. If it doesn't (e.g., a single-piece topic with no work file), capture STATE.md's Resume note instead. Either way the snapshot issue body contains the durable design context.

This is why **Fix D** (the "materialise topic to disk before designing" contract rule) matters: it ensures there's always something real to capture here.

# Step 4 — Show what will be snapshotted, then act

Print a one-shot status — no prompt, just visibility:

```
Snapshotting:
  Topic:    <slug>
  Branch:   snapshot/<slug>  (off <original-branch>)
  Reason:   <reason>
  Changes to be committed:
    <git status --short output>
```

Then proceed. The user can Ctrl-C if anything looks wrong; no confirmation gate (we trust git hygiene — unrelated edits are the user's responsibility to `git stash` first).

# Step 5 — Create the snapshot branch and commit

```
git checkout -b snapshot/<slug>
git add -A
git commit -m "snapshot: <slug> — paused: <reason>"
git push -u origin snapshot/<slug>
```

If `git commit` exits with "nothing to commit" (no uncommitted edits to capture), proceed anyway — the branch tracks the current HEAD and that's all we need. Use `git commit --allow-empty -m "snapshot: <slug> — paused: <reason>"` to create a marker commit so the branch has a distinct tip.

# Step 6 — File the Snapshot GitHub issue

```
gh api graphql -H "GraphQL-Features: sub_issues" -f query='
  mutation($repoId: ID!, $title: String!, $body: String!, $typeId: ID!) {
    createIssue(input: { repositoryId: $repoId, title: $title, body: $body, issueTypeId: $typeId }) {
      issue { number url }
    }
  }' -F repoId=<repo-node-id> -F title="[Snapshot] <slug>" -F body="<body>" -F typeId="<snapshot-type-id>"
```

The **body** template:

```
**From:** <project-name>

Branch:        snapshot/<slug>
Resume:        cd <repo-path> && git checkout snapshot/<slug> && claude --resume <session-id>
Transcript:    <transcript-path>
(machine-local — branch + this issue are portable, transcript is not)

Reason: <reason>

---

## Work file at snapshot moment

<work-file-content>

---

## STATE at snapshot moment

```
Topic: <original-topic>
Phase: <original-phase>
Last:  <original-last>
```

---

To merge this work back into `<original-branch>` when ready, include `Closes #<N>` in the final commit so GitHub auto-closes this snapshot issue.
```

Hold the issue's `<N>` and `url` from the mutation response.

# Step 7 — Switch back and reset STATE

```
git checkout <original-branch>
```

Rewrite `.td/STATE.md`:

```
# State

Project:  <project-name-or-slug>
Topic:    idle
Phase:    idle
Blocker:  none
Last:     YYYY-MM-DD — snapshotted <slug> → #<N> (snapshot/<slug>).

## Resume note

`<original-topic>` paused and snapshotted as #<N> on branch `snapshot/<slug>`. Resume by checking out the branch — the `claude --resume` command is in the issue body. The previous Resume note is preserved on the snapshot branch's STATE.md.
```

Then commit and push:

```
git add .td/STATE.md
git commit -m "chore: snapshot <slug> → #<N>"
git push origin <original-branch>
```

# Step 8 — Tell the user

```
Snapshotted <slug> → #<N> on branch snapshot/<slug>.
  Issue:   <issue-url>
  Resume:  cd <repo-path> && git checkout snapshot/<slug> && claude --resume <session-id>

Back on <original-branch> with clean STATE. Ready for the next thing.
```

# Rules

- **Topic must not be idle** — abort gracefully if there's nothing in flight.
- **Snapshot type is required** — if the org doesn't have the `Snapshot` Issue Type, abort and tell the user where to create it.
- **No confirmation gate** — print what's about to happen, then act. Trust git hygiene; user Ctrl-Cs if needed.
- **Captures everything uncommitted** — `git add -A` is intentional. Unrelated edits are the user's responsibility to stash first.
- **Switch back to the original branch** — typically `main`. STATE on the original branch resets to idle; STATE on the snapshot branch stays frozen at the snapshot moment.
- **`claude --resume` is the resume mechanism** — it's a native Claude Code feature, not magic. Same-machine only (the JSONL transcript is on the originating machine). The branch + issue are portable across machines; the live conversation resume isn't.
- **Auto-close on merge** — when the snapshot work ships back to `<original-branch>`, the final commit should include `Closes #<N>` so GitHub auto-closes the issue. Standard pattern, nothing new.
- **No `/td-flow-snapshot resolve` or cleanup command** — when an issue closes, `git branch -d snapshot/<slug>` and `git push origin :snapshot/<slug>` are one line each. Don't invent ceremony.
- **Composable** — `/td-flow-incident` invokes this internally. `/td-flow-snapshot` can also be invoked standalone whenever the user wants to pivot or step away without losing in-flight context.
