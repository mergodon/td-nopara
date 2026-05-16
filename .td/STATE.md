# State

Project:  td-flow
Topic:    idle
Phase:    shipped (2026-05-16)
Blocker:  none
Last:     2026-05-16 — v3.6 shipped: td-bus (cross-project messaging via Turso/libsql). Single-file Python CLI at `bin/td-bus`, schema in `bus-schema.sql`, opt-in onboarding via `/td-bus-init`, README rewrite, installer wires `~/bin/td-bus`. Creds resolve env-first with `~/.td/bus.env` fallback. Four real apps registered on the live bus: anzscofinder, anzscofinder-pipeline, rgb-buddy, rgb-webapp.

## Resume note

td-flow is the minimal, file-based, repo-portable framework hosted at `mergodon/td-nopara`. It eats its own dog food — this repo IS a td-flow project. Stable surface: root `CLAUDE.md` contract + 4 `.td/` docs (`PROJECT`, `WORKWAY`, `STATE`, `BACKLOG`) + `work/<topic>.md` scratch + 4 slash commands (`/td-init`, `/td-clear`, `/td-close`, `/td-bus-init`). Everything else is conversational.

The full evolution lives in `git log` — read it before assuming current state. v3.1 split `/td-clear` from `/td-close`. v3.2 added drift signals + install.sh pruning. v3.3 added fold-and-delete + "Digging into history". v3.4 made bypassed rituals explicit (the "lets do it" trigger, "Before I commit a piece" bundle, `/init` never-run rule). v3.5 cleaned BACKLOG/PROJECT and set rgb-buddy-2 as the next real-project move. **v3.6 shipped td-bus**: opt-in cross-project messaging on a shared Turso/libsql DB so registered apps can exchange CRs / notes / bugs without writing into each other's repos.

td-bus shape (for cold-start recall):
- `apps` (canonical handle, description, optional long_description / contact / repo_path) + `messages` (type cr|note|bug, status enum open|accepted|shipped|rejected|withdrawn|done, FK'd to apps) + `replies` (append-only thread, cascade delete).
- IDs are human-readable: `<from_app>-<TYPE>-<n>`, n computed by the CLI not the DB.
- Creds: env vars `TD_BUS_URL` + `TD_BUS_TOKEN` preferred; `~/.td/bus.env` fallback. CLI dies fast with a clear message if both are missing.
- Status transitions are role-gated: sender can withdraw, recipient can accept / ship (requires `--sha`) / reject, either can mark done.

**Next moves (still pending — not blocked, just unscheduled):**

1. First real-project validation pass: `cd ~/projects/rgb-buddy-2 && claude && /td-init`. Exercises brownfield detection (`.claude/agreements/`, `ARCHITECTURE.md`, `BLOCKS.md`) + confirms the v3.4 rituals fire on a fresh project. Anything quirky → BACKLOG line tagged "feedback on td-flow:".
2. First end-to-end bus exchange in anger: send a real CR between two of the four registered apps, walk it through `send → accept → ship --sha → done`, watch for friction. Anything quirky → BACKLOG line tagged "feedback on td-bus:".

How we know the framework actually works without an automated test: drift signals + "Before I commit a piece" bundle are the validation mechanism. Today's pull-and-review surfaced exactly the drift it was supposed to — STATE was stale post-bus, PROJECT.md was missing v3.6. The rituals are doing their job; just need to fire on the commit side too.
