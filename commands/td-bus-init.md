---
description: Onboard the current project to the td-bus (cross-project messaging via Turso). One-time per project. Idempotent — re-runs update the registration.
---

You are onboarding the current project to **td-bus** — the cross-project messaging system used by td-flow to send change requests, notes, and bug reports between projects.

After this runs, the project can send/receive messages via `td-bus send`, `td-bus inbox`, `td-bus outbox`, etc. The CLI is at `~/projects/td/bin/td-bus` (assumed on PATH after `install.sh`).

# Step 0 — Credentials check

Resolve `TD_BUS_URL` + `TD_BUS_TOKEN`. Order of precedence the CLI uses:

1. Process env vars — set them once in `~/.secrets` (or `~/dotfiles/shell/secrets.zsh`, or `.zshrc`) so every shell + Claude session inherits them. **Preferred path.**
2. Fallback file at `~/.td/bus.env` — for fresh machines without a shell-secrets convention.

Run `env | grep TD_BUS_` to check. If both are unset:

1. Tell the user: "td-bus needs Turso credentials. Provision once via `turso db create td-bus-<you>` + `turso db tokens create td-bus-<you>`. Paste the URL + token below."
2. Prompt for `TD_BUS_URL` (format `libsql://...`) and `TD_BUS_TOKEN`.
3. Append to `~/.secrets` (or whatever file the user names — read `~/.zshrc` / `~/.zprofile` for `source` lines if unsure):
   ```
   export TD_BUS_URL="<url>"
   export TD_BUS_TOKEN="<token>"
   ```
   Then tell the user to `source ~/.secrets` (or open a new shell) to pick them up.
4. **Fallback path only** if the user has no shell-secrets convention: write `~/.td/bus.env` (chmod 600) with the two `KEY=value` lines.
5. Apply the schema to the freshly provisioned DB:
   ```
   # Pipeline against the DB via the bin script; if schema already applied, IF NOT EXISTS makes it a no-op.
   python3 -c "import json,os,re; from pathlib import Path; from urllib.request import Request,urlopen; \
     env={l.split('=')[0]:l.split('=',1)[1].strip().strip(chr(34)+chr(39)) for l in Path('~/.td/bus.env').expanduser().read_text().splitlines() if '=' in l and not l.lstrip().startswith('#')}; \
     url=env['TD_BUS_URL'].replace('libsql://','https://'); token=env['TD_BUS_TOKEN']; \
     stmts=[s.strip() for s in '\n'.join(l for l in Path('~/projects/td/bus-schema.sql').expanduser().read_text().splitlines() if not l.lstrip().startswith('--')).split(';') if s.strip()]; \
     payload={'requests':[{'type':'execute','stmt':{'sql':s}} for s in stmts]+[{'type':'close'}]}; \
     print(urlopen(Request(f'{url}/v2/pipeline', data=json.dumps(payload).encode(), headers={'Authorization':f'Bearer {token}','Content-Type':'application/json'}, method='POST')).read().decode()[:200])"
   ```

# Step 1 — Detect existing registration

```sh
td-bus --json apps | jq -r '.[].name'
```

If the basename of `pwd` is already in the list, this project is already registered. Tell the user `<name> is already on the bus`, ask whether to update the registration or skip.

# Step 2 — Gather metadata

Ask the user (with sensible defaults):

- **App name** (default = `pwd` basename). Must be lowercase kebab-case, must be unique on the bus.
- **One-line description** (required). Shown in inbox listings. Example: "Laravel app at anzscofinder.com — auth, workflows, billing."
- **Long description** (optional, blank to skip). Shown by `td-bus apps show <name>`. Pre-fill from `.td/PROJECT.md § What this is` if that file exists and has content.
- **Contact** (optional). Human owner / handle.

Don't ask for `repo_path` — auto-set to `$(pwd)`.

# Step 3 — Register

Run the non-interactive `apps-register` subcommand with the gathered values:

```sh
td-bus apps-register <name> \
  --description "<one-line>" \
  --long-description "<long, or omit>" \
  --contact "<who, or omit>" \
  --repo-path "$(pwd)"
```

If the user chose "update" in Step 1, send the same fields — the CLI's interactive `init` handles the upsert, but the non-interactive `apps-register` will fail on duplicate. For updates, use the interactive form:

```sh
cd <project> && td-bus init
```

…or run direct SQL via a one-shot Python call against the apps table.

# Step 4 — Wire into the project docs

Update `.td/PROJECT.md`: append (or replace) a small section near the top:

```markdown
## td-bus

Registered on td-bus as **<name>**. Use `td-bus inbox` to see incoming CRs / notes / bugs from other projects, `td-bus send <to> "<title>"` to send.
```

# Step 5 — Confirm

Print:

- `<name> registered on td-bus.`
- `Inbox: $(td-bus inbox --json | jq length) open items.`
- `Outbox: $(td-bus outbox --json | jq length) open items.`

# Notes

- This is **opt-in per project.** Don't run `/td-bus-init` from `/td-init` automatically — the bus is for projects that genuinely talk to other projects. Solo projects with no cross-repo asks don't need it.
- The `apps` table is shared across the user's whole td-bus DB. The name picked here is how other projects address messages to you.
- Re-running `/td-bus-init` is safe — it updates the registration in place.
