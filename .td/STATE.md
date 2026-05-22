# State

Project:  td-flow
Topic:    idle
Phase:    closed (2026-05-22)
Blocker:  none
Last:     2026-05-22 — role-played the /td-init + /td-refresh UAT; fixed framework commits to skip the pre-commit hook.

## Resume note

td-flow now delivers its contract by `@import`: one canonical contract
(`~/projects/td-flow/CLAUDE.md`, linked to `~/.claude/td-flow-contract.md` by
`install.sh`), and every consuming project's `CLAUDE.md` is a one-line
`@~/.claude/td-flow-contract.md` import — no per-project copy, no drift.
`PROJECT.md § Shipped` has the full v5.0 arc; `git log` has the detail.

The `/td-init` + `/td-refresh`-migration UAT was role-played 2026-05-22 in two
throwaway projects and passed — the `@import` mechanic, the installer, and the
legacy full-copy → import migration all work. One real gap was found and fixed:
the framework's own `chore: td-flow init` / `docs: migrate CLAUDE.md` commits now
commit `--no-verify`, so the pre-commit hook's `Test command` can't block them on
a project whose test env isn't ready.

Existing td-flow projects still carry pre-import full-copy `CLAUDE.md` files; each
migrates onto the import the first time `/td-refresh` runs in it.
