---
description: Print a one-screen cheat sheet for td-flow. Optional argument shows help for a single command.
---

You are printing help. Keep it tight. Do not editorialize.

# If no argument

Print exactly this:

```
td-flow — solo developer framework

  /td-init              start in a new (or existing) project
  /td-feature <name>    BIG: new features (plan + reality check + ship in pieces)
  /td-fix <text>        SMALL: bugfixes and tweaks (no plan, just ship)
  /td-ship              do the next thing → test → commit → push
  /td-status            where are we?
  /td-note <text>       capture an idea/bug for THIS project
  /td-feedback <text>   capture an idea/bug for td-flow itself
  /td-reset             squash + handoff before /clear
  /td-cleanup           if a framework polluted CLAUDE.md
  /td-help <command>    details on one command

Typical loop:
  /td-init  →  /td-feature or /td-fix  →  /td-ship  (repeat)  →  done

Where things live in your project:
  CLAUDE.md         the contract (don't edit by hand)
  .td/PROJECT.md    what / who / stack / scope
  .td/TESTING.md    how to test
  .td/ENV.md        live URLs and deploy
  .td/STATE.md      where we are now
  .td/INBOX.md      ideas captured by /td-note
  .td/flow/         the active piece
```

# If argument is a command name

Strip a leading `/td-` if present. The user might type `/td-help feature` or `/td-help td-feature`.

Read the matching file from `~/.claude/td-templates/../commands/td-<name>.md` (or directly from `~/.claude/commands/td-<name>.md`). Pull the `description:` field from the frontmatter.

Print exactly:

```
/td-<name>

<description from frontmatter>

For full behavior, read: ~/.claude/commands/td-<name>.md
```

If the command doesn't exist, print: `Unknown command: td-<name>. Try /td-help.`

# Rules

- No paragraphs of prose. The whole point is "super simple."
- Do not invent commands that aren't in the list.
- Do not modify any files.
