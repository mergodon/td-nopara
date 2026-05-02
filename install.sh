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

# 1. Symlink slash commands
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

# 2. Symlink the skill
echo "→ installing skill to $SKILLS_DIR/td-flow"
SKILL_LINK="$SKILLS_DIR/td-flow"
if [ -L "$SKILL_LINK" ] || [ -d "$SKILL_LINK" ]; then
  rm -rf "$SKILL_LINK"
fi
ln -s "$REPO_DIR/skill" "$SKILL_LINK"
echo "  td-flow"

# 3. Symlink templates dir (commands resolve files from here)
echo "→ linking templates to $TEMPLATES_LINK"
if [ -L "$TEMPLATES_LINK" ] || [ -d "$TEMPLATES_LINK" ]; then
  rm -rf "$TEMPLATES_LINK"
fi
ln -s "$REPO_DIR/templates" "$TEMPLATES_LINK"
echo "  templates linked"

echo
echo "td-flow installed."
echo
echo "Try it:"
echo "  cd ~/projects/some-project"
echo "  claude"
echo "  /td-init"
echo
echo "To update later: pull this repo, then re-run ./install.sh"
