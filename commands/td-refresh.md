---
description: Review and apply deltas between this project's CLAUDE.md and canonical at ~/projects/td-flow/CLAUDE.md. Diff-and-propose, never auto-overwrite.
---

You are reviewing this project's `CLAUDE.md` against the canonical at `~/projects/td-flow/CLAUDE.md`. The canonical drifts forward over time; project copies fall behind. Your job: surface every deviation, propose what to take, never auto-overwrite. The user owns `CLAUDE.md` — your role is to make the deltas reviewable, one section at a time.

# Step 0 — Verify we're in a td-flow project

- Confirm `./CLAUDE.md` and `./.td/` exist. If either is missing, abort: "Not a td-flow project — `/td-refresh` only runs inside a td-flow project."
- Confirm `~/projects/td-flow/CLAUDE.md` exists. If missing, abort: "Canonical not found at `~/projects/td-flow/CLAUDE.md`. Is td-flow installed?"

# Step 1 — Quick equality check

Compare the two files. If they match byte-for-byte, tell the user "Already in sync — no deltas to review." and exit.

# Step 2 — Split into sections

Both files are organized by `##` headings. Split each into ordered `(heading, body)` pairs. Treat the preamble (content before the first `##`) as its own section keyed `_preamble`.

# Step 3 — Categorize each section

For each section, compare local vs canonical and bucket it:

- **clean** — local matches canonical (ignore whitespace-only differences).
- **canonical-newer** — local looks like an older copy of canonical; canonical has changes local doesn't have.
- **local-has-additions** — local contains content not in canonical. Likely intentional project-specific drift.
- **genuinely-diverged** — both sides have non-trivial changes. Needs the user's eye.
- **missing-locally** — section exists in canonical, not in local → treat as canonical-newer.
- **missing-in-canonical** — section exists in local, not in canonical → treat as local-has-additions.

# Step 4 — Report the shape

Before walking individual sections, print one compact summary:

```
N sections clean ✓
N sections canonical-newer:    <heading-list>
N sections local-has-additions: <heading-list>
N sections genuinely-diverged:  <heading-list>
```

If everything came out clean after whitespace normalization, say "Differences are whitespace-only — no semantic deltas." and exit without changes.

# Step 5 — Walk the non-clean sections

For each non-clean section, in document order, present:

1. The heading.
2. The category.
3. The diff — pick the right format for the size: inline prose for tiny tweaks, `diff` style for larger blocks.
4. A recommendation:
   - **canonical-newer** → recommend "take canonical."
   - **local-has-additions** → recommend "keep local," explain why you think it's intentional drift.
   - **genuinely-diverged** → no default; ask the user.
5. Wait for one of: `take canonical` / `keep local` / `show me both` / `skip for now` / a freeform instruction.

Apply choices as you go. Don't batch — apply each accepted change before moving to the next section so the working file always reflects the user's current accepted state.

If the user says "take all canonical sections" or similar bulk accept, confirm once, then apply all `canonical-newer` sections in one pass. Still walk `genuinely-diverged` and `local-has-additions` individually — bulk-accept doesn't apply to ambiguous categories.

# Step 6 — Commit (only if something changed)

If any sections were updated:

```
git add CLAUDE.md
git commit -m "docs: refresh CLAUDE.md from canonical"
```

If the user kept everything local: "Reviewed N sections, nothing accepted. No commit."

Do **not** push automatically. `/td-refresh` is doc-hygiene; the user pushes when they're ready alongside other work.

# Rules

- Never overwrite `CLAUDE.md` without an explicit per-section accept (or bulk-accept) from the user.
- Never auto-merge sections the user didn't review.
- Don't propose deltas for whitespace-only differences.
- If you can't read the canonical (missing, permission), stop and tell the user — don't guess what it should say.
- This command only touches root `CLAUDE.md`. It does not modify `.td/*`, `~/.claude/*`, or anything else.
- This is a `docs:` commit per `CLAUDE.md § Commit messages`, so the pre-commit `Test command` is exempt.
