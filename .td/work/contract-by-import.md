# v5.0 — deliver the contract by import, not copy

Planning scratch. Triggered 2026-05-22 by the user's question — "is storing the
rules in CLAUDE.md the main issue?" Yes. Supersedes `.td/work/section-ownership.md`
(fold-and-delete that file with the first v5.0 commit).

## The problem

Every td-flow project carries a full COPY of the ~200-line contract in its
CLAUDE.md. Copies drift. `/td-refresh`, the v4.9 managed-file model, the
`td:custom` marker, take-canonical-and-resplice — all machinery to manage that
copy. The framework's own #1 principle is "GitHub is the memory — don't
duplicate," and it duplicates its whole contract into every project. Root issue.

## The fix

A project's CLAUDE.md imports the contract instead of containing it:

    @~/.claude/td-flow-contract.md

    ## Project-specific rules
    (optional — usually empty)

One canonical contract, no per-project copy, nothing to drift. Verified against
the Claude Code docs (claude-code-guide agent): `@import` content loads in full
at session start every session — same guarantee as inline CLAUDE.md. Home paths
and symlinks supported.

## Step 0 — GO / NO-GO gate (before anything else)

Prove the import actually loads in a live Claude Code session. Throwaway project
(WORKWAY § Local UAT method):
- `ln -s ~/projects/td-flow/CLAUDE.md ~/.claude/td-flow-contract.md`
- `/tmp/td-import-test/CLAUDE.md` = the single line `@~/.claude/td-flow-contract.md`
- Open Claude Code there → confirm it knows the td-flow contract (rhythm, rules).
- Approve the external-import dialog when prompted (expected, one-time per project).

If it doesn't load reliably → STOP. The whole plan depends on this one fact.

## The work — ✓ SHIPPED (Step 0 gate passed; landed in one v5.0 commit)

Items 1–6 below all shipped in the v5.0 commit. Item 7 (UAT) + 8 (close) remain.

1. **install.sh** — symlink `~/.claude/td-flow-contract.md` → repo `CLAUDE.md`,
   alongside the existing command/skill/template symlinks.
2. **Contract content** (canonical `CLAUDE.md`) — remove the `td:custom` region;
   rewrite the preamble (managed-copy framing → single-source/import framing);
   update § Drift signals (drop "differs from canonical outside td:custom" — no
   copy exists; adapt the Boost-overwrite signal to "the `@import` line is
   missing"); update the § slash-commands `/td-refresh` line.
3. **templates/CLAUDE.md** — shrink to the ~3-line import template. Kills the
   root↔template byte-identical mirroring.
4. **/td-init** — write the import-line CLAUDE.md (Step 3 + the v2/brownfield
   migration branches). Assumes td-flow is installed (import target exists).
5. **/td-refresh** — rewrite: `git pull` + `install.sh` (its current Step 0),
   PLUS a one-time migration — if this project's CLAUDE.md is a full copy (no
   `@import` line), convert it to the import, preserving any genuine local
   additions below the line. Delete the reconcile/resplice machinery.
6. **README + SKILL.md** — update to the import model (Install, "The docs",
   "Updating an existing project" becomes trivial, /td-refresh row, Repo layout).
7. **UAT** — throwaway project end-to-end: /td-init → import CLAUDE.md → contract
   loads; simulate an old full-copy project → /td-refresh migrates it.
8. **Close as v5.0.**

## Commit shape

The install.sh symlink can land first (harmless alone). The rest — contract
cleanup + templates + /td-init + /td-refresh + README/SKILL — is interdependent;
a half-migrated framework is incoherent. Land as one or two cohesive commits.
Exact split decided at execution.

## Supersedes / survives

- **Supersedes:** v4.9 Piece 1 (managed-file preamble + `td:custom`), Piece 2
  (/td-refresh take-canonical-and-resplice). The preamble is rewritten not
  deleted; /td-refresh's framework-sync half survives as the whole command.
- **Survives untouched:** Pieces 3 (nudge scoping), 4 (Idea→Task), 5 (GSD
  removal), the /td-clear doc-sync. Their content lives in the contract — same
  content, now delivered by import.
- The 7 v4.9 commits stay in git history; no separate v4.9 Shipped entry — the
  whole arc closes as v5.0, the entry noting the managed-file model was explored
  then superseded.

## Honest risks

- **Import-load reliability** — Step 0 gate covers it.
- First external import → a one-time Claude Code approval dialog per project.
- **Existing td-flow projects** carry full-copy CLAUDE.md — /td-refresh owns the
  migration (work item 5).
- Boost can still overwrite a project's CLAUDE.md — but restoring is now one line,
  not 200. Drift signal adapted.
- Projects stop being self-contained (CLAUDE.md is one line; the contract lives
  in the install). Accepted — commands + skill already depend on the install.

## Not an Epic

Cohesive single-repo change, like v4.9. One work file, a short sequence of commits.
