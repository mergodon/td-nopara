---
description: Execute the next piece (BIG) or the fix (SMALL). Work + test + commit + push + advance.
---

You are shipping the next unit of work. Read `.td/STATE.md` and `.td/flow/` to determine what to ship.

# Step 1 — Identify the unit

- If `.td/flow/fix.md` exists → SMALL flow. Unit = the fix.
- If `.td/flow/plan.md` exists → BIG flow. Unit = the next unfinished piece (lowest-numbered `NN-name.md` not marked done).
- If neither → abort: tell the user to start a flow with `/td-feature` or `/td-fix` first.

# Step 2 — Read context

- `.td/PROJECT.md` — scope and stack
- `.td/TESTING.md` — pre-ship checklist
- `.td/ENV.md` — live env (only if needed for this piece)
- The unit's flow file (`fix.md` or `NN-name.md`) — goal, plan, test
- Any `.td/frameworks/*.md` relevant to the surfaces being touched

# Step 3 — Do the work

Implement the piece. Stay inside its scope — do not expand. If the work reveals the piece is actually two pieces, stop, update `plan.md` to split, and ship only the first half.

Append progress notes to the piece's `## Notes` section as you go. Keep them terse.

# Step 4 — Run the pre-ship checklist

Walk every checkbox in `.td/TESTING.md` "Pre-ship checklist". Each must pass.

- Test command must exit 0.
- Dev server must start clean.
- Manual / browser / curl checks: actually run them. Do not skip.

If any check fails: stop, do not commit, surface the failure to the user, and wait for direction.

# Step 5 — Commit

One commit. Use the format from `CLAUDE.md`:

- BIG piece: `feat(<feature>): <NN> <piece-name>`
- SMALL fix: `fix: <one-line description>`

Stage with explicit paths (no `git add -A` — do not pull in unrelated noise). Do not include co-author trailers unless the user has asked for them in this repo.

If the pre-commit hook fails, do not retry with `--no-verify`. Investigate, fix, re-stage, commit again.

# Step 6 — Push

```
git push origin main
```

If the push is rejected (someone else pushed, network failure), surface the error to the user and stop. Do not force-push.

# Step 7 — Advance

**SMALL flow:**
- Delete `.td/flow/`.
- Update `.td/PROJECT.md`: if this fix corresponds to a "Shipped" line, add it; otherwise leave PROJECT.md alone.
- Rewrite `.td/STATE.md` to idle:
  ```
  Currently: idle (no active flow)
  Position: —
  Status: ready
  Last action: <YYYY-MM-DD> — shipped fix: <description>
  Next: start a flow with `/td-feature <name>` or `/td-fix <description>`
  ```

**BIG flow:**
- Mark the piece done in `.td/flow/plan.md` (prefix the piece line with `[x]`).
- If more pieces remain: rewrite `.td/STATE.md` to point at the next piece.
- If this was the last piece:
  - Update `.td/PROJECT.md`: move the feature from "Active scope" to "Shipped".
  - Delete `.td/flow/`.
  - Rewrite `.td/STATE.md` to idle.

# Step 8 — Tell the user

One or two sentences max:

- BIG, more pieces left: "Shipped 02. Next: 03 — <name>. Run `/td-ship`."
- BIG, last piece: "Shipped final piece. Feature done. `.td/flow/` cleared."
- SMALL: "Fix shipped: <description>. Idle."

# Rules

- Tests must pass before commit. No exceptions.
- One commit per piece, no `wip` commits.
- Auto-push on success. No PRs, no branches, no force-pushes.
- Do not re-plan in this command. If scope changed, abort and use `/td-reset`.
