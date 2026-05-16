# State

Project:  td-flow
Topic:    idle
Phase:    shipped (2026-05-16)
Blocker:  none
Last:     2026-05-16 — v3.7 shipped: retired td-bus in favor of GitHub Issues + per-project `## Cross-repo` registry. Deleted `bin/td-bus`, `bus-schema.sql`, `commands/td-bus-init.md`, bus blocks in `install.sh` + `README.md`. Added Cross-repo workflow + warm-up `gh issue list` nudge to root + template CLAUDE.md. Bus shipped and retired same day (~8h apart) once research on Projects v2 / Issues showed the bus was reinventing what GH already gives for free.

## Resume note

td-flow is the minimal, file-based, repo-portable framework hosted at `mergodon/td-nopara`. It eats its own dog food — this repo IS a td-flow project. Stable surface: root `CLAUDE.md` contract + 4 `.td/` docs (`PROJECT`, `WORKWAY`, `STATE`, `BACKLOG`) + `work/<topic>.md` scratch + 3 slash commands (`/td-init`, `/td-clear`, `/td-close`). Everything else is conversational.

The full evolution lives in `git log` — read it before assuming current state. v3.1 split `/td-clear` from `/td-close`. v3.2 added drift signals + install.sh pruning. v3.3 added fold-and-delete + "Digging into history". v3.4 made bypassed rituals explicit. v3.5 cleaned BACKLOG/PROJECT. v3.6 shipped td-bus (Turso/libsql + Python CLI). **v3.7 retired td-bus** — too much surface for a solo dev when GH Issues + `gh search issues --owner <owner> --involves @me --state open` does the same job with zero infra.

Cross-repo shape now (for cold-start recall):
- Per-project: `.td/PROJECT.md § Cross-repo` lists repos this project files CRs against. Opt-in — only present when the project has a real cross-repo relationship to declare. No template scaffold.
- Workflow: I check the registry → `gh repo view <slug>` to verify access + read target's README/PROJECT.md for context → `gh issue create --repo <slug>` with body = ask + why + source → discuss in comments → receiver closes via `Closes <slug>#N`.
- Warm-up: at first message of fresh session I run `gh issue list --state open` and surface incoming alongside STATE.
- Etiquette: never commit/push/test in another repo. The only write into another project's territory is via `gh issue create`.

**Loose ends + next moves:**

1. **User actions still pending** (Claude can't do these without overreach):
   - **Destroy cloud DB:** `turso db destroy td-bus-mergodon` (region `aws-ap-northeast-1`). User has no `turso` CLI installed; either `brew install tursodatabase/tap/turso` or use the Turso web UI.
   - **~~Remove env vars from `~/dotfiles/shell/secrets.zsh`~~** — DONE 2026-05-16. Removed the 3-line td-bus block (comment header + `TD_BUS_URL` + `TD_BUS_TOKEN`) via sed-by-pattern with a `.bak` backup; verified diff showed only those 3 lines changed; backup deleted. `~/dotfiles` is a git repo (`matevisky/_dotfiles`); the modified `secrets.zsh` is uncommitted there — user's call when/how to commit in their own repo per v3.7 cross-repo etiquette. Confirm in a new shell with `env | grep TD_BUS_` (should be empty).

2. **Local cleanup status (as of 2026-05-16):**
   - `~/bin/td-bus` symlink: removed.
   - `~/.td/bus.env`: not present (never created on this machine).
   - `~/.td/` dir: not present.
   - `bin/td-bus` + `bus-schema.sql` + `commands/td-bus-init.md` in repo: deleted in `b52bed0`.

3. **Memo for affected projects** lives at `/tmp/td-bus-retirement-memo.md` — copy-pasteable summary of the convention + per-repo asks + issue links. Survives the session; regenerate from this STATE if lost.

4. **First real-project validation:** `cd ~/projects/rgb-buddy-2 && claude && /td-init` — still unscheduled. Doubles as warm-up-nudge validation since rgb-buddy-2#7 is waiting in its inbox.

5. **First real cross-repo issue in anger — DONE + VALIDATED 2026-05-16.** Four retirement issues filed from `td-nopara` per the v3.7 workflow; **all four closed by their projects' Claude sessions within ~1 hour** of filing. Validation outcomes:
   - **anzsco-tasmanvisa-com#1** — closed by `matevisky` with rich comment (commit 289e179): td-bus refs removed, CLAUDE.md restored to canonical, `## Cross-repo` registry added pointing at `mergodon/anzscofinder-pipeline`. Full v3.7 migration done.
   - **anzscofinder-pipeline#1** — closed silently via commit.
   - **rgb-buddy-2#7** — closed silently via commit.
   - **tdphp-rgbtracker-mainweb#1** — closed by `cicmorgi` with detailed audit comment: repo never adopted `.td/` (uses `.work/`), no td-bus refs found, no changes needed, framework already pulled to e4d8e2c. Also confirmed the technical nuance that fresh `env` output in a Claude session shows pre-removal vars only because the session inherited them at startup (verifies my earlier finding about Bash-tool env inheritance).
   - **Found bug during this review**: the documented unified-inbox query was wrong — `gh search issues "user:X involves:@me state:open"` (quoted form) breaks because gh interprets the whole quoted string as a single phrase. Corrected to flag form `gh search issues --owner <owner> --involves @me --state open` in root CLAUDE.md, templates/CLAUDE.md, README.md, and this STATE.md. The unquoted positional form also works; flag form chosen for readability.
   - **Bonus signal**: while running the corrected query I noticed 4 new open issues in `mergodon/anzsco-tasmanvisa-com` (#2–5) titled `(CR-X consumer follow-up)`. That's the v3.7 cross-repo convention being used organically beyond the bus retirement — anzscofinder-pipeline filing real CRs into its Laravel consumer.

6. **`templates/CLAUDE.md` vs root `CLAUDE.md` drift** patched as part of v3.7; both have the full Cross-repo section now. Worth a future audit to keep them in sync going forward.
