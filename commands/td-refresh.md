---
description: Bring this project current with the td-flow framework — pull the latest framework, re-run the installer, and (one-time) migrate the project off the old copied-contract model onto the @import.
---

You are syncing this project with the td-flow framework. The contract is no longer copied into each project — a project's `CLAUDE.md` is a one-line `@import` of the canonical contract (`~/.claude/td-flow-contract.md`, linked by `install.sh`). So a "refresh" is two things: pull the framework so the canonical is current, and — once per project — migrate a legacy `CLAUDE.md` that still holds a full copy onto the import.

# Step 0 — Sync the framework

Resolve the framework repo from this command's symlink target (clone-path-independent), falling back to the default clone path:

```
TD_REPO=$(cd "$(dirname "$(readlink ~/.claude/commands/td-refresh.md)")/.." 2>/dev/null && pwd)
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

# Step 2 — Tell the user

Two lines:

`Framework synced (<pulled N commits / already current>). CLAUDE.md <migrated to the @import / already on the import model>.`

`Slash commands available: ` then list the basename of every `*.md` in `~/.claude/commands/` that resolves into `<TD_REPO>/commands/`. Useful when refreshing from a long-stale state — surfaces commands the user may not have seen before (e.g. `/td-snapshot` was added in v5.2).

# Rules

- `/td-refresh` syncs the framework and migrates a legacy `CLAUDE.md` — nothing else. It never touches `.td/` docs, `BACKLOG.md`, or the cross-repo registry.
- Step 0 may `git pull` the td-flow repo, but only as a clean-tree fast-forward; it never merges or forces.
- The only commit `/td-refresh` makes is Step 1's one-time migration commit; it commits `--no-verify` so the pre-commit hook's `Test command` doesn't gate a doc-only rewrite.
- Never push.
