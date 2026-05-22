# v4.9 — managed contract + a quieter framework

Planning scratch. Ship as a sequence of commits, close as v4.9.
Triggered 2026-05-22 by: "/td-refresh is annoying" + nudge-pollution feedback.

## Goal

The framework talks when it doesn't need to. `/td-refresh` can't tell intentional
project drift from staleness, so it asks. The startup nudge surfaces Ideas nobody
asked about. Fix both — and make doc ownership explicit so refresh just works.

## Research (2026-05-22) — three established patterns, no reinvention

- **Generated-file header** (Go `DO NOT EDIT`, protobuf, OpenAPI codegen):
  one-line declaration that a file is tool-managed.
- **Managed block / blockinfile** (Ansible `BEGIN/END ANSIBLE MANAGED BLOCK`):
  tool owns a fenced region, user owns the rest, idempotent re-write.
- **Editable regions** (Dreamweaver/CloudCannon templates): template locks
  everything; marked regions are user-editable. `<!-- TemplateBeginEditable -->`.

Verdict: CLAUDE.md is ~100% framework-owned → treat as a managed file (header)
with ONE editable region (`td:custom`) for project carve-outs. YAML frontmatter
considered for STATE's field block — declined: td-flow has no parser, Claude
reads the block fine, it'd be complexity with no user-visible payoff.

## Piece 1 — Managed-file header + td:custom region ✓ shipped

CLAUDE.md gets a top-of-file managed header (HTML comment) + one editable region:

```
<!-- td-flow contract — managed by /td-refresh. Project content lives in .td/.
     To add a project-only rule, wrap it in the td:custom region below. -->
# How we work in this repo
...
<!-- td:custom -->
  (project's own rules, if any — /td-refresh never touches between these)
<!-- /td:custom -->
```

- `td:custom` is XML-namespace syntax (`prefix:name`) — closing tag `/td:custom`.
- `td:scratch` (remove-at-close region) considered and DROPPED — work files
  already cover whole-file scratch; an in-doc marker is surface area for a rare
  problem. Flagged to the user; re-add if a real need shows up.
- Implemented as a managed-file *preamble* (prose), not a separate HTML-comment
  header — the preamble is read every session anyway, so it carries the statement.
- Canonical CLAUDE.md: short section documenting the convention.
- templates/CLAUDE.md: mirror (header + empty td:custom region is fine here —
  templates/CLAUDE.md is already maintained as conceptually distinct).
- Drift signal "root CLAUDE.md differs from canonical" → "differs OUTSIDE the
  td:custom region."

Commit: feat(markers): managed-file header + td:custom region

## Piece 2 — /td-refresh: take-canonical-and-resplice ✓ shipped (+ trimmed to framework-sync, post-review)

- Phase 0: auto-pull when behind + ff-only + clean tree (already the only case
  it pulls — stop asking). Dirty/diverged → skip + note.
- Phase 1: DELETE the section-categorizer (Steps 2-6: clean / canonical-newer /
  local-has-additions / genuinely-diverged). Replace with: extract the project's
  td:custom region → take canonical wholesale → splice td:custom back → write.
  The "genuinely-diverged, needs your eye" bucket — gone; project content is now
  fenced and unambiguous. The no-push `docs: refresh` commit is the review gate.
  ONE interactive case: first refresh on a legacy project whose CLAUDE.md
  diverges with no td:custom fence → one-time migration prompt ("fence what you
  want to keep, I take canonical for the rest"). After that, every refresh is clean.
- Phase 2: BACKLOG non-empty → straight into /td-park digest; drop the redundant
  yes/no/show-me pre-gate.
- Phase 3: cross-repo drift — surface only (a) observed-not-declared, or
  (b) declared-not-observed AND bare (no `—` context). Declared-with-context →
  silent. Kills the "Recommendation: keep" noise.
- Common case: sync → resplice → "done, registry in sync." Zero questions.

Ripple: frontmatter description, CLAUDE.md slash-command line ("4 phases,
diff-and-propose"), README /td-refresh row + "Updating an existing td-flow
project" section.

Commit: feat(refresh): take-canonical-and-resplice Phase 1

## Piece 3 — Nudge scoping (Ideas/Epics quiet unless asked) ✓ shipped

- Fresh-session nudge: surface open Bugs + Tasks only. Ideas + Epics not surfaced
  unprompted. Type-aware query needed — GraphQL like /td-mailbox Step 2, or
  `gh issue list --type` if it exists (VERIFY at build).
- /td-clear Step 6 snapshot: count + break down Bug/Task only; drop Idea/Epic.
- /td-close Step 2 gate: already Bug/Task-only — verified, no functional change.
- Ripple: CLAUDE.md § Nudges, § Where things go ("any incoming?"), README
  startup-nudge mentions + quick-fix scenario.

Commit: feat(nudges): scope unprompted inbox surfacing to Bug/Task

## Piece 4 — Idea → Task promotion ✓ shipped

- /td-mailbox inbound vocabulary gains `promote N` — converts Idea #N to Task.
- /td-mailbox Step 8 `start`: target is an Idea → promote to Task first
  (starting work = committed work). Same shape as the Epic→children redirect.
- Conversational route "show me the ideas" / "review ideas" → Idea-filtered digest
  + promote. Document in CLAUDE.md § Where things go. Lives in /td-mailbox —
  consistent with "Ideas surface during /td-mailbox."
- Conversion mechanism: GraphQL — VERIFY exact mutation (`updateIssue` with
  `issueTypeId`, or `updateIssueIssueType`) via context7/GH docs at build.
- Ripple: CLAUDE.md § Where things go, /td-mailbox actions list + Step 8,
  README scenario + Issue Types section.

Commit: feat(mailbox): Idea→Task promotion

## Piece 5 — Drop GSD legacy migration ✓ shipped

We are td-flow; GSD migration shipped in v3 and is dead code now.
- commands/td-init.md: remove the "GSD-1 / GSD legacy detected" branch; reword
  the brownfield branch's `(and not GSD)` parenthetical.
- skill/SKILL.md: remove "GSD-style legacy planning conventions" from the
  migration sentence.
- .td/PROJECT.md § Out of scope: drop "(the gsd-2 mistake)" attribution, keep
  the rule (matches README's wording).
- .td/PROJECT.md v3 Shipped entry: KEEP "GSD legacy migration" — accurate
  history; the v4.9 entry records the removal.
- Aside (user's call): the td-flow-v2 migration branch in /td-init is the same
  kind of legacy dead code — drop too?

Commit: chore: drop GSD legacy migration

## Deferred (park as Idea after v4.9, not v4.9 scope)

Reconcile `.td/`-doc STRUCTURE (heading set) against templates when the framework
adds a mandatory section — real gap today, but new scope + risk. Editable-region
pattern applies (headings self-delineate the regions), but defer.

## Post-plan additions (this session)

- /td-refresh trimmed to framework-sync only (folded into Piece 2 above).
- /td-clear gained a session doc-sync — syncs PROJECT/WORKWAY to the session,
  not just STATE. Old stack-drift flag-no-fix replaced by fixing it; the vacated
  `## Heads-ups` block mechanism removed.

## Close

chore: close v4.9 — PROJECT.md § Shipped entry, STATE to closed, full ripple check.

## Calls made (correct me)

- Ship as v4.9, sequence of commits, one work file — NOT an Epic.
- CLAUDE.md becomes a managed file (header + one td:custom region); the user
  controls `.td/` + td:custom, td-flow manages the rest. Strengthens the
  existing "user controls it" intent (asserts it against Boost/Cursor), not against it.
- Keep td:scratch though its use is narrow.
- Idea-review lives in /td-mailbox, not a new command.
- v3 Shipped entry's GSD mention stays (accurate history).

## Build order

1 (header+region) → 2 (refresh, depends on 1). 3, 4, 5 independent — any order.
Piece 5 is quick and unblocked — good warm-up.
