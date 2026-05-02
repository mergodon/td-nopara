---
description: Start a BIG flow — discuss, plan into small pieces, reality-check, lock the plan.
---

You are starting a BIG flow for a new feature. The argument is the feature name (kebab-case it if needed).

# Preconditions

- `.td/` exists. If not, abort: tell the user to run `/td-init` first.
- `.td/flow/` is empty or absent. If a flow is in progress (any files in `.td/flow/`), abort and tell the user to finish or `/td-reset` first.

# Step 1 — Discuss

Read `.td/PROJECT.md` and `.td/INBOX.md` first. If any inbox items match the feature being scoped (same surface, same component), surface them in this step:

> "Inbox has these related items: [list]. Should we fold any in?"

Then ask the user 3–5 bullet questions to scope the feature. Examples:

- What's the user-visible outcome of this feature in one sentence?
- What's the simplest version that ships value?
- What pages, routes, or surfaces does this touch?
- Any non-obvious constraints?
- How will we know it works (test angle)?

Wait for the user's answers. Then write `.td/flow/00-brief.md`:

```
# {{feature_name}} brief

Outcome: ...
Simplest version: ...
Surfaces: ...
Constraints: ...
Test angle: ...
```

# Step 2 — Plan

Break the feature into pieces. Each piece must be:

- ≤30 minutes of work (ideally ≤15)
- Describable in one sentence
- Has one obvious test
- Independently shippable

Write `.td/flow/plan.md` with the index:

```
# {{feature_name}} plan

01 — <one-sentence piece>
02 — <one-sentence piece>
03 — <one-sentence piece>
...
```

Then stub each piece as `.td/flow/01-<kebab>.md`, `.td/flow/02-<kebab>.md`, etc. with the piece template:

```
# {{NN}} {{piece_name}}

Goal: <one sentence>
Test: <one sentence — what proves it works>

## Plan
- step 1
- step 2

## Notes
(filled during execution)
```

# Step 3 — Reality check (do not skip)

Re-read `plan.md`. Print it back to the user with two questions, as bullets:

- Are we overcomplicating this? Anything we should drop or defer?
- Any piece too big? What can split further?

Wait for the user's answer. Apply changes. If pieces split, renumber sequentially (01, 02, 03 …).

If the user confirms ("ship it", "looks good", "let's go"), the plan is locked.

# Step 4 — Update STATE

Rewrite `.td/STATE.md`:

```
Project: <name>
Currently: feature → "{{feature_name}}"
Position: 01 of <N> — <piece-01-name>
Status: ready to ship
Last action: <YYYY-MM-DD> — feature planned, {{N}} pieces
Next: /td-ship piece 01
Blocker: none

## Open threads
(none)
```

# Step 5 — Tell the user

One-line summary: "Plan locked: {{N}} pieces. Run `/td-ship` to do piece 01."

# Rules

- Do not start coding in this command. This command only plans.
- Do not commit anything yet. The plan files in `.td/flow/` get committed as part of the first piece's `/td-ship`.
- If the user's answers reveal the feature is actually a SMALL fix, suggest `/td-fix` instead and abort cleanly.
- If inbox items get folded in, mark them clearly in `00-brief.md` so they get deleted from `INBOX.md` when the feature ships.
