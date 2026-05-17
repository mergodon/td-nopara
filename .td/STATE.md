# State

Project:  td-flow
Topic:    idle
Phase:    shipped v4.0 (2026-05-17)
Blocker:  none
Last:     2026-05-17 — **v4.0 cut — public-identity milestone.** Builds on v3.8 (public/private split landed earlier today) by aligning the public brand: GH repo renamed `mergodon/td-nopara` → `mergodon/td-flow`, local clone renamed `~/projects/td/` → `~/projects/td-flow/`. Friendly name, project name, slug, and local path all line up for the first time. Post-rename validation pass found three downstream projects on this machine (`anzscofinder-pipeline`, `anzscofinder`, `familycop`) still pointing at the old `~/projects/td/` path in their per-project `CLAUDE.md`; reconcile happens in each project's own Claude session per the README "Updating an existing td-flow project" flow. GH redirects keep old slug refs working.

## Resume note

td-flow is the minimal, file-based, repo-portable methodology hosted at `mergodon/td-flow` (public). It eats its own dog food — this repo IS a td-flow project. Stable surface: root `CLAUDE.md` contract + 4 `.td/` docs (`PROJECT`, `WORKWAY`, `STATE`, `BACKLOG`) + `work/<topic>.md` scratch + 3 slash commands (`/td-init`, `/td-clear`, `/td-close`). User-specific data (SERVICES.md + future outbound-issue logs) lives in a separate private companion repo discovered via `$TD_REGISTRY`. Everything else is conversational.

The full evolution lives in `git log` — read it before assuming current state. v3.1 split `/td-clear` from `/td-close`. v3.2 added drift signals + install.sh pruning. v3.3 added fold-and-delete + "Digging into history". v3.4 made bypassed rituals explicit. v3.5 cleaned BACKLOG/PROJECT. v3.6 shipped td-bus (Turso/libsql + Python CLI). **v3.7 retired td-bus** — too much surface for a solo dev when GH Issues + `gh search issues --owner <your-org> --state open` does the same job with zero infra. **v3.8 split user data into a private companion registry** so the framework can be public as a methodology while user-specific information stays private.

Cross-repo shape (for cold-start recall):
- Per-project: `.td/PROJECT.md § Cross-repo` lists repos this project files CRs against. Opt-in — only present when the project has a real cross-repo relationship to declare. No template scaffold.
- Workflow: check the per-project Cross-repo registry → `gh repo view <slug>` to verify access + read target's README/PROJECT.md for context → `gh issue create --repo <slug>` with body = ask + why + source → discuss in comments → receiver closes via `Closes <slug>#N`.
- Inbox: `gh issue list --state open` (current repo only by default; cross-repo opt-in via explicit triggers like "all repos", "global inbox", "everything open").
- Lookup: `SERVICES.md` in `$TD_REGISTRY` resolves friendly names to GH slugs (private; clone or fetch via `gh api`).
- Etiquette: never commit/push/test in another repo. The only write into another project's territory is via `gh issue create`.
- Identity-agnostic: REPO is the unit; multiple GH identities across machines are fine and incidental.

**Loose ends + next moves:**

1. **~~Destroy retired Turso DB~~** — DONE 2026-05-17. Bus retirement is now fully closed: framework code removed (v3.7), local creds removed (env vars + ~/.td/bus.env), cloud DB destroyed.

2. **First real-project validation** of the v3.7+v3.8 framework on a brownfield repo — still unscheduled. Exercises brownfield detection on a fresh project and confirms the rituals fire end-to-end.

3. **First real cross-repo issue in anger — DONE + VALIDATED 2026-05-16.** Four retirement-cleanup issues were filed from `td-nopara` per the v3.7 workflow into affected projects; **all four closed by their projects' Claude sessions within ~1 hour** of filing. Two closed silently via commit; one had a rich migration comment confirming full v3.7 adoption (including adding `## Cross-repo` registry to that project); one had a detailed audit comment confirming nothing to change because that project uses a different docs convention. Bonus signal: cross-repo follow-up CRs were subsequently filed organically between sibling projects — the convention is in real use beyond just the retirement cleanup.

4. **One bug found during validation review**: original unified-inbox query syntax was wrong — quoted-string `gh search issues "user:X involves:@me state:open"` breaks because gh interprets the whole quoted blob as a single search phrase. Fixed to `--owner` flag form; later dropped `--involves @me` entirely (REPO is the unit, not GH identity).

5. **Slash-command enrichment (Piece 2)** — pending: enrich `/td-init` to auto-register new projects in `$TD_REGISTRY`'s `SERVICES.md`, `/td-clear` to surface inbox + outbox in the resume note, `/td-close` to check unresolved issues before wrapping. Triggered by the v3.8 registry split; ready to start whenever — v4.0 surface is now stable + public.

7. **~~Pending external rename~~** `mergodon/rgb-buddy-2` → `mergodon/rgb-ggbuddy` — DONE 2026-05-17. GH rename landed; td-registry SERVICES.md updated (commit `5335fc7` in td-registry). Remaining: the renamed repo itself needs a local-side cleanup pass (git remote, internal doc refs, .td docs if any). Process documented; user will paste prompt into rgb-ggbuddy Claude session.

6. **`templates/CLAUDE.md` vs root `CLAUDE.md` drift** patched as part of v3.7+v3.8 work; both have the full Cross-repo section now. Worth a future audit to keep them in sync going forward.
