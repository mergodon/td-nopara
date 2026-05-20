---
description: Bring this project current with the framework conventions. (0) Sync the framework install — re-run install.sh, offer to pull td-flow if behind. (1) Diff CLAUDE.md against canonical, propose per section. (2) Flush any accumulated BACKLOG items to GitHub Issues. (3) Cross-repo registry drift check — diff actual filings against PROJECT.md § Cross-repo, propose add/remove per delta. Diff-and-propose throughout — never overwrites without your accept.
---

You are bringing this project up to the current framework conventions. Four phases, all diff-and-propose, all per-item-confirmable, never destructive without explicit user accept:

- **Phase 0 (Step 0):** Sync the framework itself before comparing against it. Re-run `install.sh` (idempotent — refreshes `~/.claude/` symlinks, prunes stale ones); if the local td-flow repo is behind its remote, offer to pull. Everything after this compares the project against the *installed* framework, so it has to be current first.
- **Phase 1 (Steps 1-6):** Review project `CLAUDE.md` against the installed canonical (`$TD_REPO/CLAUDE.md`, resolved in Phase 0). The canonical drifts forward over time; project copies fall behind. Surface every section deviation, propose what to take, apply only what the user accepts.
- **Phase 2 (Step 7):** If `.td/BACKLOG.md` has accumulated items (left over from before the gh-source-of-truth model, or just from extended work), offer to flush them to GitHub Issues using the `/td-park` procedure.
- **Phase 3 (Step 8):** Cross-repo registry drift check. `.td/PROJECT.md § Cross-repo` is load-bearing (bounds `/td-mailbox` outbound). Compare actual filings (via org-wide `**From:**` marker search) against the declared list; propose add (we filed into a repo not declared) or remove (declared but never used).
The user owns both surfaces. Your role is to make the deltas reviewable, one item at a time.

# Step 0 — Sync the framework (Phase 0)

Every later phase compares this project against the *installed* framework — the canonical `CLAUDE.md`, the symlinked commands, the templates dir. If the local td-flow repo is behind its remote, or `install.sh` wasn't re-run after command files changed, the refresh reconciles against a stale baseline. So sync the framework before comparing against it.

First, confirm this is a td-flow project — abort if not:

- `./CLAUDE.md` and `./.td/` both exist. If either is missing: abort with "Not a td-flow project — `/td-refresh` only runs inside a td-flow project."

Resolve the framework repo — `install.sh` symlinks this command out of the repo, so the symlink target locates it regardless of clone path; fall back to the default clone path:

```
TD_REPO=$(cd "$(dirname "$(readlink ~/.claude/commands/td-refresh.md)")/.." 2>/dev/null && pwd)
[ -d "$TD_REPO/.git" ] || TD_REPO="$HOME/projects/td-flow"
```

If `$TD_REPO` still isn't a git repo: abort with "Can't find the td-flow framework repo — is td-flow installed?" (Phase 1 needs the canonical `CLAUDE.md` from it.)

**Check for unpulled framework commits** (read-only):

```
git -C "$TD_REPO" fetch --quiet origin 2>/dev/null
git -C "$TD_REPO" rev-list --count main..origin/main 2>/dev/null
```

- Count `0`, or the check errors (offline): say `Framework repo current.` and continue to the install step.
- Count `N > 0`: show the commits (`git -C "$TD_REPO" log --oneline main..origin/main`), then ask:

  ```
  td-flow is N commit(s) behind origin/main. Pull before refreshing? (yes / no)
  ```

  - `no` → continue, but note: "Refreshing against td-flow `main`, N commits behind origin — Phase 1's canonical may be stale."
  - `yes` → only pull if the repo's tree is clean (`git -C "$TD_REPO" status --porcelain` is empty). If dirty: skip the pull, say "td-flow repo has uncommitted changes — skipping pull, resolve it manually if you want those commits." If clean: `git -C "$TD_REPO" pull --ff-only origin main`. If the pull isn't a fast-forward (local commits diverged): surface that and continue without it — never merge or force during a refresh.

**Re-run the installer** (always — idempotent, only writes `~/.claude/` symlinks):

```
bash "$TD_REPO/install.sh"
```

This re-links all commands, the skill, and templates, and prunes stale symlinks (e.g. a command that was renamed). Report concisely: what it pruned/added, or `framework symlinks already in sync` if nothing changed.

Phase 0 makes no commit and touches no project files — it only updates the td-flow repo (on your confirmation) and the `~/.claude/` symlinks. Continue to Step 1.

# Step 1 — Quick equality check

Compare the project `CLAUDE.md` against the canonical at `$TD_REPO/CLAUDE.md` (`$TD_REPO` resolved in Step 0). If they match byte-for-byte, tell the user "Phase 1 in sync — no CLAUDE.md deltas." and skip to Step 7 (Phase 2). Phases 2-3 still need to run.

# Step 2 — Split into sections

Both files are organized by `##` headings. Split each into ordered `(heading, body)` pairs. Treat the preamble (content before the first `##`) as its own section keyed `_preamble`.

# Step 3 — Categorize each section

For each section, compare local vs canonical and bucket it:

- **clean** — local matches canonical (ignore whitespace-only differences).
- **canonical-newer** — local looks like an older copy of canonical; canonical has changes local doesn't have.
- **local-has-additions** — local contains content not in canonical. Likely intentional project-specific drift.
- **genuinely-diverged** — both sides have non-trivial changes. Needs the user's eye.
- **missing-locally** — section exists in canonical, not in local → treat as canonical-newer.
- **missing-in-canonical** — section exists in local, not in canonical → treat as local-has-additions.

# Step 4 — Report the shape

Before walking individual sections, print one compact summary:

```
N sections clean ✓
N sections canonical-newer:    <heading-list>
N sections local-has-additions: <heading-list>
N sections genuinely-diverged:  <heading-list>
```

If everything came out clean after whitespace normalization, say "Differences are whitespace-only — no semantic deltas." and exit without changes.

# Step 5 — Walk the non-clean sections

For each non-clean section, in document order, present:

1. The heading.
2. The category.
3. The diff — pick the right format for the size: inline prose for tiny tweaks, `diff` style for larger blocks.
4. A recommendation:
   - **canonical-newer** → recommend "take canonical."
   - **local-has-additions** → recommend "keep local," explain why you think it's intentional drift.
   - **genuinely-diverged** → no default; ask the user.
5. Wait for one of: `take canonical` / `keep local` / `show me both` / `skip for now` / a freeform instruction.

Apply choices as you go. Don't batch — apply each accepted change before moving to the next section so the working file always reflects the user's current accepted state.

If the user says "take all canonical sections" or similar bulk accept, confirm once, then apply all `canonical-newer` sections in one pass. Still walk `genuinely-diverged` and `local-has-additions` individually — bulk-accept doesn't apply to ambiguous categories.

# Step 6 — Commit (only if something changed)

If any sections were updated:

```
git add CLAUDE.md
git commit -m "docs: refresh CLAUDE.md from canonical"
```

If the user kept everything local: "Reviewed N sections, nothing accepted. No commit."

Do **not** push automatically. `/td-refresh` is doc-hygiene; the user pushes when they're ready alongside other work.

# Step 7 — BACKLOG migration (Phase 2, conditional)

The refresh also checks whether `.td/BACKLOG.md` has accumulated items that belong in GitHub Issues now (per the gh-source-of-truth model — BACKLOG flushes to GH at `/td-close`).

1. Read `.td/BACKLOG.md`. Count bullet items (lines shaped like `- ...`). Skip the preamble and the `(empty)` placeholder.
2. **If item count is 0:** skip silently, jump to Step 8.
3. **Otherwise:** tell the user `BACKLOG has N items. Flush them to GitHub Issues as part of the refresh? (yes / no / show me)` and wait.
4. **On `show me`:** print each item with line number, then re-ask.
5. **On `yes`:** invoke the `/td-park` procedure inline — walk each line, suggest Type with the vague-defaults-to-`Idea` heuristic, show the trigger phrase, dedupe against open issues, then per line: sync to GH with the chosen type / drop / skip. Apply each before moving on. Rewrite `BACKLOG.md` at the end with only skipped lines.
6. **On `no`:** skip. BACKLOG stays untouched.

This is the migration path for projects that pre-date the gh-source-of-truth model. Projects starting on the current model rarely accumulate BACKLOG items across `/td-close` boundaries, so Phase 2 is usually a no-op or a small flush.

# Step 8 — Cross-repo registry drift check (Phase 3)

`.td/PROJECT.md § Cross-repo` is load-bearing — it bounds `/td-mailbox`'s outbound query. Stale or missing entries cause real visibility gaps:
- **Missing entry:** we filed into a repo not declared → that filing won't show up in `/td-mailbox` outbound.
- **Stale entry:** we declared a repo but never filed into it → noise in the list.

Check by comparing actual filings against the declared list.

1. Determine this project's friendly name (same procedure as `/td-mailbox` Step 1: first H1 in `.td/PROJECT.md`, fall back to directory basename). Hold as `<project-name>`.

2. Run an **org-wide** `**From:**` marker search (NOT bounded by the declared list — that would defeat the point):

```
gh api graphql -f query='
  query($q: String!) {
    search(query: $q, type: ISSUE, first: 100) {
      nodes {
        ... on Issue {
          number title url body state
          repository { nameWithOwner }
        }
      }
    }
  }' -F q="org:<owner> \"<project-name>\" type:issue state:open"
```

State filter is `state:open` — focus on active connections. A long-closed one-off shouldn't force a declaration.

3. Filter client-side: keep only results where body begins with `**From:** <project-name>\b` AND `repository.nameWithOwner != "<owner>/<name>"` (cross-repo from this project's perspective). Collect unique set of `repository.nameWithOwner` → **observed-repos**.

4. Read `.td/PROJECT.md § Cross-repo`. Parse out the declared GH slugs → **declared-repos**. (If section missing, treat as empty set.)

5. Compute diffs:
   - **observed but not declared** → filings exist that `/td-mailbox` outbound can't see.
   - **declared but not observed** → noise (no open filings from us into that repo).

6. Surface per item, one at a time.

For **observed-not-declared**:
```
<repo> — <count> open filing(s) found, e.g.:
  #<N> <title>
  <more if multiple>
Declare in .td/PROJECT.md § Cross-repo? (yes / yes-with-context / skip)
```
- `yes` → append `- <repo>` to the section (create the section if missing).
- `yes-with-context` → ask user for one-line description, append `- <repo> — <context>`.
- `skip` → leave undeclared (the visibility gap persists; you'll be reminded next refresh).

For **declared-not-observed**:
```
Declared: <repo>
No open filings found from <project-name>. Remove from list? (yes / keep)
```
- `yes` → remove the line.
- `keep` → leave (maybe an expected connection that hasn't been used yet, or a one-off you want documented).

7. If both diffs are empty: say `Cross-repo registry in sync.` and continue.

If you made changes: write back `.td/PROJECT.md`. The user reviews the diff at commit time.

# Step 9 — Tell the user

One sentence covering all four phases:

`Framework synced (<pulled N commits / already current>). Refresh complete — <N> CLAUDE.md sections updated. <M> BACKLOG items flushed to GH. <K> Cross-repo entries updated.`

If a phase didn't fire (no deltas, no items): use "in sync" wording for that phase instead of a number.

# Rules

- Never overwrite `CLAUDE.md` without an explicit per-section accept (or bulk-accept) from the user.
- Never auto-merge sections the user didn't review.
- Don't propose deltas for whitespace-only differences.
- If you can't read the canonical (missing, permission), stop and tell the user — don't guess what it should say.
- **Phase 0** re-runs `install.sh` (idempotent — re-links `~/.claude/` symlinks) and, only with your confirmation and only as a fast-forward, may `git pull` the td-flow repo. It makes no commit and never touches project files. Phases 1-3 touch root `CLAUDE.md`; they never overwrite existing `.td/*` content.
- The only commit this command makes is Step 6's `docs: refresh CLAUDE.md from canonical`, so the pre-commit `Test command` is exempt.
