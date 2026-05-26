---
description: Live production fire mode. Drop everything else and focus on the broken thing. Snapshots any in-flight work first (so nothing is lost), sets STATE to incident mode, opens a work file, surfaces DEBUG.md if exists.
---

You are entering live-fire mode for a production incident. Work in progress pauses — diagnosing and fixing this is the only thing that matters until it's resolved. Stay narrow. No refactors, no optimization, no "while we're here" cleanups.

This command is a **composition**, not a bespoke pivot. Step 1 invokes `/td-flow-snapshot` to preserve any in-flight piece (branch + GH Snapshot issue, fully resumable). Then we set incident-mode STATE on clean main. After the fix ships, the previous work is one `git checkout snapshot/<slug>` away.

# Step 0 — Verify we're in a td-flow project

Confirm `./.td-flow/` exists. If missing, abort: "Not a td-flow project — `/td-flow-incident` only runs inside a td-flow project."

# Step 1 — Snapshot any in-flight piece

Read `.td-flow/STATE.md`. Parse `Topic:` line.

- **If `Topic != idle`:** invoke `/td-flow-snapshot incident-pivot` inline (run its full procedure). This commits any uncommitted work to `snapshot/<previous-slug>`, files a Snapshot-type GH issue with the resume command, switches back to main (or wherever you were), resets STATE to idle, pushes. Nothing is lost.
- **If `Topic == idle`:** skip. Nothing to preserve. Proceed to Step 2 on the already-clean main.

This single step replaces the old `/td-flow-incident`'s bespoke "preserve previous topic as a pointer in Resume note" mechanic — the mechanic that caused the #11 failure mode by preserving pointers instead of the actual content.

# Step 2 — Capture what's broken

If `/td-flow-incident` was invoked with an argument (e.g. `/td-flow-incident login is 500ing`), use the argument as the one-liner. Otherwise — and only otherwise — ask: **"What's broken? One-line description."** and wait.

Keep it tight — the headline, not the diagnostic. Detailed context comes in Step 5.

# Step 3 — Set STATE to incident mode

Slugify the one-liner (kebab-case, 3–5 words, lowercase ASCII). Hold as `<incident-slug>`.

Rewrite `.td-flow/STATE.md`:

```
# State

Project:  <project-name>
Topic:    incident: <incident-slug>
Phase:    incident — on fire (<YYYY-MM-DD>)
Blocker:  none
Last:     <YYYY-MM-DD HH:MM> — incident opened: <one-liner>.

## Resume note

Production incident: <one-liner>. Work file at `.td-flow/work/incident-<incident-slug>.md`. <if prior snapshot in Step 1: "Previous piece snapshotted as #<N> on `snapshot/<previous-slug>` — resume via the issue's resume command after the incident closes.">
```

Don't commit yet — the work file is the next thing to create, and STATE + work file land together with the eventual fix.

# Step 4 — Open the incident work file

Create `.td-flow/work/incident-<incident-slug>.md`:

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

# Step 5 — Surface DEBUG.md if it exists

If `./.td-flow/DEBUG.md` exists, read it and surface the relevant sections — project-specific troubleshooting tools (Forge tail commands, Cloudflare cache invalidation, Sentry correlation chasing, etc.). One line to the user: "DEBUG.md found — pulling diagnostic tools for this project."

If `./.td-flow/DEBUG.md` does **not** exist, tell the user: "No DEBUG.md yet. We'll capture useful diagnostics as we go and offer to save them at close-out." Continue.

# Step 6 — Walk the diagnosis

Help the user diagnose. Standard prompts (use the relevant ones):

- "What do you see? (logs, status pages, dashboards, user reports)"
- "When did it start? (correlate with recent deploys, crons, external events)"
- "What changed recently?" — run `git log --oneline -10` and surface
- "What's the blast radius? (one user, all users, one feature, the whole site)"

Use project-specific tools from DEBUG.md where relevant. **Read-only on production by default** — diagnostics (tail logs, list issues, query DB read-only) yes, mutations (restart workers, purge cache, rollback, migrate) only with explicit go-ahead.

Update the work file's Context and Hypothesis sections as the picture firms up. The work file is the durable record of this incident.

# Step 7 — Resolution

The incident ends in one of three ways:

**(a) Fixed in this session.**

1. Apply the fix.
2. Run pre-ship checks per project's `WORKWAY.md § Local testing`. If there's a live URL, smoke after deploy.
3. **Single capture prompt:** ask **"Anything from this fire worth keeping? (`debug: <text>` / `backlog: <text>` / `no`)"**. Route by prefix — the user just fought a fire, one decision point is enough. Multiple prefixes per response are OK (one per line). What each routes to:
   - `debug:` → append to `.td-flow/DEBUG.md` under the right section (symptom → diagnostic / gotchas / production commands per content). Create from template if missing.
   - `backlog:` → append to `.td-flow/BACKLOG.md` (follow-up work surfaced during the fire — not the fire itself).
   - `no` → continue.
4. Reset STATE: `Topic: idle`, `Phase: idle`, `Last:` notes incident closed. If a previous snapshot was taken in Step 1, mention in Resume note: "Previous piece on `snapshot/<previous-slug>` (#<N>) is ready to resume."
5. Fold-and-delete the incident work file (per the contract's fold-and-delete rule).
6. Commit it all as one commit: the fix + STATE reset + work-file deletion (+ DEBUG.md/BACKLOG.md if captured). `fix(<area>): <one-line>`, body including Symptom → Root cause → Fix.
7. Push.

**(b) Too big for this session — park to GitHub.**

1. Create a GH issue in the current repo with Issue Type = `Bug`:
   - Title: the one-liner
   - Body: contents of the work file (Symptom, Context, Hypothesis, what was tried)
   - Use `gh api graphql` to create with `Bug` type attached (query the org's Issue Type IDs once per run — same as `/td-flow-park` Step 2 — never hardcode them).
2. Update `STATE.Last` to note the incident parked to GH `#N`. Reset Topic to idle.
3. Delete the local work file (the GH issue is now the source of truth).
4. Commit + push STATE update.

**(c) Actually another repo's problem — file cross-repo.**

1. Per `CLAUDE.md § Cross-repo`: check `.td-flow/PROJECT.md § Cross-repo` for the target repo. If not listed, ask the user before filing.
2. `gh api graphql` mutation to create issue in `<other-repo>` with Type = `Bug`, body opening with `**From:** <this-project-friendly-name>` followed by Symptom/Context/Hypothesis from the work file.
3. Update `STATE.Last`. Reset Topic to idle.
4. Delete the local work file.
5. Commit + push.

# Step 8 — Tell the user

One sentence per resolution path:

- (a) `Fixed. Pushed <sha>. <Captured: DEBUG | BACKLOG | nothing>. STATE idle. <if previous snapshot: "Previous piece resumable from snapshot/<previous-slug> (#<N>).">`
- (b) `Parked to GitHub as <repo>#<N> (Type: Bug). Local work file removed.`
- (c) `Filed cross-repo against <slug>#<N> (Type: Bug). Local work file removed.`

# Rules

- **Snapshot before pivot is non-negotiable.** If STATE.Topic isn't idle, Step 1 always runs. No "preserve as a pointer" — we commit it to a branch + file a tracker. The #11 failure mode lived in pointer-preservation; this command no longer does that.
- **No scope creep.** Refactors, optimizations, "while we're here" cleanups — surface them in the work file's Context or as backlog items; do not act during incident mode.
- **Read-only on production by default.** Mutations (restart, purge, rollback, migrate) require explicit user go-ahead per command.
- **Confirm before posting to GH** (cross-repo or in-repo issue creation). Commits and pushes follow the normal rhythm — don't add an extra gate during a fire.
- **STATE updates land in the same commit as the fix** (existing `feat:`/`fix:` contract rule).
- **DEBUG.md capture happens at close-out** (Step 7's single capture prompt). Don't interrupt the fire with mid-stream "save this?" asks.
- **Incident mode is exclusive.** Don't switch the conversation back to a previous topic until resolution is complete. The user can break this with an explicit "pause the incident."
- **Resume of the previous piece is the user's choice, not auto.** After the incident ships, STATE goes idle. The previous piece lives on its snapshot branch + GH Snapshot issue; the user resumes when they want (via `/td-flow-mailbox` or direct `git checkout`).
