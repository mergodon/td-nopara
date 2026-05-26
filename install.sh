#!/usr/bin/env bash
# td-flow installer — symlinks slash commands, the skill, and the templates dir into ~/.claude/.
# Idempotent: safe to re-run after pulling updates.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SKILLS_DIR="$CLAUDE_DIR/skills"
TEMPLATES_LINK="$CLAUDE_DIR/td-templates"

mkdir -p "$COMMANDS_DIR" "$SKILLS_DIR"

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

# 3. Symlink the skill
echo "→ installing skill to $SKILLS_DIR/td-flow"
SKILL_LINK="$SKILLS_DIR/td-flow"
if [ -L "$SKILL_LINK" ] || [ -d "$SKILL_LINK" ]; then
  rm -rf "$SKILL_LINK"
fi
ln -s "$REPO_DIR/skill" "$SKILL_LINK"
echo "  td-flow"

# 4. Symlink templates dir (commands resolve files from here)
echo "→ linking templates to $TEMPLATES_LINK"
if [ -L "$TEMPLATES_LINK" ] || [ -d "$TEMPLATES_LINK" ]; then
  rm -rf "$TEMPLATES_LINK"
fi
ln -s "$REPO_DIR/templates" "$TEMPLATES_LINK"
echo "  templates linked"

# 5. Symlink the canonical contract — projects @import this, instead of each
#    carrying its own full copy in CLAUDE.md.
CONTRACT_LINK="$CLAUDE_DIR/td-flow-contract.md"
echo "→ linking contract to $CONTRACT_LINK"
if [ -L "$CONTRACT_LINK" ] || [ -f "$CONTRACT_LINK" ]; then
  rm "$CONTRACT_LINK"
fi
ln -s "$REPO_DIR/CLAUDE.md" "$CONTRACT_LINK"
echo "  td-flow-contract.md linked"

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

echo "Try it:"
echo "  cd ~/projects/some-project"
echo "  claude"
echo "  /td-flow-init           # bootstrap td-flow"
echo
echo "Cross-project requests ride on GitHub issues — see CLAUDE.md § Cross-repo."
echo "Add a \`## Cross-repo\` section to .td/PROJECT.md per project — see CLAUDE.md § Cross-repo."
echo
echo "To update later: pull this repo, then re-run ./install.sh"
