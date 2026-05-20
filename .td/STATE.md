# State

Project:  td-flow
Topic:    idle
Phase:    closed (2026-05-20)
Blocker:  none
Last:     2026-05-20 — shipped: ARCHITECTURE.md drafted from project reality (git log + code + docs) at /td-refresh Phase 4, brownfield /td-init, and /td-close — no longer blank-scaffolded.

## Resume note

td-flow is the public, file-based, repo-portable solo-dev framework at `mergodon/td-flow` — and this repo IS a td-flow project (eats its own dogfood). Surface: root `CLAUDE.md` contract + five standard `.td/` docs (PROJECT/WORKWAY/ARCHITECTURE/STATE/BACKLOG) + optional DEBUG + `work/<topic>.md` scratch + seven slash commands (`/td-init`, `/td-clear`, `/td-close`, `/td-refresh`, `/td-mailbox`, `/td-incident`, `/td-park`). Everything else is conversational.

Last shipped (v4.3, 2026-05-20): framework self-update. `/td-close` Step 11 detects when the local td-flow repo is behind `origin/main` and nudges — read-only, never pulls. `/td-refresh` Phase 0 acts on it: re-runs `install.sh`, offers a confirm-first `--ff-only` pull. Rationale in ARCHITECTURE.md § Important decisions; change list in PROJECT.md § Shipped; detail in `git log`.

Post-close (2026-05-20): a doc-review roleplay pass found and fixed 15 drifts. README + SKILL.md were frozen pre-v4.2 (missing ARCHITECTURE.md, "Outbound tracking" listed as not-in-scope when it shipped, "five Issue Types" when there are four). The `## Live` WORKWAY section was still referenced as "Production / Ship" in 11 places across README/SKILL/td-init/td-close. CLAUDE.md said `/td-refresh` had 4 phases (now 5). `/td-refresh` now reuses Phase 0's `$TD_REPO` in Phases 1 & 4 instead of hardcoding the clone path. Stale `/td-inbox` / `/td-feedback` refs removed; `gh issue create` in the Cross-repo filing workflow corrected to the GraphQL `createIssue` mutation; orphaned `templates/FEEDBACK.md` deleted. A follow-up re-check caught 2 more pre-v4.2 doc enumerations in `/td-close` (the Step 2 audit-read list and the never-delete protected-doc set) — fixed too. Final sweep verified clean; framework docs are internally consistent end to end. Commits `c5c2f02` + `b57d3e2`.

Enhancement (2026-05-20): ARCHITECTURE.md is now **drafted from project reality**, not blank-scaffolded. `/td-refresh` Phase 4 (Step 9), the brownfield `/td-init` migration paths (v2 / GSD / ad-hoc), and `/td-close`'s doc-hygiene pass all offer a `draft` option that reads PROJECT/WORKWAY + the code tree + `git log`, then fills the ARCHITECTURE.md template only as far as the evidence supports — `git log`-mined Important decisions, sections with no evidence left as explicit markers, never fabricated. Canonical procedure lives in `/td-refresh` Phase 4 § Drafting procedure; `/td-init` and `/td-close` reference it. Triggered by maintainer feedback that the old scaffold just handed back an empty file. Greenfield `/td-init` still copies a blank template — a brand-new project has no history to draft from.

Nothing pending — 0 open issues, BACKLOG empty, no work files. To pick up: PROJECT.md for shape, `git log --oneline -15` for the recent arc, ARCHITECTURE.md for the load-bearing whys. This repo is already initialized — `/td-init` is for fresh projects; `/td-refresh` syncs from canonical.
