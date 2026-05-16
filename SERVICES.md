# Services

Central registry of the user's actively cross-repo-relevant projects: **friendly name → GH slug → one-line description**. This file is the human-readable lookup. Per-project `.td/PROJECT.md § Cross-repo` sections continue to use full GH slugs (since `gh issue create --repo X` needs them) — this file is for *finding* the right slug when you can't remember whether the rgb-webapp Laravel is `tdphp-rgbtracker-mainweb` or `tdgeneric-rgbtracker-mainweb`.

**Not exhaustive.** Lists the cross-repo-active and load-bearing projects only — add entries as you reach for each one. The full owner-wide view is always `gh repo list mergodon`.

## ANZSCO / Tasman Visa ecosystem

| Friendly | GH slug | What |
|---|---|---|
| `anzscofinder` | `mergodon/anzsco-tasmanvisa-com` | Laravel app at anzscofinder.com — ANZSCO workflows, auth, billing |
| `anzscofinder-pipeline` | `mergodon/anzscofinder-pipeline` | Python/FastAPI matching engine — CV → ANZSCO codes (LangGraph + Postgres/pgvector). Consumer: anzscofinder. |
| `tasssy` | `mergodon/app_tasssy_tasmanvisa_com` | TAScheck AI — ANZSCO classification tool |
| `tasmanvisa-wp` | `mergodon/tasmanvisa-com-wp` | WordPress site for tasmanvisa.com — mu-plugins, sync scripts, deployment tools |

## RGB / RGBTracker ecosystem (poker analytics)

| Friendly | GH slug | What |
|---|---|---|
| `rgb-webapp` | `mergodon/tdphp-rgbtracker-mainweb` | Laravel/Filament webapp at rgbtracker.mergodon.com — Spin & Gold receiver |
| `rgbtracker-pipeline` | `mergodon/rgbtracker-pipeline` | Hand-history pipeline — parses GG poker HHs from Google Drive into PostgreSQL |
| `rgb-buddy` | `mergodon/rgb-buddy-2` | Tampermonkey userscript at ggbuddy.mergodon.com — PokerCraft tournament data capture |
| `rgb-analytics` | `mergodon/rgb-analytics` | Per-player chipEV analysis for GG SPIN players tracked by rgbtracker |
| `rgb-hh-processor` | `mergodon/rgb-hh-processor` | GG poker hand-history processor (libhh2 + CLI) — HH+summary → JSON with cEV per hand |

## Mergodon brand & infra

| Friendly | GH slug | What |
|---|---|---|
| `familycop` | `mergodon/familycop` | NextDNS parenting tool for the Visky family — Cloudflare Worker + Ionic React SPA |
| `td-flow` | `mergodon/td-nopara` | This repo — the td-flow framework itself (eats own dog food) |
| `dotfiles` | `matevisky/_dotfiles` | Personal dotfiles (different owner — observer + dev machines, iTerm2 + tmux + zsh). |

## Notes

- **Aliases / historical**: `rgb-buddy` (original) and `rgb-ggbuddy` are historical/parallel — `rgb-buddy-2` is the active fork. `tdgeneric-rgbtracker-mainweb` is the legacy/scaffold counterpart to the active `tdphp-rgbtracker-mainweb`. Don't file CRs against the historical ones.
- **Adding a new entry**: when you spin up a new project that interacts cross-repo, add a row here AND list it in the originating project's `.td/PROJECT.md § Cross-repo`. The two artifacts answer different questions: this file = "what services exist?"; per-project Cross-repo = "what does *this* project file into?".
- **The user has multiple GH identities** (e.g. `matevisky` on observer, `cicmorgi` on dev) — the registry indexes *repos*, not users, so identity is incidental.
