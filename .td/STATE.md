# State

Project:  td-flow
Topic:    idle
Phase:    v4.6 shipped (2026-05-21)
Blocker:  none
Last:     2026-05-21 — v4.6 scoped to single-project; fleet-mode references dropped.

## Resume note

td-flow is the public, file-based, repo-portable solo-dev framework at
`mergodon/td-flow` — and this repo is itself a td-flow project (eats its own
dogfood). Surface: root `CLAUDE.md` contract (mirrored byte-for-byte in
`templates/CLAUDE.md`), four standard `.td/` docs (PROJECT/WORKWAY/STATE/BACKLOG)
+ optional DEBUG + `work/<topic>.md` scratch, eight slash commands, and
`install.sh` symlinking it all into `~/.claude/`. Everything else is conversational.

Latest: v4.6 — `/td-health`, a proactive production health check and the
proactive twin of `/td-incident`. Generic command, project-owned `.td/health.sh`
script; the fixed contract is just the protocol (exit 0/1/2, OK/WARN/FAIL lines)
so the command hardcodes no checks. First run scaffolds the script (drafted from
`WORKWAY § Live` + `PROJECT § Stack`) or marks the project non-production via an
opt-in `PROJECT.md § Health` section. WARN → park to BACKLOG; FAIL → escalate to
`/td-incident`. Single-project scope by design — no cross-project sweep.
`PROJECT.md § Shipped` carries the version history.

Nothing pending — 0 open issues, BACKLOG empty, no work files. Next session:
`/td-refresh` syncs a consuming project from canonical, `/td-init` bootstraps a
fresh one.
