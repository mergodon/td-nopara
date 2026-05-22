---
description: Bring this project current with the td-flow framework. Syncs the framework install, re-syncs CLAUDE.md from canonical (auto-merge — the project's td:custom region is preserved), flushes any BACKLOG items to GitHub Issues, and checks the cross-repo registry. One pass — surfaces only genuine decisions.
---

You are bringing this project up to the current td-flow framework. It runs in one pass — sync the framework, reconcile `CLAUDE.md`, flush `BACKLOG.md`, check the cross-repo registry — and most of it is mechanical: act, don't ask. Only two things can stop for a decision: the `/td-park` flush digest (if BACKLOG has items) and a genuine cross-repo drift (if any). When nothing needs deciding, `/td-refresh` does the work and reports.

`CLAUDE.md` is a managed file: everything in it is canonical except the `<!-- td:custom --> … <!-- /td:custom -->` region, which holds the project's own contract rules. So reconciling it is mechanical — take canonical, splice the project's `td:custom` content back in. No section-by-section guessing about which divergence is intentional; the marker settles it.

# Step 0 — Sync the framework (Phase 0)

Later steps compare this project against the *installed* framework. If the local td-flow repo is behind its remote, the refresh reconciles against a stale baseline — so sync first.

Confirm this is a td-flow project — abort if not: `./CLAUDE.md` and `./.td/` must both exist. If either is missing: abort with "Not a td-flow project — `/td-refresh` only runs inside a td-flow project."

Resolve the framework repo from this command's symlink target (clone-path-independent), falling back to the default clone path:

```
TD_REPO=$(cd "$(dirname "$(readlink ~/.claude/commands/td-refresh.md)")/.." 2>/dev/null && pwd)
[ -d "$TD_REPO/.git" ] || TD_REPO="$HOME/projects/td-flow"
```

If `$TD_REPO` still isn't a git repo: abort with "Can't find the td-flow framework repo — is td-flow installed?"

**Pull the framework if behind** — check, then act when it's safe (no prompt; the pull is safe by construction):

```
git -C "$TD_REPO" fetch --quiet origin 2>/dev/null
git -C "$TD_REPO" rev-list --count main..origin/main 2>/dev/null
```

- Count `0`, or the check errors (offline) → `Framework repo current.`
- Count `N > 0` → show the commits (`git -C "$TD_REPO" log --oneline main..origin/main`), then:
  - Tree clean (`git -C "$TD_REPO" status --porcelain` empty) **and** the pull is a fast-forward → `git -C "$TD_REPO" pull --ff-only origin main`; report `Pulled N framework commit(s).`
  - Tree dirty → skip; "td-flow repo has uncommitted changes — refreshing against `main`, N commits behind."
  - Not a fast-forward (local commits diverged) → skip; "td-flow `main` diverged from origin — resolve it in the td-flow repo." Never merge or force during a refresh.

**Re-run the installer** (always — idempotent, only rewrites `~/.claude/` symlinks):

```
bash "$TD_REPO/install.sh"
```

Report what it pruned/added, or `framework symlinks already in sync`.

Phase 0 makes no commit and touches no project files.

# Step 1 — Reconcile CLAUDE.md (Phase 1)

Reconcile = take canonical, keep the project's `td:custom` content. No digest, no per-section decisions — the marker already says what is the project's and what is canonical.

1. Read the project's `./CLAUDE.md` and the canonical `$TD_REPO/CLAUDE.md`.

2. Locate the `td:custom` region in each — from the opening HTML comment that begins `<!-- td:custom` to the closing line `<!-- /td:custom -->`. Canonical's holds nothing between the markers; the project's may.

3. Compare the two files with their `td:custom` regions removed:
   - **Equal** → `Phase 1 in sync — CLAUDE.md matches canonical.` Continue to Step 2. The project's `td:custom` content is its own and is never touched.
   - **Differ** → the canonical part of the project's `CLAUDE.md` is stale. Continue.

4. **Reconcile.** Build the new `CLAUDE.md`: the canonical file verbatim, with the text between the opening `td:custom` comment and the `<!-- /td:custom -->` line replaced by whatever the project had between *its* markers (nothing, if the project had no region). Write it to `./CLAUDE.md`.

5. **Report** — list the `##` sections that changed, one line each. The user reviews the full diff at commit time (Step 4); there is nothing to decide here.

   If the project's `CLAUDE.md` had **no `td:custom` region** and some of its divergence looks like a deliberate hand-edit (a project rule, not just an old copy), add one heads-up line: `§<X> had un-fenced local content — took canonical; if it was deliberate, re-add it inside the td:custom region and commit.` Don't block on it — the unpushed commit in Step 4 is the review gate.

# Step 2 — Flush BACKLOG (Phase 2)

`.td/BACKLOG.md` is session-scoped; items shouldn't survive across `/td-close`. A refresh is a good moment to flush any that lingered.

1. Read `.td/BACKLOG.md`. Count bullet items (`- …` lines); skip the preamble and the `(empty)` placeholder.
2. **0 items** → skip silently, go to Step 3.
3. **N > 0 items** → say `BACKLOG has N item(s) — flushing via /td-park.` and run the canonical `/td-park` procedure (its Steps 2–8: cache Issue Type IDs + friendly name → consolidate related lines → digest with Type + dedupe → one decision point → batch-create → rewrite `BACKLOG.md`). Skip `/td-park`'s Step 0/1 (already verified; BACKLOG read here) and its Step 9 summary (Step 5 below covers it).

`/td-park`'s own digest is the decision point — the user adjusts or declines there. No separate yes/no gate.

# Step 3 — Cross-repo registry drift (Phase 3)

`.td/PROJECT.md § Cross-repo` bounds `/td-mailbox`'s outbound query. Stale or missing entries cause real visibility gaps — but only some drift is worth a prompt.

1. Friendly name: first H1 in `.td/PROJECT.md`, else directory basename. Hold as `<project-name>`.
2. Org-wide `**From:**` marker search (NOT bounded by the declared list — that would defeat the point):

```
gh api graphql -f query='
  query($q: String!) {
    search(query: $q, type: ISSUE, first: 100) {
      nodes { ... on Issue { number title url body state repository { nameWithOwner } } }
    }
  }' -F q="org:<owner> \"<project-name>\" type:issue state:open"
```

3. Filter client-side: keep results whose body begins `**From:** <project-name>\b` AND whose `repository.nameWithOwner` ≠ this repo → **observed-repos**.
4. Read `.td/PROJECT.md § Cross-repo`; parse declared slugs and note whether each carries a `— <context>` description → **declared-repos**. Section missing → empty set.
5. Decide what is worth surfacing:
   - **observed but not declared** → always surface — a real gap (`/td-mailbox` outbound can't see those filings).
   - **declared but not observed, entry is bare** (no `— <context>`) → surface — likely stale.
   - **declared but not observed, entry has context** → **stay silent.** A described declaration is an intentional, documented connection; "no open filings right now" is quiet, not drift. (This is the common case — don't turn it into a prompt.)
6. **Nothing to surface** → `Cross-repo registry in sync.` and continue.
   **Something to surface** → one digest, decided in a single reply:

```
Cross-repo registry drift — <N> item(s)
  observed but not declared (/td-mailbox outbound can't see these):
    1. <repo> — <count> open filing(s): #<N> <title>   → declare?
  declared but not observed, no context (likely stale):
    2. <repo>   → remove?
Reply, e.g. "declare 1 with context, remove 2".
```

Apply the batch: **declare** → append `- <repo>` (or `- <repo> — <context>` for `declare with context` — ask for the line); **remove** → delete the line; **skip/keep** → leave as-is. Write back `.td/PROJECT.md` if anything changed — the user reviews the diff at commit time.

# Step 4 — Commit CLAUDE.md (only if it changed)

If Step 1 reconciled `CLAUDE.md`:

```
git add CLAUDE.md
git commit -m "docs: refresh CLAUDE.md from canonical"
```

Commit `CLAUDE.md` only. Cross-repo edits to `.td/PROJECT.md` (Step 3) and the `BACKLOG.md` rewrite (Step 2) stay uncommitted — the user reviews and commits them alongside their own work. Don't push: `/td-refresh` is doc-hygiene; the user pushes when ready.

If Step 1 found nothing: no commit.

# Step 5 — Tell the user

One line covering the pass:

`Framework synced (<pulled N commits / already current>). CLAUDE.md <reconciled — N sections / in sync>. BACKLOG <flushed M items / empty>. Cross-repo registry <K updated / in sync>.`

# Rules

- The `CLAUDE.md` reconcile is mechanical and non-interactive — the `td:custom` marker draws the line between canonical and project content, so there is nothing to decide. The unpushed `docs: refresh` commit is the user's review gate.
- The project's `td:custom` region is never modified — its content is spliced back verbatim.
- If you can't read the canonical `CLAUDE.md` (missing, permissions): stop and tell the user — don't guess what it should say.
- **Phase 0** may `git pull` the td-flow repo, but only as a clean-tree fast-forward; it makes no commit and never touches project files. **Phase 1** rewrites `CLAUDE.md`. **Phases 2–3** may rewrite `.td/BACKLOG.md` and `.td/PROJECT.md`.
- The only commit `/td-refresh` makes is Step 4's `docs: refresh CLAUDE.md from canonical`, so the pre-commit `Test command` is exempt.
- Never push.
