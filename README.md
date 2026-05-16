# td-flow

A minimal, file-based, repo-portable framework for solo development.

Same shape every project. Conversational interface — after `/td-init`, you just talk and I orchestrate. GitHub commits are the work memory.

## Install

```
git clone https://github.com/mergodon/td-nopara ~/projects/td
cd ~/projects/td
./install.sh
```

Symlinks created:
- `~/.claude/commands/td-init.md`
- `~/.claude/commands/td-clear.md`
- `~/.claude/commands/td-close.md`
- `~/.claude/skills/td-flow`
- `~/.claude/td-templates`

To update on any machine: `git pull && ./install.sh`.

## Use

In any project directory:

```
claude
/td-init                       # bootstrap or migrate (brownfield-aware)
/td-init --template laravel    # bootstrap from a saved template
/td-clear                      # mid-project: save STATE handoff, light prune, push. Run before /clear.
/td-close                      # wrap project (or phase): full doc audit, prune redundant docs, push.
```

Shipping individual pieces is conversational: tests pass → commit → push to `origin/main`. No slash command for that.

`/td-init` detects existing td-flow v1/v2, GSD legacy (`.planning/`, HTML markers), or rgb-buddy-2-style conventions (`.claude/agreements/`, `ARCHITECTURE.md`, `BLOCKS.md`) and migrates them in place — no re-explaining.

After init, just talk:

- "let's add a search bar" — starts the rhythm
- "test command is `npm test`" — updates `.td/WORKWAY.md` § Local testing
- "live URL is myapp.pages.dev" — updates `.td/WORKWAY.md` § Production / Ship
- "remember to debounce later" — appends `.td/BACKLOG.md`
- "save this as a `userscript` template" — extracts the current `.td/` shape into `~/projects/td/templates/userscript/`
- "ship it" — tests pass, commit, push to `origin/main` (conversational)
- "where are we" — summarizes `.td/STATE.md`
- "let's clear" / about to /clear — runs `/td-clear`
- "wrap the project" / "we're done" — runs `/td-close`

## The rhythm

```
1. Plan      — single-shot or multi-step; plan goes in .td/work/<topic>.md
2. Park      — bigger out-of-scope items → .td/BACKLOG.md
3. Work      — implement
4. Test      — follow .td/WORKWAY.md (Local testing → Local UAT → Production / Ship)
5. Ship      — push to origin/main when green
6. Close     — review, validate, update STATE, remove redundant docs, push
```

A session can cover any subset. STATE.md tracks where you are; the next session picks up cold.

## The five docs

```
CLAUDE.md                ← contract at root; user controls
.td/
  PROJECT.md             ← what / who / stack / scope
  WORKWAY.md             ← Local testing + Local UAT + Production/Ship + Framework specifics
  STATE.md               ← current phase, current topic, blocker
  BACKLOG.md             ← parked bigger items
  work/<topic>.md        ← active work; deleted at close
.env.example             ← committed
.env                     ← gitignored
.git/hooks/pre-commit    ← runs Test command from WORKWAY.md § Local testing
```

## Repo layout (this repo)

```
commands/             slash commands (td-init, td-clear, td-close)
templates/            files copied into target projects on /td-init
  CLAUDE.md           the universal contract
  td/PROJECT.md
  td/WORKWAY.md       the way-of-work doc with locked sections
  td/STATE.md
  td/BACKLOG.md
  td/frameworks/.gitkeep   (overflow dir, rarely needed)
  .gitignore
  .env.example
  FEEDBACK.md         template for framework-level feedback
  <name>/             saved starter templates (laravel, userscript, etc.)
skill/SKILL.md        skill definition (symlinked into ~/.claude/skills/td-flow)
hooks/pre-commit      test-on-commit hook installed by /td-init
install.sh            symlinks commands, skill, templates into ~/.claude/
FEEDBACK.md           feedback about td-flow itself, captured from any project
```

## Cross-repo requests

Projects sometimes need things from other projects. Convention: each `.td/PROJECT.md` keeps an opt-in `## Cross-repo` section listing the repos this project legitimately files against — example:

```markdown
## Cross-repo

- `mergodon/anzscofinder` — Laravel app, ANZSCO workflows + auth + billing.
- `mergodon/rgb-webapp` — Laravel app at rgbtracker.mergodon.com.
```

Workflow: I read the registry, `gh repo view <slug>` to confirm access + read the target repo for context, then `gh issue create --repo <slug>`. Discussion in issue comments. The receiver closes via `Closes <slug>#N` in a commit message — auto-links both sides. No file-based CRs, no separate inbox, no status enum, no labels.

Unified view across all your repos: `gh search issues "user:<owner> involves:@me state:open"`.

The section is opt-in — projects with no cross-repo relationships skip it. Details in `templates/CLAUDE.md § Cross-repo`.

## Saving and reusing templates

When a project's setup is dialed in, you say "save this as a `<name>` template." I copy `.td/*` (anonymized — placeholders restored) to `~/projects/td/templates/<name>/`. Future `/td-init --template <name>` starts from that shape so a new Laravel project is configured like the previous one out of the gate.

## Frameworks (Laravel Boost, Next, etc.)

Frameworks like Laravel Boost regenerate root files (`CLAUDE.md`, `AGENTS.md`, `.mcp.json`, `boost.json`, `junie/`) on `boost:install`. We:

1. Use Boost's MCP server (the genuinely useful part — `.mcp.json` is gitignored, regenerated, and that's fine).
2. Note the framework in `.td/WORKWAY.md` § Framework specifics so I know how to use it.
3. Gitignore Boost's auto-generated guideline files.
4. If Boost overwrites root `CLAUDE.md`, you tell me; I restore it from the canonical template. One-line edge case, not the default.

## Principles

- Three similar lines beats a premature abstraction.
- Tests are the contract.
- Ship fast, fix fast.
- Complexity without user-visible value doesn't belong.
- GitHub is the memory. Don't duplicate.
- Cleanup is part of the work — fix incidental drift in the same commit.
- Present results — assumptions, fixes, decisions visible. No opaque "done."

## Not in scope (yet)

- Research / context7 deep integration in the rhythm.
- Subagents for parallel pieces.
- Anything that turns this into a CLI or npm package.
