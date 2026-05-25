---
description: Rigorous mid-project checkpoint for complex multi-day work. Enhanced version of /td-clear with required STATE sections, self-validation, and explicit handoff scaffolding. Use when /td-clear isn't enough (multi-phase work, lots of in-flight decisions, partial deliverables, external dependencies). Project continues — this is a checkpoint, not a wrap.
---

You are checkpointing a complex session where standard `/td-clear` is too loose. The user wears this command when the work spans multiple phases, decisions, partial human-in-loop deliverables, parallel runs, or external dependencies — situations where a state-of-the-world dump misses operational substance (who-does-what-next, what's-running-now, what-disappears-on-reboot).

Same baseline rhythm as `/td-clear` (steps 1–6, 8, 9). The differences are **Step 7** (STATE rewrite — now structurally enforced), **Step 7.5** (self-validation gate), and an expanded **Step 5** (capture decisions + conversation-only context).

# Step 1 — Update memory

Identical to `/td-clear` Step 1. Scan the session for things worth keeping in the auto-memory system. Update existing memory files rather than creating duplicates.

# Step 2 — Audit current state

Identical to `/td-clear` Step 2. Read `.td/STATE.md`, `.td/work/` listing, `.td/PROJECT.md`. Check `git status --short` and `git log origin/main..HEAD --oneline`. Working tree must be clean before proceeding.

# Step 3 — Quick code sanity check

Identical to `/td-clear` Step 3. Skim recent changes for accidentally committed secrets or obvious leftovers. Don't refactor.

# Step 4 — Squash local-only commits (if any)

Identical to `/td-clear` Step 4.

# Step 5 — Capture BACKLOG + conversation-only context

Two sub-steps:

**5a. Backlog**: ask the user "Anything to add to the backlog before we clear?" — same as `/td-clear`.

**5b. Conversation-only context** (new, REQUIRED): scan the session for **decisions whose rationale lived only in chat, not in any committed doc**. Common patterns:

- "We chose X over Y because Z" — the *because Z* is the load-bearing part.
- Course corrections — "originally I tried A; switched to B when we discovered C."
- Clarifications the user gave conversationally that overrode an earlier doc.
- Why a small piece of code or data was *intentionally* left in a non-obvious state.
- Wrong-path findings worth noting so we don't repeat the mistake.

These don't belong in BACKLOG (they're not future work) but they DO belong in STATE — under a "Conversation-only context" section in the resume note. **List them silently first, then add as one paragraph or bullet list in Step 7.**

# Step 6 — Light prune + handoff signals

Identical to `/td-clear` Step 6. Walk `.td/` for stale topic files, resolved blockers, shipped backlog lines. Fetch the mailbox snapshot. Fire the drift heads-up if a stack file changed.

# Step 7 — Write a structured STATE handoff

Rewrite `.td/STATE.md` so a fresh conversation picks up cold. The next context will load this and assume it's true.

**The /td-complex-clear contract is stricter than /td-clear.** STATE.md must have the structured sections below. Length is not capped — write what's needed, not less.

### Top section (field-shaped, same as /td-clear)

```
Project:  <name>
Topic:    <current topic, or "idle">
Phase:    <whatever describes where we are — pick a word that fits>
Blocker:  <one-line if any, else "none">
Last:     <YYYY-MM-DD HH:MM> — <one-line summary>
```

### Resume note (free-form prose: a lead block, then REQUIRED sections)

The resume note **opens with the "Resume — start here" block**, then the detailed sections. Cover every applicable section below in approximately the listed order; skip one only if it genuinely doesn't apply — but say so out loud ("§ X N/A this session").

**Lead block — REQUIRED, must be physically FIRST in the resume note (before § 1):**

- **Resume — start here.** The single first-action pointer ("the very next thing to do on resume", one sentence), followed by the ordered first 2–4 steps the next session should take. If a `.td/work/<topic>.md` section (or any other doc) must be read on resume, **name it here explicitly** — don't assume the reader reaches a later section. A fresh reader scans the top fields, then this block, and must know exactly what to do, by whom, in what order, *without reading further*. Everything below is reference; this block is the entry point.
- **Why it leads, not trails:** a first-action pointer placed at the bottom of a long handoff gets skipped — the reader forms the gist from the top sections and stops. Putting the next step where the eye lands first is the whole point of the structured handoff. Do not bury it.

**Required sections — these are the contract (in approximately this order, after the lead block):**

1. **Mailbox snapshot** (from Step 6) — at the top.
2. **Heads-ups block** (from Step 6) — only if drift fired.
3. **Current phase / state-of-play** — what we've been doing + why.
4. **Decisions LOCKED this session** — one line each, with *why* / who decided. Include any reasoning that lived only in conversation (from Step 5b).
5. **Pending action list — full, by owner**:
   - `A` (user) actions — what the user needs to do, with `effort` + `blocks` per item
   - `B` external waits — what / from whom / ETA expectation
   - `C` next-session Claude actions — sequenced in dependency order; group as C1, C2... if multi-phase
   - `D` parked (BACKLOG) — what's not in scope for the immediate next session but worth listing as a one-liner referring to BACKLOG.md
   - `E` post-launch / longer-horizon — if applicable
6. **Dependency graph / critical path** — even a text-ASCII sketch. Shows what blocks what; what can run in parallel. Should make the critical path to "ship" obvious.
7. **Background / in-flight processes** — what's running on the machine right now (PIDs / commands / owners — `ps -ef | grep <relevant>`). Flag anything stateful that future-Claude shouldn't kill.
8. **Volatile artifacts** — table of paths NOT git-tracked + what each holds + recovery cost if lost. Flag the highest-recovery-cost item explicitly + recommend protection step ("snapshot to ~/").
9. **Credentials state** — anything rotated this session, anything still pending rotation, anything that LEAKED (chat / log / public). Be explicit.
10. **Authoritative paths** — every relevant artifact location (plans, audits, staging, seeds, data dirs).
11. **Cumulative spend + budget marker** (if money is being spent on LLM calls / external APIs) — current total + budget cap or "no cap stated."
12. **Safe-without-asking vs needs-approval boundary** — explicit list of operations the next session can do autonomously vs ones that need the user's nod. Include "NEVER do" items (e.g. touch prod, force-push, skip pre-commit hook).
13. **Conversation-only context** (from Step 5b) — decisions / clarifications / wrong-path findings whose *why* lived only in chat. Captured here so they survive `/clear`.

The first-action pointer and the ordered first steps both live in the **Resume — start here** lead block above — do not also scatter them into trailing sections.

**Tone**: write so a fresh-context Claude can pick up cold. Complete sentences. No "see above" — each section is self-contained and may be read in any order. The one ordering rule: the **Resume — start here** lead block is physically first.

**Length**: no cap. 300-500+ lines is fine for a 2-day complex session.

# Step 7.5 — Self-validation gate (new)

Before declaring done, the model must answer these four questions internally, **out loud in the response to the user**:

1. "If I were a fresh Claude reading only this STATE.md, would I know EXACTLY what to do first, by whom, in what order?"
2. "Are there decisions the user is waiting on that I have not surfaced in the action list?"
3. "Are there volatile artifacts (in /tmp/, in process memory, in conversation only) that might disappear before next session?"
4. "Is there anything in *this conversation* whose rationale is NOT in committed docs?"

If any answer is "no" (for Q1) or "yes — and not captured" (for Q2/Q3/Q4), the STATE is incomplete. **Iterate before continuing to Step 8.** Do not push a STATE that fails its own self-validation.

When all four answers are "yes / no respectively, all captured", surface the self-validation block to the user in the final response so they can see the gate passed.

# Step 8 — Push

```
git push origin main
```

If push is rejected (network, auth, divergence), surface the error and stop.

# Step 9 — Tell the user

Two lines:

```
Cleared. <N> commits pushed. STATE handoff written (<line-count> lines).
Self-validation: Q1 ✓ Q2 ✓ Q3 ✓ Q4 ✓. Safe to /clear.
```

# Rules (same as /td-clear, plus)

- Working tree must be clean before pushing.
- Never force-push. Squashing is for local-only commits.
- Don't run the full doc audit — that's `/td-close`. Stay focused on handoff.
- **The structured sections in Step 7 are not optional.** A `/td-complex-clear` STATE that's missing the **Resume — start here** lead block, the action list, the dependency graph, or the volatile-artifacts table is not done. Iterate.
- **The self-validation in Step 7.5 must be surfaced to the user** in the final response. Don't quietly self-pass — make the gate visible.
- If the session genuinely doesn't have material for a required section (e.g. no LLM spend, no volatile artifacts), say "§ X N/A this session" explicitly rather than skipping silently.
- This skill is heavier than `/td-clear` by design — use it when the complexity warrants the rigor. Simple sessions stick with `/td-clear`.

# When to use which

- **`/td-clear`**: single-topic session, decisions captured in commits, no partial human-in-loop deliverables, no volatile artifacts, no parallel runs. Fast.
- **`/td-complex-clear`**: multi-phase session, decisions taken conversationally (not all in commits), partial deliverables awaiting external input, volatile state on disk, parallel work streams, multiple owners involved. Slower but produces a handoff that survives complexity.
