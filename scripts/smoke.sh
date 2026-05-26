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

# 3a. Framework pre-commit hook in sync with canonical (drift catcher).
#     install.sh Step 6 syncs hooks/pre-commit → .git/hooks/pre-commit on
#     every install. Must run BEFORE check #4 (install.sh idempotency)
#     because that step self-heals the drift silently. Surfaces "you edited
#     hooks/pre-commit without re-running install.sh" as a fail-fast cause,
#     not a hidden auto-fix. Only meaningful in the framework repo (where
#     hooks/ source lives).
if [ -f hooks/pre-commit ] && [ -d .git/hooks ]; then
  if [ ! -f .git/hooks/pre-commit ]; then
    fail "framework pre-commit hook not installed at .git/hooks/pre-commit (run ./install.sh)"
  elif ! cmp -s hooks/pre-commit .git/hooks/pre-commit; then
    fail "framework pre-commit hook drift: hooks/pre-commit differs from .git/hooks/pre-commit (run ./install.sh)"
  else
    ok "framework pre-commit hook in sync with canonical"
  fi
fi

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

# 8. Per-command load-bearing anchors. For each command, assert that
#    load-bearing strings (step headers, commit conventions, protocol
#    fragments, named procedure references) still exist in the file.
#    Catches silent regressions when an edit / refactor / AI rewrite
#    drops a piece the command's behavior depends on. Add a row when a
#    new load-bearing piece lands (e.g. v7.0 added refresh's Step 1.7).
#    Pattern is grep -qE (extended regex); use -i where case-insensitive
#    matters. Format: <command>|<pattern>|<short description>.
ANCHORS=(
  # /td-flow-init — Step 0 detection + Step 3 scaffold + @import target
  "td-flow-init|^# Step 0 — Detect|brownfield/v2/already-init detection branch"
  "td-flow-init|ln -s \.td-flow \.td|v7.0 compat symlink scaffold step"
  "td-flow-init|td-flow-contract\.md|@import target reference"

  # /td-flow-clear — STATE handoff + commit convention
  "td-flow-clear|^# Step 6 — Update STATE|STATE handoff step header"
  "td-flow-clear|chore: clear|commit message convention"

  # /td-flow-complex-clear — self-validation gate + lead block (b23a488)
  "td-flow-complex-clear|^# Step 7\.5 — Self-validation gate|self-validation gate (enforce-then-iterate)"
  "td-flow-complex-clear|Resume — start here|lead-block requirement (b23a488 — garmin's resume fix)"

  # /td-flow-close — framework-update check (v4.3) + commit + park delegation (v4.5)
  "td-flow-close|^# Step 11|framework-update check (v4.3)"
  "td-flow-close|chore: close|commit message convention"
  "td-flow-close|BACKLOG-flush procedure|delegates to /td-flow-park's canonical procedure (v4.5)"

  # /td-flow-refresh — framework sync + nudge prune + state-dir migration (v7.0) + safety flags
  "td-flow-refresh|^# Step 0 — Sync the framework|framework sync phase"
  "td-flow-refresh|^# Step 1\.5|deprecated-nudge prune"
  "td-flow-refresh|^# Step 1\.7|v7.0 .td → .td-flow migration step"
  "td-flow-refresh|--no-verify|doc-only commits skip pre-commit hook"
  "td-flow-refresh|--ff-only|never merge or force on framework pull"

  # /td-flow-mailbox — body marker + sub-issue support + cross-repo registry
  "td-flow-mailbox|\*\*From:\*\*|body marker for outbound identification"
  "td-flow-mailbox|sub_issues|GraphQL header for sub-issue rollup"
  "td-flow-mailbox|Cross-repo|connected-repos registry source"

  # /td-flow-health — protocol (OK/WARN/FAIL + exit codes) + script path + escalation
  "td-flow-health|OK/WARN/FAIL|protocol output format"
  "td-flow-health|= all OK|protocol exit-0 = all OK contract line"
  "td-flow-health|\.td-flow/health\.sh|project-owned health script path"
  "td-flow-health|/td-flow-incident|escalation path for FAIL"

  # /td-flow-incident — snapshot composition + STATE handling + read-only constraint
  "td-flow-incident|/td-flow-snapshot|composition (snapshot in-flight before pivot)"
  "td-flow-incident|STATE\.Topic|incident-mode STATE handling"
  "td-flow-incident|[Rr]ead-only|production diagnosis constraint"

  # /td-flow-park — consolidation (v4.5) + createIssue mutation + BACKLOG source
  "td-flow-park|consolidat|consolidation pass (v4.5)"
  "td-flow-park|createIssue|GraphQL mutation (gh issue create can't set Type)"
  "td-flow-park|BACKLOG\.md|source file reference"

  # /td-flow-snapshot — branch pattern + resume line + Snapshot Issue Type
  "td-flow-snapshot|snapshot/|snapshot branch name pattern"
  "td-flow-snapshot|claude --resume|resume line in Snapshot issue body"
  "td-flow-snapshot|Snapshot-type|Snapshot Issue Type filing"
)
anchors_missing=0
for entry in "${ANCHORS[@]}"; do
  IFS='|' read -r cmd pattern desc <<< "$entry"
  file="commands/$cmd.md"
  if [ ! -f "$file" ]; then
    fail "$cmd: command file missing (referenced by anchor check)"
    anchors_missing=$((anchors_missing+1))
    continue
  fi
  if ! grep -qE -e "$pattern" "$file"; then
    fail "$cmd: missing anchor — pattern '$pattern' ($desc)"
    anchors_missing=$((anchors_missing+1))
  fi
done
[ "$anchors_missing" -eq 0 ] && ok "all per-command load-bearing anchors present (${#ANCHORS[@]} across 10 commands)"

# Summary
echo
echo "Summary: $PASS OK, $WARN WARN, $FAIL FAIL"
[ "$FAIL" -gt 0 ] && exit 2
[ "$WARN" -gt 0 ] && exit 1
exit 0
