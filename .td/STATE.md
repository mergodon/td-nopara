# State

Project:  td-flow
Topic:    idle
Phase:    v4.8 shipped (2026-05-21)
Blocker:  none
Last:     2026-05-21 — shipped v4.8: removed the pre-work ride-along nudge from the contract.

## Resume note

td-flow is the public, file-based, repo-portable solo-dev framework at
`mergodon/td-flow` — and this repo is itself a td-flow project (eats its own
dogfood). Surface: root `CLAUDE.md` contract (mirrored byte-for-byte in
`templates/CLAUDE.md`), four standard `.td/` docs (PROJECT/WORKWAY/STATE/BACKLOG)
+ optional DEBUG + `work/<topic>.md` scratch, eight slash commands, and
`install.sh` symlinking it all into `~/.claude/`. Everything else is conversational.

Latest: v4.8 — removed the pre-work ride-along nudge ("anything else on your
mind that should ride along?") from the contract (`CLAUDE.md` + its
`templates/CLAUDE.md` mirror). As a turn-ending question it was indistinguishable
from a "task done, waiting on you" message — the user couldn't tell a finished
piece from a pre-work scope check. Preceding it, v4.7 — the ripple-check gate:
before shipping any commit (all types), trace each changed fact to everywhere
it's stated and fix stale spots in the same commit. `PROJECT.md § Shipped` has
the full history.

Nothing pending — 0 open issues, BACKLOG empty, no work files. Next session:
`/td-refresh` syncs a consuming project from canonical, `/td-init` bootstraps a
fresh one.
