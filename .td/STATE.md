# State

Project:  td-flow
Topic:    idle
Phase:    shipped (2026-05-16)
Blocker:  none
Last:     2026-05-16 — v3.7 shipped: retired td-bus in favor of GitHub Issues + per-project `## Cross-repo` registry. Deleted `bin/td-bus`, `bus-schema.sql`, `commands/td-bus-init.md`, bus blocks in `install.sh` + `README.md`. Added Cross-repo workflow + warm-up `gh issue list` nudge to root + template CLAUDE.md. Bus shipped and retired same day (~8h apart) once research on Projects v2 / Issues showed the bus was reinventing what GH already gives for free.

## Resume note

td-flow is the minimal, file-based, repo-portable framework hosted at `mergodon/td-nopara`. It eats its own dog food — this repo IS a td-flow project. Stable surface: root `CLAUDE.md` contract + 4 `.td/` docs (`PROJECT`, `WORKWAY`, `STATE`, `BACKLOG`) + `work/<topic>.md` scratch + 3 slash commands (`/td-init`, `/td-clear`, `/td-close`). Everything else is conversational.

The full evolution lives in `git log` — read it before assuming current state. v3.1 split `/td-clear` from `/td-close`. v3.2 added drift signals + install.sh pruning. v3.3 added fold-and-delete + "Digging into history". v3.4 made bypassed rituals explicit. v3.5 cleaned BACKLOG/PROJECT. v3.6 shipped td-bus (Turso/libsql + Python CLI). **v3.7 retired td-bus** — too much surface for a solo dev when GH Issues + `gh search issues "user:<owner> involves:@me state:open"` does the same job with zero infra.

Cross-repo shape now (for cold-start recall):
- Per-project: `.td/PROJECT.md § Cross-repo` lists repos this project files CRs against. Opt-in — only present when the project has a real cross-repo relationship to declare. No template scaffold.
- Workflow: I check the registry → `gh repo view <slug>` to verify access + read target's README/PROJECT.md for context → `gh issue create --repo <slug>` with body = ask + why + source → discuss in comments → receiver closes via `Closes <slug>#N`.
- Warm-up: at first message of fresh session I run `gh issue list --state open` and surface incoming alongside STATE.
- Etiquette: never commit/push/test in another repo. The only write into another project's territory is via `gh issue create`.

**Loose ends + next moves:**

1. **Live Turso DB still exists.** User can `turso db destroy td-bus-<you>` whenever — not blocking anything, just costs nothing to leave it idle.
2. **`templates/CLAUDE.md` and root `CLAUDE.md` have drifted.** Template has the full Cross-repo section now; root has it too, but the older drift (template's etiquette callout vs. root's absence) was patched as part of v3.7. Worth a future audit to keep them in sync.
3. **First real-project validation:** `cd ~/projects/rgb-buddy-2 && claude && /td-init` — still the unscheduled next-real-project move. Exercises brownfield detection on a fresh project. The rgb-buddy-2 repo also now has issue #7 (the bus-retirement cleanup) waiting in its inbox, so opening it doubles as warm-up-nudge validation.
4. **First real cross-repo issue in anger — DONE 2026-05-16.** Filed 4 retirement-cleanup issues from `td-nopara` per the v3.7 workflow:
   - mergodon/anzsco-tasmanvisa-com#1
   - mergodon/anzscofinder-pipeline#1
   - mergodon/rgb-buddy-2#7
   - mergodon/tdphp-rgbtracker-mainweb#1

   Each asks the receiving project to drop the stale `## td-bus` section from `.td/PROJECT.md` and delete `~/.td/bus.env` if present. When you open any of those projects, the warm-up `gh issue list --state open` should surface its issue automatically. Anything quirky in that flow → BACKLOG line tagged "feedback on cross-repo:".
