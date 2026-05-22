# State

Project:  td-flow
Topic:    idle
Phase:    closed (2026-05-22)
Blocker:  none
Last:     2026-05-22 — closed v5.0.

## Resume note

td-flow now delivers its contract by `@import`: one canonical contract
(`~/projects/td-flow/CLAUDE.md`, linked to `~/.claude/td-flow-contract.md` by
`install.sh`), and every consuming project's `CLAUDE.md` is a one-line
`@~/.claude/td-flow-contract.md` import — no per-project copy, no drift.
`PROJECT.md § Shipped` has the full v5.0 arc; `git log` has the detail.

Outstanding (not blocking): a full `/td-init` + `/td-refresh`-migration UAT in a
throwaway project — the core `@import` mechanic is already proven live. Existing
td-flow projects still carry pre-import full-copy `CLAUDE.md` files; each migrates
onto the import the first time `/td-refresh` runs in it.

Next session: `/td-init` bootstraps a fresh project; `/td-refresh` syncs the
framework and migrates an existing project onto the imported contract.
