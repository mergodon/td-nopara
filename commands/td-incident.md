---
description: Live production fire mode. Drop everything else and focus on the broken thing. Sets STATE, opens a work file, surfaces DEBUG.md if exists.
---

You are entering live-fire mode for a production incident. Work in progress pauses — diagnosing and fixing this is the only thing that matters until it's resolved. Stay narrow. No refactors, no optimization, no "while we're here" cleanups.

# Step 0 — Verify we're in a td-flow project

Confirm `./.td/` exists. If missing, abort: "Not a td-flow project — `/td-incident` only runs inside a td-flow project."

# Step 1 — Ask what's broken

Ask the user: **"What's broken? One-line description."**

Wait for the answer. Keep it tight — capturing the headline, not the diagnostic. Detailed context comes in Step 5.

# Step 2 — Set STATE to incident mode

Update `.td/STATE.md` field block:

- `Topic:` `incident: <short slug of the one-liner>`
- `Phase:` `incident — on fire (<YYYY-MM-DD>)`
- `Blocker:` leave as-is (the previous topic's blocker — not relevant to the incident itself)
- `Last:` `<YYYY-MM-DD HH:MM> — incident opened: <one-liner>`

In Resume note, briefly note: "Production incident opened mid-session. Previous topic was <X>; resuming after incident closes." Preserve the previous Resume note content so we can pick up where we left off.

# Step 3 — Open a work file

Create `.td/work/incident-<slug>.md` with this template:

```
# Incident: <one-liner>

Opened: <YYYY-MM-DD HH:MM>
Status: open

## Symptom

<one-liner>

## Context

<filled in during Step 5>

## Hypothesis

<filled in during diagnosis>

## Fix

<filled in during fix>
```

# Step 4 — Surface DEBUG.md if it exists

If `./.td/DEBUG.md` exists, read it and surface the relevant sections — project-specific troubleshooting tools (Forge tail commands, Cloudflare cache invalidation, Sentry correlation chasing, etc.). One line to the user: "DEBUG.md found — pulling diagnostic tools for this project."

If `./.td/DEBUG.md` does **not** exist, tell the user: "No DEBUG.md yet. We'll capture useful diagnostics as we go and offer to save them at close-out." Continue.

# Step 5 — Walk the diagnosis

Help the user diagnose. Standard prompts (use the relevant ones):

- "What do you see? (logs, status pages, dashboards, user reports)"
- "When did it start? (correlate with recent deploys, crons, external events)"
- "What changed recently?" — run `git log --oneline -10` and surface
- "What's the blast radius? (one user, all users, one feature, the whole site)"

Use project-specific tools from DEBUG.md where relevant. **Read-only on production by default** — diagnostics (tail logs, list issues, query DB read-only) yes, mutations (restart workers, purge cache, rollback, migrate) only with explicit go-ahead.

Update the work file's Context and Hypothesis sections as the picture firms up. The work file is the durable record of this incident.

# Step 6 — Resolution

The incident ends in one of three ways:

**(a) Fixed in this session.**

1. Apply the fix (confirm with user before code edits).
2. Run pre-ship checks per project's `WORKWAY.md § Local testing`. If there's a live URL, smoke after deploy.
3. Commit: `fix(<area>): <one-line>` with a body that includes Symptom → Root cause → Fix (matching the work file structure).
4. Push.
5. Ask: **"Anything worth saving to `DEBUG.md`?"** If yes, capture — creates the file if not present. Include the symptom that took you there, the diagnostic path that worked, and any tool-specific tricks (Sentry correlation ID, Forge log path, etc.).
6. Reset STATE: Topic back to previous (or `idle`); Phase reflects what's now active; `Last:` notes incident closed.
7. Fold-and-delete the work file in the same commit (per the contract's fold-and-delete rule).

**(b) Too big for this session — park to GitHub.**

1. Create a GH issue in the current repo with Issue Type = `Bug`:
   - Title: the one-liner
   - Body: contents of the work file (Symptom, Context, Hypothesis, what was tried)
   - Use `gh api graphql` to create with `Bug` type attached (the org's Bug type ID is cached in this skill or queried once per run).
2. Update `STATE.Last` to note the incident parked to GH `#N`.
3. Delete the local work file (the GH issue is now the source of truth).
4. Commit + push STATE update.

**(c) Actually another repo's problem — file cross-repo.**

1. Per `CLAUDE.md § Cross-repo`: check `.td/PROJECT.md § Cross-repo` for the target repo. If not listed, ask the user before filing.
2. `gh api graphql` mutation to create issue in `<other-repo>` with Type = `Bug`, body opening with `**From:** <this-project-friendly-name>` followed by Symptom/Context/Hypothesis from the work file.
3. Update `STATE.Last`.
4. Delete the local work file.
5. Commit + push.

# Step 7 — Tell the user

One sentence per resolution path:

- (a) `Fixed. Pushed <sha>. <DEBUG.md updated | DEBUG.md unchanged>. Back to <previous topic | idle>.`
- (b) `Parked to GitHub as <repo>#<N> (Type: Bug). Local work file removed.`
- (c) `Filed cross-repo against <slug>#<N> (Type: Bug). Local work file removed.`

# Rules

- **No scope creep.** Refactors, optimizations, "while we're here" cleanups — surface them in the work file's Context or as backlog items; do not act during incident mode.
- **Read-only on production by default.** Mutations (restart, purge, rollback, migrate) require explicit user go-ahead per command.
- **Always confirm before posting** to GH, committing, or pushing.
- **STATE updates land in the same commit as the fix** (existing `feat:`/`fix:` contract rule).
- **Capture for DEBUG.md as you go**, not just at close-out. If a useful diagnostic command or non-obvious gotcha surfaces, ask "save this to DEBUG.md?" right then — small captures during the incident beat trying to reconstruct at the end.
- **Incident mode is exclusive.** Don't switch the conversation back to the previous topic until resolution is complete. The user can break this with an explicit "pause the incident."
