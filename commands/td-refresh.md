---
description: Bring this project current with the td-flow framework. Syncs the framework install and re-syncs CLAUDE.md from canonical — an auto-merge that preserves the project's td:custom region. One mechanical pass, no prompts.
---

You are bringing this project up to the current td-flow framework. `/td-refresh` does exactly one job — sync the framework and reconcile the contract — in one mechanical pass: no questions, no digests.

It does **not** touch project state. Flushing `BACKLOG.md` is `/td-park`'s job; the cross-repo registry is checked at `/td-close`. `/td-refresh` only syncs the framework install and `CLAUDE.md` — nothing else.

`CLAUDE.md` is a managed file: everything in it is canonical except the `<!-- td:custom --> … <!-- /td:custom -->` region, which holds the project's own contract rules. So reconciling it is mechanical — take canonical, splice the project's `td:custom` content back in. No section-by-section guessing about which divergence is intentional; the marker settles it.

# Step 0 — Sync the framework

`/td-refresh` reconciles this project against the *installed* framework. If the local td-flow repo is behind its remote, the refresh reconciles against a stale baseline — so sync first.

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

This step makes no commit and touches no project files.

# Step 1 — Reconcile CLAUDE.md

Reconcile = take canonical, keep the project's `td:custom` content. No digest, no per-section decisions — the marker already says what is the project's and what is canonical.

1. Read the project's `./CLAUDE.md` and the canonical `$TD_REPO/CLAUDE.md`.

2. Locate the `td:custom` region in each — from the opening HTML comment that begins `<!-- td:custom` to the closing line `<!-- /td:custom -->`. Canonical's holds nothing between the markers; the project's may.

3. Compare the two files with their `td:custom` regions removed:
   - **Equal** → `CLAUDE.md already in sync with canonical.` Skip to Step 3. The project's `td:custom` content is its own and is never touched.
   - **Differ** → the canonical part of the project's `CLAUDE.md` is stale. Continue.

4. **Reconcile.** Build the new `CLAUDE.md`: the canonical file verbatim, with the text between the opening `td:custom` comment and the `<!-- /td:custom -->` line replaced by whatever the project had between *its* markers (nothing, if the project had no region). Write it to `./CLAUDE.md`.

5. **Report** — list the `##` sections that changed, one line each. The user reviews the full diff at commit time (Step 2); there is nothing to decide here.

   If the project's `CLAUDE.md` had **no `td:custom` region** and some of its divergence looks like a deliberate hand-edit (a project rule, not just an old copy), add one heads-up line: `§<X> had un-fenced local content — took canonical; if it was deliberate, re-add it inside the td:custom region and commit.` Don't block on it — the unpushed commit in Step 2 is the review gate.

# Step 2 — Commit (only if CLAUDE.md changed)

If Step 1 reconciled `CLAUDE.md`:

```
git add CLAUDE.md
git commit -m "docs: refresh CLAUDE.md from canonical"
```

Don't push — `/td-refresh` is doc-hygiene; the user pushes when ready. If Step 1 found nothing: no commit.

# Step 3 — Tell the user

One line:

`Framework synced (<pulled N commits / already current>). CLAUDE.md <reconciled — N sections / already in sync>.`

# Rules

- The `CLAUDE.md` reconcile is mechanical and non-interactive — the `td:custom` marker draws the line between canonical and project content, so there is nothing to decide. The unpushed `docs: refresh` commit is the user's review gate.
- The project's `td:custom` region is never modified — its content is spliced back verbatim.
- If you can't read the canonical `CLAUDE.md` (missing, permissions): stop and tell the user — don't guess what it should say.
- **Scope is the framework and `CLAUDE.md`, full stop.** `/td-refresh` never touches `.td/` docs, `BACKLOG.md`, or the cross-repo registry — those belong to `/td-park`, `/td-close`, and `/td-mailbox`. Step 0 may `git pull` the td-flow repo (clean-tree fast-forward only); Step 1 rewrites `CLAUDE.md`. Nothing else.
- The only commit `/td-refresh` makes is Step 2's `docs: refresh CLAUDE.md from canonical`, so the pre-commit `Test command` is exempt.
- Never push.
