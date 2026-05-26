# State

Project:  td-flow
Topic:    idle
Phase:    idle
Blocker:  none
Last:     2026-05-26 — shipped v6.0: all slash commands renamed `/td-*` → `/td-flow-*` (clean break, no aliases). install.sh prints a one-time v6 rename banner on first re-run when old-name symlinks are detected. 10 command files git-mv'd; 262 references bulk-updated across commands/contract/skill/README/FEEDBACK/templates/install.sh/smoke.sh/.td docs. Folded `/td-flow-complex-clear` into the canonical command list (10 commands, not 9 — pre-existing drift fixed in same commit). Live install + smoke clean (8 OK). Rebased on top of two concurrent fixes pushed mid-session: (a) /td-flow-complex-clear resume note "Resume — start here" leader block; (b) `hooks/pre-commit` xargs→sed trim that preserves quotes.

## Resume note

td-flow framework itself, settled. Ten slash commands now under the `/td-flow-*` namespace (matches the project name, GH slug, local path, contract file, skill). Contract delivered via one-line `@import` per project; pre-commit hook runs `scripts/smoke.sh` for mechanical sanity (now quote-preserving — sed instead of xargs after v5.5 fix). See PROJECT.md § Shipped v6.0 for the rename detail + migration path. Next session: pick up whatever the user brings.

Side-finding (unaddressed): td-flow's *own* `.git/hooks/pre-commit` is not installed, so commits to this repo don't auto-gate on smoke — run `scripts/smoke.sh` manually before committing here, or `cp hooks/pre-commit .git/hooks/ && chmod +x .git/hooks/pre-commit` to dogfood it.
