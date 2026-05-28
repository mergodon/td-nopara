#!/usr/bin/env bash
# td-flow installer — symlinks slash commands and the contract into ~/.claude/.
# (Templates are read directly from the repo by /td-flow-init, not symlinked.)
# Idempotent: safe to re-run after pulling updates.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SKILLS_DIR="$CLAUDE_DIR/skills"

mkdir -p "$COMMANDS_DIR"

# Cleanup: prior bus install left ~/bin/td-bus around; drop the orphan symlink.
if [ -L "$HOME/bin/td-bus" ]; then
  rm "$HOME/bin/td-bus"
  echo "  pruned stale: ~/bin/td-bus (td-bus retired in favor of gh issues)"
fi

# v6 rename detection — note pre-existing old-name symlinks BEFORE the prune
# step rewrites them. Used at the end to print the rename banner only when a
# user is actually upgrading (fresh installs see nothing).
V6_RENAMED_FROM=(td-init td-clear td-close td-refresh td-mailbox td-health td-incident td-park td-snapshot td-complex-clear)
V6_RENAME_DETECTED=false
for name in "${V6_RENAMED_FROM[@]}"; do
  if [ -L "$COMMANDS_DIR/$name.md" ]; then
    V6_RENAME_DETECTED=true
    break
  fi
done

# v6.1 skill retirement detection — note whether the old skill symlink exists
# BEFORE the prune step removes it. Used at the end to print the retirement
# notice only when a user is upgrading.
SKILL_LINK="$SKILLS_DIR/td-flow"
V6_1_SKILL_DETECTED=false
if [ -L "$SKILL_LINK" ] || [ -d "$SKILL_LINK" ]; then
  V6_1_SKILL_DETECTED=true
fi

# v7.0 dir-rename announcement — banner fires once per machine for users
# upgrading from pre-v7.0 (state dir renamed .td/ → .td-flow/, per-project
# migration via /td-flow-refresh). Detected by absence of the ack marker
# AND presence of a pre-existing contract symlink (signals "this is an
# upgrade", not a fresh install). Either way, the marker is created at the
# end so future installs see it and never re-fire.
V7_MARKER="$CLAUDE_DIR/.td-flow-v7-acked"
V7_DIR_RENAME_DETECTED=false
if [ ! -f "$V7_MARKER" ] && [ -L "$CLAUDE_DIR/td-flow-contract.md" ]; then
  V7_DIR_RENAME_DETECTED=true
fi

# 1. Prune stale symlinks pointing into this repo's commands/ dir
#    (catches retired commands like /td-ship from older versions, and
#    catches the v6 /td-* → /td-flow-* rename automatically)
for link in "$COMMANDS_DIR"/*.md; do
  [ -L "$link" ] || continue
  resolved=$(readlink "$link")
  case "$resolved" in
    "$REPO_DIR/commands/"*)
      if [ ! -e "$resolved" ]; then
        echo "  pruned stale: /$(basename "$link" .md)"
        rm "$link"
      fi
      ;;
  esac
done

# 2. Symlink slash commands
echo "→ installing slash commands to $COMMANDS_DIR"
for cmd in "$REPO_DIR/commands/"*.md; do
  name=$(basename "$cmd")
  target="$COMMANDS_DIR/$name"
  if [ -L "$target" ] || [ -f "$target" ]; then
    rm "$target"
  fi
  ln -s "$cmd" "$target"
  echo "  /$(basename "$name" .md)"
done

# 3. Retire the td-flow skill (v6.1) — the @import contract covers everything
#    the skill described, so the skill was vestigial. Prune any existing
#    symlink; no longer installed.
if [ -L "$SKILL_LINK" ] || [ -d "$SKILL_LINK" ]; then
  rm -rf "$SKILL_LINK"
  echo "  pruned stale: ~/.claude/skills/td-flow (skill retired v6.1; contract @import covers it)"
fi

# 4. Prune the retired td-templates symlink — commands now read templates
#    directly from the repo (~/projects/td-flow/templates/), so the
#    ~/.claude/td-templates indirection is gone. Remove any existing link.
TEMPLATES_LINK="$CLAUDE_DIR/td-templates"
if [ -L "$TEMPLATES_LINK" ] || [ -d "$TEMPLATES_LINK" ]; then
  rm -rf "$TEMPLATES_LINK"
  echo "  pruned stale: ~/.claude/td-templates (templates now read from repo)"
fi

# 5. Symlink the canonical contract — projects @import this, instead of each
#    carrying its own full copy in CLAUDE.md.
CONTRACT_LINK="$CLAUDE_DIR/td-flow-contract.md"
echo "→ linking contract to $CONTRACT_LINK"
if [ -L "$CONTRACT_LINK" ] || [ -f "$CONTRACT_LINK" ]; then
  rm "$CONTRACT_LINK"
fi
ln -s "$REPO_DIR/CLAUDE.md" "$CONTRACT_LINK"
echo "  td-flow-contract.md linked"

# 6. Sync the framework repo's own pre-commit hook. install.sh always runs
#    from the framework repo (which IS a td-flow project), so this dogfoods
#    the same setup consumer projects get via /td-flow-init Step 5. Without
#    it, an edit to hooks/pre-commit doesn't take effect on commits to this
#    repo until someone manually copies — silent drift caught in v7.3.
HOOK_SRC="$REPO_DIR/hooks/pre-commit"
HOOK_DST="$REPO_DIR/.git/hooks/pre-commit"
if [ -f "$HOOK_SRC" ] && [ -d "$REPO_DIR/.git/hooks" ]; then
  if [ ! -f "$HOOK_DST" ] || ! cmp -s "$HOOK_SRC" "$HOOK_DST"; then
    cp "$HOOK_SRC" "$HOOK_DST"
    chmod +x "$HOOK_DST"
    echo "→ synced framework pre-commit hook"
    echo "  $HOOK_DST"
  fi
fi

echo
echo "td-flow installed."
echo

if [ "$V6_RENAME_DETECTED" = "true" ]; then
  cat <<'BANNER'
─────────────────────────────────────────────────────
  td-flow v6.0 — slash commands renamed
─────────────────────────────────────────────────────
  All commands now use the /td-flow-* prefix:

    /td-init           →  /td-flow-init
    /td-clear          →  /td-flow-clear
    /td-close          →  /td-flow-close
    /td-refresh        →  /td-flow-refresh
    /td-mailbox        →  /td-flow-mailbox
    /td-health         →  /td-flow-health
    /td-incident       →  /td-flow-incident
    /td-park           →  /td-flow-park
    /td-snapshot       →  /td-flow-snapshot
    /td-complex-clear  →  /td-flow-complex-clear

  Old names removed (clean break — no aliases).
  Update your muscle memory.
─────────────────────────────────────────────────────

BANNER
fi

if [ "$V6_1_SKILL_DETECTED" = "true" ]; then
  cat <<'BANNER'
─────────────────────────────────────────────────────
  td-flow v6.1 — skill retired
─────────────────────────────────────────────────────
  The `td-flow` skill at ~/.claude/skills/td-flow was
  vestigial — it duplicated the rhythm + file structure
  + command list that the contract already covers via
  `@import` in every td-flow project's CLAUDE.md.

  Old symlink pruned. Nothing to migrate; the contract
  is unchanged. `/td-flow` will no longer appear in
  Claude Code's slash-command autocomplete.
─────────────────────────────────────────────────────

BANNER
fi

if [ "$V7_DIR_RENAME_DETECTED" = "true" ]; then
  cat <<'BANNER'
─────────────────────────────────────────────────────
  td-flow v7.0 — state dir renamed .td/ → .td-flow/
─────────────────────────────────────────────────────
  The per-project state directory is now `.td-flow/`
  (matches the framework name: `td-flow`, `/td-flow-*`,
  `td-flow-contract.md`). Last spot where the name
  didn't carry the prefix.

  Framework code now reads from `.td-flow/`, with a
  `.td/` fallback (transition safety net — keeps
  pre-migration projects working until you refresh
  them).

  Per-project migration:

    cd <your td-flow project>
    /td-flow-refresh

  → `git mv .td .td-flow` (history preserved) +
    creates `.td → .td-flow` compat symlink so any
    user-side `.td/` references keep resolving.

  Idempotent: skips projects already on .td-flow/.
  The fallback + compat symlink stay until v8.0.
─────────────────────────────────────────────────────

BANNER
fi

# Create the v7.0 ack marker so future installs skip the banner — runs
# regardless of whether the banner fired (silent on fresh installs).
touch "$V7_MARKER"

echo "Try it:"
echo "  cd ~/projects/some-project"
echo "  claude"
echo "  /td-flow-init           # bootstrap td-flow"
echo
echo "Cross-project requests ride on GitHub issues — see CLAUDE.md § Cross-repo."
echo "Add a \`## Cross-repo\` section to .td-flow/PROJECT.md per project — see CLAUDE.md § Cross-repo."
echo
echo "To update later: pull this repo, then re-run ./install.sh"
