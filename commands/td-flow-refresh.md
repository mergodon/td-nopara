---
description: Bring this project current with the td-flow framework — pull the latest framework, re-run the installer, and (one-time) migrate the project off the old copied-contract model onto the @import.
---

You are syncing this project with the td-flow framework. The contract is no longer copied into each project — a project's `CLAUDE.md` is a one-line `@import` of the canonical contract (`~/.claude/td-flow-contract.md`, linked by `install.sh`). So a "refresh" is two things: pull the framework so the canonical is current, and — once per project — migrate a legacy `CLAUDE.md` that still holds a full copy onto the import.

# Step 0 — Sync the framework

Resolve the framework repo from this command's symlink target (clone-path-independent), falling back to the default clone path:

```
TD_REPO=$(cd "$(dirname "$(readlink ~/.claude/commands/td-flow-refresh.md)")/.." 2>/dev/null && pwd)
[ -d "$TD_REPO/.git" ] || TD_REPO="$HOME/projects/td-flow"
```

If `$TD_REPO` isn't a git repo: abort with "Can't find the td-flow framework repo — is td-flow installed?"

**Pull the framework if behind** — check, then act when it's safe (no prompt; the pull is safe by construction):

```
git -C "$TD_REPO" fetch --quiet origin 2>/dev/null
git -C "$TD_REPO" rev-list --count main..origin/main 2>/dev/null
```

- Count `0`, or the check errors (offline) → `Framework repo current.`
- Count `N > 0` → show the commits (`git -C "$TD_REPO" log --oneline main..origin/main`), then:
  - Tree clean (`git -C "$TD_REPO" status --porcelain` empty) **and** the pull is a fast-forward → `git -C "$TD_REPO" pull --ff-only origin main`; report `Pulled N framework commit(s).`
  - Tree dirty → skip; "td-flow repo has uncommitted changes — skipping pull, N commits behind."
  - Not a fast-forward (local commits diverged) → skip; "td-flow `main` diverged from origin — resolve it in the td-flow repo." Never merge or force during a refresh.

**Re-run the installer** (always — idempotent; relinks the `~/.claude/` symlinks, including `td-flow-contract.md`):

```
bash "$TD_REPO/install.sh"
```

Once this runs, `~/.claude/td-flow-contract.md` points at the current contract — and every project that `@import`s it is current next session. That is the refresh: there is no per-project contract copy to reconcile.

# Step 1 — Migrate a legacy CLAUDE.md (one-time, only if needed)

Read this project's `./CLAUDE.md`.

- **It is the one-line `@import`** — contains `@~/.claude/td-flow-contract.md`, plus at most a project-specific section below it → already on the current model. Nothing to migrate; skip to Step 2.
- **It is a full copy of the contract** — a pre-import-model project carrying the whole contract inline (possibly with an old `<!-- td:custom -->` region) → migrate it:
  1. Extract any genuinely project-specific content — the body of an old `<!-- td:custom -->` region, or any section clearly not part of the canonical contract. If you can't tell whether something is project-specific, surface it to the user rather than discard it.
  2. Rewrite `./CLAUDE.md` as: the `@~/.claude/td-flow-contract.md` import line, then the extracted project-specific content (if any) below it.
  3. Commit: `git add CLAUDE.md` then `git commit --no-verify -m "docs: migrate CLAUDE.md to the imported td-flow contract"`. The `--no-verify` skips the pre-commit hook's `Test command` — this commit only rewrites a doc, there is no code change to gate, and the project's test env may not be ready. Don't push — the user pushes when ready.

This runs once per project. After it, the project's `CLAUDE.md` never needs reconciling again — it imports the canonical, which `git pull` keeps current.

# Step 1.5 — Prune deprecated nudge patterns from `./CLAUDE.md`

Runs every refresh, not just on migration. Some rules that lived in earlier contract versions have been retired because the user pushed back on them. Migrated projects (or project-specific tails below the `@import` line) can still carry the old phrasing. Prune it.

Known-deprecated patterns (extend this list when new ones surface):

- `anything else on your mind` — unscoped pre-work nudge, retired.
- `ride along` — sibling phrasing of the same nudge.
- `We're scattered` — mid-flow "want to wrap and start fresh?" interrupting question, retired.

Procedure:

1. `grep -in -E "anything else on your mind|ride along|We're scattered" ./CLAUDE.md` — if zero hits, skip the rest.
2. For each hit, locate the bounding chunk (the bullet, line, or short paragraph that contains it). If the chunk is cleanly delimited (a single bullet or sentence), remove it. If the phrase sits inside a longer paragraph where removal would mangle surrounding meaning, surface the line to the user with the exact text and ask once before editing.
3. If any change was made, commit: `git add CLAUDE.md` then `git commit --no-verify -m "chore: prune deprecated nudge language from CLAUDE.md"`. Same `--no-verify` rationale as Step 1 — doc-only rewrite. Don't push.

# Step 1.7 — Migrate `.td/` → `.td-flow/` (one-time, only if needed)

The v7.0 rename moved the per-project state dir from `.td/` to `.td-flow/` (consistent with the rest of the namespace: `td-flow`, `/td-flow-*`, `td-flow-contract.md`). Migrate any project still on `.td/`.

Procedure:

1. **Detect the state**:
   ```
   has_td_dir=false      # .td/ exists as a real directory
   has_td_symlink=false  # .td/ exists as a symlink (already migrated)
   has_td_flow=false     # .td-flow/ exists
   [ -d .td ] && [ ! -L .td ] && has_td_dir=true
   [ -L .td ] && has_td_symlink=true
   [ -d .td-flow ] && has_td_flow=true
   ```
2. **Decide**:
   - Neither `.td/` nor `.td-flow/` → not a td-flow project (or never initialized). Skip silently.
   - `.td-flow/` exists AND `.td/` is a symlink → already migrated. Skip silently.
   - `.td-flow/` exists AND `.td/` is a real directory → conflict (both layouts present). Abort: "Both `.td/` and `.td-flow/` exist as real directories. Resolve manually before refreshing — pick which one is canonical, move any content over, delete the loser."
   - `.td-flow/` doesn't exist AND `.td/` is a real directory → **migrate**.
3. **Migrate** (only when the "migrate" branch fires):
   ```
   git mv .td .td-flow                                     # preserves history
   ln -s .td-flow .td                                      # compat symlink for any user-side .td/ refs
   git add .td .td-flow                                    # stage the move + the symlink
   git commit --no-verify -m "chore: migrate .td/ → .td-flow/ (td-flow v7.0)"
   ```
   Same `--no-verify` rationale as Steps 1 + 1.5: doc/structure-only change, the pre-commit hook's `Test command` shouldn't gate it. Don't push — the user pushes when ready.
4. **Tell the user** what was done (renamed dir + compat symlink).

The compat symlink stays until v8.0 (a future framework version drops the `.td/` fallback from `hooks/pre-commit` and `scripts/smoke.sh`; existing symlinks in user projects stay until the user removes them manually).

# Step 2 — Tell the user

Two lines:

`Framework synced (<pulled N commits / already current>). CLAUDE.md <migrated to the @import / already on the import model / pruned N deprecated nudge line(s) / no changes>. State dir <migrated .td → .td-flow + compat symlink / already on .td-flow/ / N/A — not a td-flow project>.`

`Slash commands available: ` then list the basename of every `*.md` in `~/.claude/commands/` that resolves into `<TD_REPO>/commands/`. Useful when refreshing from a long-stale state — surfaces commands the user may not have seen before (e.g. `/td-flow-snapshot` was added in v5.2).

# Rules

- `/td-flow-refresh` syncs the framework, migrates a legacy `CLAUDE.md`, prunes deprecated nudge patterns, and (one-time per project) migrates the state dir from `.td/` to `.td-flow/` — nothing else. It never touches `.td-flow/` doc *contents*, `BACKLOG.md`, or the cross-repo registry.
- Step 0 may `git pull` the td-flow repo, but only as a clean-tree fast-forward; it never merges or forces.
- The only commits `/td-flow-refresh` makes are Step 1's one-time `CLAUDE.md` migration, Step 1.5's nudge prune (only if a match was found and cleanly removed), and Step 1.7's one-time `.td → .td-flow` rename; all `--no-verify` so the pre-commit hook's `Test command` doesn't gate structural rewrites.
- Never push.
