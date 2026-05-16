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

1. **User actions still pending** (Claude can't do these without overreach):
   - **Destroy cloud DB:** `turso db destroy td-bus-mergodon` (region `aws-ap-northeast-1`). User has no `turso` CLI installed; either `brew install tursodatabase/tap/turso` or use the Turso web UI.
   - **Remove env vars** from `~/dotfiles/shell/secrets.zsh` lines 58-59 (`TD_BUS_URL` + `TD_BUS_TOKEN`). `~/.secrets` is a symlink to this file, so one edit covers both paths. Confirm with `env | grep TD_BUS_` in a fresh shell.

2. **Local cleanup status (as of 2026-05-16):**
   - `~/bin/td-bus` symlink: removed.
   - `~/.td/bus.env`: not present (never created on this machine).
   - `~/.td/` dir: not present.
   - `bin/td-bus` + `bus-schema.sql` + `commands/td-bus-init.md` in repo: deleted in `b52bed0`.

3. **Memo for affected projects** lives at `/tmp/td-bus-retirement-memo.md` — copy-pasteable summary of the convention + per-repo asks + issue links. Survives the session; regenerate from this STATE if lost.

4. **First real-project validation:** `cd ~/projects/rgb-buddy-2 && claude && /td-init` — still unscheduled. Doubles as warm-up-nudge validation since rgb-buddy-2#7 is waiting in its inbox.

5. **First real cross-repo issue in anger — DONE 2026-05-16.** Four retirement issues filed from `td-nopara` per the v3.7 workflow:
   - mergodon/anzsco-tasmanvisa-com#1
   - mergodon/anzscofinder-pipeline#1
   - mergodon/rgb-buddy-2#7
   - mergodon/tdphp-rgbtracker-mainweb#1

6. **`templates/CLAUDE.md` vs root `CLAUDE.md` drift** patched as part of v3.7; both have the full Cross-repo section now. Worth a future audit to keep them in sync going forward.
