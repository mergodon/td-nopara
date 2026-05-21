# State

Project:  td-flow
Topic:    idle
Phase:    v4.7 shipped (2026-05-21)
Blocker:  none
Last:     2026-05-21 — shipped v4.7: the ripple-check gate; fixed a stale README example.

## Resume note

td-flow is the public, file-based, repo-portable solo-dev framework at
`mergodon/td-flow` — and this repo is itself a td-flow project (eats its own
dogfood). Surface: root `CLAUDE.md` contract (mirrored byte-for-byte in
`templates/CLAUDE.md`), four standard `.td/` docs (PROJECT/WORKWAY/STATE/BACKLOG)
+ optional DEBUG + `work/<topic>.md` scratch, eight slash commands, and
`install.sh` symlinking it all into `~/.claude/`. Everything else is conversational.

Latest: v4.7 — the ripple-check gate, a new `CLAUDE.md` section. Before shipping
any commit (all types, no exemptions), read the whole-surface docs (`README.md`
+ `.td/`) and trace each changed fact to everywhere it's stated, fixing stale
spots in the same commit. Born from a v4.6 miss: a keyword grep skipped a stale
README example. Preceding it, v4.6 — `/td-health`, the proactive twin of
`/td-incident`: generic command, project-owned `.td/health.sh`, exit-0/1/2
protocol, single-project scope. `PROJECT.md § Shipped` has the full history.

Nothing pending — 0 open issues, BACKLOG empty, no work files. Next session:
`/td-refresh` syncs a consuming project from canonical, `/td-init` bootstraps a
fresh one.
