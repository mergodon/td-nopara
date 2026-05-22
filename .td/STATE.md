# State

Project:  td-flow
Topic:    contract-by-import
Phase:    v5.0 built — UAT + close remain
Blocker:  none
Last:     2026-05-22 — shipped v5.0: contract delivered by @import, not per-project copy.

## Resume note

v5.0 shipped (one commit) — the td-flow contract is delivered by `@import`, no
longer copied into each project. Plan record: `.td/work/contract-by-import.md`.

What shipped: `install.sh` links `~/.claude/td-flow-contract.md` → the canonical
contract; `templates/CLAUDE.md` is now a one-line `@~/.claude/td-flow-contract.md`
import; `/td-refresh` rewritten (pull + install + one-time legacy migration); the
`td:custom`/managed-file model removed from the contract; `/td-init`, README,
SKILL updated. The Step 0 gate passed — the import loads (verified live via
`/memory`: `td-flow-contract.md` showed `@-imported`).

Remaining before close: UAT — a full `/td-init` in a throwaway project, and a
`/td-refresh` migration of a legacy full-copy project. Then `/td-close` as v5.0
(it writes the § Shipped entry; v4.9's 7 commits fold into the v5.0 entry).
