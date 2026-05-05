# State

Project:  td-flow
Topic:    idle
Phase:    closed (2026-05-04)
Blocker:  none
Last:     2026-05-05 — v3.5 shipped: BACKLOG/PROJECT cleanup. Auto-test-suite item dropped (validate per-project instead). rgb-buddy-2 set as the explicit next-session move (closes UAT + first-real-project validation in one).

## Resume note

td-flow is the minimal, file-based, repo-portable framework hosted at `mergodon/td-nopara`. It eats its own dog food — this repo IS a td-flow project. Stable surface: root `CLAUDE.md` contract + 4 `.td/` docs (`PROJECT`, `WORKWAY`, `STATE`, `BACKLOG`) + `work/<topic>.md` scratch + 3 slash commands (`/td-init`, `/td-clear`, `/td-close`). Everything else is conversational.

The full evolution lives in `git log` — read it before assuming current state. v3.1 split `/td-clear` from `/td-close`. v3.2 added drift signals, sharpened "Who does what", slimmed SKILL.md to a thin pointer, made `install.sh` prune stale command symlinks. v3.3 added the fold-and-delete rule and the "Digging into history" git recipe. v3.4 closed the loop on rituals that were getting bypassed in practice: "lets do it" is now explicitly a meaningful-work trigger, the "Before I commit a piece" section bundles pre-ship + STATE-update + fold-and-delete, and a hard rule was added: never run Claude Code's built-in `/init` in a td-flow project.

**The very next move (do this first, do not iterate further on td-flow itself):**

```
cd ~/projects/rgb-buddy-2
claude
/td-init
```

This single move exercises the brownfield detection (`.claude/agreements/`, `ARCHITECTURE.md`, `BLOCKS.md` mapping), confirms the v3.4 rituals fire on a real project (drift signals, "Before I commit a piece", "lets do it" trigger), and produces the first real-project commit history under td-flow v3.4. Anything quirky → file as a "feedback on td-flow: …" line that lands in this repo's BACKLOG.md.

How we know v3.4 actually works without an automated test: the framework's own drift signals + "Before I commit a piece" bundle are the validation mechanism. After one or two real-project sessions, scan the resulting commits — if STATE.md updates ride alongside `feat:` commits, scratch files got fold-and-deleted, and "anything else on your mind?" appears at piece-start, the rituals are live. If they don't, surface as feedback and tighten CLAUDE.md again.
