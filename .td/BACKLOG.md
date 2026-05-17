# Backlog

Bigger items noticed but not in scope for the current topic. Append-only. When an item ships, delete the line — git keeps the history.

- 2026-05-04 — **Next session: validate v3.4–v3.8 on a real brownfield project.** Single `/td-init` move closes (a) UAT for the recent framework changes, (b) brownfield-detection check on a real project, (c) first-real-project proof. File anything quirky here via "feedback on td-flow: …".
- 2026-05-03 — Save a `laravel` template once a Laravel project has been initialized (use `/td-init`'s "save this as a template" path)
- 2026-05-03 — Save a `userscript` template (Vite + vite-plugin-monkey + Tampermonkey) from the first real userscript project's shape
- 2026-05-03 — Add research/context7 step into the rhythm if it shows up as a missing pattern in real use
- 2026-05-03 — Add subagent / parallel-piece path if a real feature has 4+ independent pieces
- 2026-05-03 — Decide whether `ARCHITECTURE.md` (a pattern seen in some brownfield projects) should be a standard `.td/` doc or stay project-specific
- 2026-05-17 — **Piece 2: slash-command enrichment.** Enrich `/td-init` to auto-register projects in `$TD_REGISTRY`'s SERVICES.md, `/td-clear` to surface inbox + outbox in resume note, `/td-close` to check unresolved issues before wrapping. Triggered by v3.8 registry split.
- 2026-05-17 — **Pending external action: rename `mergodon/rgb-buddy-2` → `mergodon/rgb-ggbuddy`.** Blocked on freeing the existing `rgb-ggbuddy` slot (owner handling separately). When the rename lands: (1) `gh repo rename --repo mergodon/rgb-buddy-2 rgb-ggbuddy`, (2) update SERVICES.md in `td-registry` (slug only — friendly name `rgb-buddy` stays decoupled), (3) `git remote set-url origin` in each local clone, (4) update per-project `## Cross-repo` sections that reference the old slug. GH redirects keep everything working until then.
