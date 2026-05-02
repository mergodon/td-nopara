---
description: Run the local checks; if green, commit and push to origin/main. Use when the current piece is done and you want it live.
---

You are shipping the current piece. The contract is: tests pass → one commit → push to `origin/main`. Deploy follows automatically per `.td/WORKWAY.md` § Production / Ship.

# Step 1 — Confirm what's being shipped

Read `.td/STATE.md` to identify the current topic. Read `.td/work/<topic>.md` for the piece's goal and test angle. If no active topic, ask the user "what's being shipped?" and abort if they don't answer concretely.

# Step 2 — Run the local checks

Walk every checkbox in `.td/WORKWAY.md` § Local testing → Pre-ship checklist:

- Run `Test command`. Must exit 0.
- Run `Dev server` if listed and confirm it starts clean.
- Any manual local checks listed: actually do them (curl, browser via available tools, etc.). If a check requires the user (manual UAT step), surface it and pause for confirmation.

If any check fails: stop. Surface the failure as one line. Do not commit.

# Step 3 — Commit

One commit, explicit paths. No `git add -A`. Format from CLAUDE.md:

- Topic piece: `feat(<topic>): <one-line>` or `fix(<topic>): <one-line>`
- Bigger sweep that includes incidental cleanup: still one commit, format unchanged.

If the pre-commit hook fails, do not retry with `--no-verify`. Investigate, fix, re-stage, commit again.

# Step 4 — Push

```
git push origin main
```

If push is rejected (network, auth, divergence), surface the error and stop.

# Step 5 — Post-ship validation (if WORKWAY.md § Production has live checks)

If § Production / Ship lists smoke commands or live URLs: run the smoke command, hit the URL. If anything is wrong, surface it. Don't auto-fix — the user decides whether to roll back or patch forward.

If § Production / Ship is empty / "none" (e.g. local-only project): skip this step silently.

# Step 6 — Update STATE

Briefly: rewrite `.td/STATE.md` to reflect the new position. If this was the last piece of a topic, also update `.td/PROJECT.md` (Active scope → Shipped) and delete `.td/work/<topic>.md` — but **do not** do a full doc cleanup here; that's `/td-close`.

# Step 7 — Tell the user

One line: `Shipped <topic>: <one-line>. Pushed.` If post-ship validation surfaced anything, add it as a second line.

# Rules

- Tests pass before commit. No exceptions.
- One commit per ship. No `wip`, no `fix typo` follow-ups.
- Push to `origin/main` directly. No PRs.
- Don't replan in this command. If scope changed, abort and let the user redirect.
- Don't run the full doc-cleanup ritual here — that's `/td-close`.
