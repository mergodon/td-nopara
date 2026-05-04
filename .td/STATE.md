# State

Project:  td-flow
Topic:    idle
Phase:    closed (2026-05-04)
Blocker:  none
Last:     2026-05-04 — v3.3 shipped: fold-and-delete rule + "Digging into history" recipe in CLAUDE.md.

## Resume note

td-flow is the minimal, file-based, repo-portable framework hosted at `mergodon/td-nopara`. It eats its own dog food — this repo IS a td-flow project. Stable surface: root `CLAUDE.md` contract + 4 `.td/` docs (`PROJECT`, `WORKWAY`, `STATE`, `BACKLOG`) + `work/<topic>.md` scratch + 3 slash commands (`/td-init`, `/td-clear`, `/td-close`). Everything else is conversational.

The full evolution lives in `git log` — read it before assuming current state. v3.1 split `/td-clear` from `/td-close`. v3.2 added drift signals, sharpened "Who does what", slimmed SKILL.md to a thin pointer, made `install.sh` prune stale command symlinks. v3.3 added the fold-and-delete rule and the "Digging into history" git recipe.

The first thing the next session should do is **use the framework on a real project**, not iterate on it. `rgb-buddy-2` is the lowest-risk first migration (its convention is closest to v3). File anything quirky as a `.td/BACKLOG.md` item here via natural language.
