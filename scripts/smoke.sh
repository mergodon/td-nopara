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
' .td-flow/WORKWAY.md | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
if [ -n "$extracted" ]; then
  ok "AWK extractor returns Test command value: '$extracted'"
else
  fail "AWK extractor produced no value from .td-flow/WORKWAY.md § Local testing"
fi

# 6. Cross-reference: every command file in commands/ is mentioned in
#    CLAUDE.md (contract trigger map), README.md install symlinks list, AND
#    README.md slash commands table. Catches the "added a command, forgot
#    to fold it into the canonical surfaces" drift — the bug that left
#    /td-flow-complex-clear off every canonical "Nine commands" list for
#    multiple versions before v6.0 cleanup folded it in.
cross_ref_missing=0
for cmd in commands/td-flow-*.md; do
  name=$(basename "$cmd" .md)
  # Skip if not in EXPECTED_COMMANDS (the unexpected-warn handles those).
  in_expected=0
  for c in "${EXPECTED_COMMANDS[@]}"; do
    [ "$c" = "$name" ] && { in_expected=1; break; }
  done
  [ "$in_expected" -eq 0 ] && continue

  if ! grep -q "^- \`/$name\`" CLAUDE.md; then
    fail "$name: not in CLAUDE.md command list (expected '- \`/$name\`' line)"
    cross_ref_missing=$((cross_ref_missing+1))
  fi
  if ! grep -q "~/.claude/commands/$name.md" README.md; then
    fail "$name: not in README.md install symlinks list"
    cross_ref_missing=$((cross_ref_missing+1))
  fi
  if ! grep -q "^| \`/$name\`" README.md; then
    fail "$name: not in README.md slash commands table"
    cross_ref_missing=$((cross_ref_missing+1))
  fi
done
[ "$cross_ref_missing" -eq 0 ] && ok "all 10 commands cross-referenced in CLAUDE.md + README.md"

# 7. Every command file has YAML frontmatter with a non-empty description.
#    Claude Code uses the description for autocomplete + skill detection —
#    missing or empty description silently breaks discovery.
fm_broken=0
for cmd in commands/td-flow-*.md; do
  name=$(basename "$cmd" .md)
  if [ "$(head -1 "$cmd")" != "---" ]; then
    fail "$name: missing YAML frontmatter (first line is not '---')"
    fm_broken=$((fm_broken+1))
    continue
  fi
  desc=$(awk '
    NR==1 && /^---$/ { in_fm=1; next }
    in_fm && /^---$/ { exit }
    in_fm && /^description:/ {
      sub(/^description:[[:space:]]*/, "")
      print
      exit
    }
  ' "$cmd" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
  if [ -z "$desc" ]; then
    fail "$name: missing or empty 'description:' field in frontmatter"
    fm_broken=$((fm_broken+1))
  fi
done
[ "$fm_broken" -eq 0 ] && ok "all 10 commands have valid frontmatter with non-empty description"

# 8. /td-flow-complex-clear structural anchors — load-bearing pieces that
#    a future edit must preserve. (a) Step 7.5 self-validation gate, the
#    enforce-then-iterate mechanism. (b) "Resume — start here" lead block
#    requirement (added in b23a488 after garmin's maiden run skipped the
#    bottom-buried first-action pointer on resume — fix made the pointer
#    physically first in the resume note).
CC=commands/td-flow-complex-clear.md
cc_missing=0
if ! grep -q '^# Step 7\.5 — Self-validation gate' "$CC"; then
  fail "td-flow-complex-clear: Step 7.5 self-validation gate header missing"
  cc_missing=$((cc_missing+1))
fi
if ! grep -q 'Resume — start here' "$CC"; then
  fail "td-flow-complex-clear: 'Resume — start here' lead block requirement missing"
  cc_missing=$((cc_missing+1))
fi
[ "$cc_missing" -eq 0 ] && ok "td-flow-complex-clear structural anchors present (Step 7.5 + Resume — start here)"

# Summary
echo
echo "Summary: $PASS OK, $WARN WARN, $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 2
[ "$WARN" -gt 0 ] && exit 1
exit 0
