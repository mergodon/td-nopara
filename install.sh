#!/usr/bin/env bash
# td-flow installer — symlinks slash commands, the skill, and the templates dir into ~/.claude/.
# Idempotent: safe to re-run after pulling updates.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SKILLS_DIR="$CLAUDE_DIR/skills"
TEMPLATES_LINK="$CLAUDE_DIR/td-templates"
BIN_DIR="$HOME/bin"

mkdir -p "$COMMANDS_DIR" "$SKILLS_DIR" "$BIN_DIR"

# 1. Prune stale symlinks pointing into this repo's commands/ dir
#    (catches retired commands like /td-ship from older versions)
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

# 5. Symlink the td-bus CLI into $HOME/bin (cross-project messaging)
echo "→ installing td-bus CLI to $BIN_DIR/td-bus"
BUS_LINK="$BIN_DIR/td-bus"
if [ -L "$BUS_LINK" ] || [ -f "$BUS_LINK" ]; then
  rm "$BUS_LINK"
fi
ln -s "$REPO_DIR/bin/td-bus" "$BUS_LINK"
echo "  td-bus linked"

if ! command -v python3 >/dev/null 2>&1; then
  echo "  warning: python3 not found on PATH — td-bus needs it. Install via Xcode CLT or brew."
fi

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "  note: $BIN_DIR is not on your PATH. Add to your shell rc:  export PATH=\"\$HOME/bin:\$PATH\"" ;;
esac

echo
echo "td-flow installed."
echo
echo "Try it:"
echo "  cd ~/projects/some-project"
echo "  claude"
echo "  /td-init           # bootstrap td-flow"
echo "  /td-bus-init       # opt-in to cross-project messaging (needs Turso DB + TD_BUS_URL/TD_BUS_TOKEN env vars; see README § td-bus)"
echo
echo "To update later: pull this repo, then re-run ./install.sh"
