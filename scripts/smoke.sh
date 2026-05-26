#!/usr/bin/env bash
# td-flow smoke check — automates the WORKWAY § Local testing pre-ship list.
# Output protocol mirrors /td-flow-health: OK/WARN/FAIL lines, exit 0/1/2.

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

PASS=0
WARN=0
FAIL=0

ok()   { echo "OK   $1"; PASS=$((PASS+1)); }
warn() { echo "WARN $1"; WARN=$((WARN+1)); }
fail() { echo "FAIL $1"; FAIL=$((FAIL+1)); }

# 1. Bash syntax — install.sh + pre-commit hook
if bash -n install.sh 2>/dev/null; then
  ok "install.sh — bash syntax"
else
  fail "install.sh — bash syntax error"
fi

if bash -n hooks/pre-commit 2>/dev/null; then
  ok "hooks/pre-commit — bash syntax"
else
  fail "hooks/pre-commit — bash syntax error"
fi

# Check current install state BEFORE running install.sh (which self-heals).
# install.sh idempotency runs last for that reason.

# 2. All 10 slash commands resolve in ~/.claude/commands/
EXPECTED_COMMANDS=(td-flow-init td-flow-clear td-flow-complex-clear td-flow-close td-flow-refresh td-flow-mailbox td-flow-health td-flow-incident td-flow-park td-flow-snapshot)
missing=0
for c in "${EXPECTED_COMMANDS[@]}"; do
  link="$HOME/.claude/commands/$c.md"
  if [ ! -L "$link" ] || [ ! -e "$link" ]; then
    fail "command symlink broken or missing: $c.md"
    missing=$((missing+1))
  fi
done
[ "$missing" -eq 0 ] && ok "all 10 slash commands resolve in ~/.claude/commands/"

# Bonus: warn if extra commands not on the expected list are present (likely retired but un-pruned)
for link in "$HOME/.claude/commands/"*.md; do
  [ -L "$link" ] || continue
  target=$(readlink "$link")
  case "$target" in
    "$(pwd)/commands/"*)
      name=$(basename "$link" .md)
      keep=0
      for c in "${EXPECTED_COMMANDS[@]}"; do
        [ "$c" = "$name" ] && { keep=1; break; }
      done
      [ "$keep" -eq 0 ] && warn "unexpected td-flow command symlinked: $name (not in EXPECTED_COMMANDS — retired?)"
      ;;
  esac
done

# 3. Templates + contract symlinks
for path in \
  "td-templates" \
  "td-flow-contract.md"; do
  link="$HOME/.claude/$path"
  if [ -L "$link" ] && [ -e "$link" ]; then
    ok "~/.claude/$path resolves"
  else
    fail "~/.claude/$path missing or broken"
  fi
done

# 4. install.sh idempotency — run twice, both must exit 0. Runs LAST because
#    install.sh self-heals symlinks; running it earlier would mask checks 2+3.
if ./install.sh >/dev/null 2>&1 && ./install.sh >/dev/null 2>&1; then
  ok "install.sh — idempotent (two consecutive runs)"
else
  fail "install.sh — not idempotent or errors out"
fi

# 5. AWK extractor — verify it returns a non-empty value from this project's WORKWAY
extracted=$(awk '
  /^## Local testing/ { in_section = 1; next }
  /^## / && in_section { exit }
  in_section && /^- Test command:/ {
    sub(/^- Test command:[[:space:]]*/, "")
    print
    exit
  }
' .td/WORKWAY.md | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
if [ -n "$extracted" ]; then
  ok "AWK extractor returns Test command value: '$extracted'"
else
  fail "AWK extractor produced no value from .td/WORKWAY.md § Local testing"
fi

# Summary
echo
echo "Summary: $PASS OK, $WARN WARN, $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 2
[ "$WARN" -gt 0 ] && exit 1
exit 0
