#!/usr/bin/env bash
# {{PROJECT}} — production health check.
#
# Run it:  .td/health.sh   (directly, or via the /td-health command)
#
# CONTRACT — /td-health depends on this, keep it intact:
#   * every check prints ONE line via ok / warn / fail below
#   * exit 0 = all OK   ·   exit 1 = any WARN   ·   exit 2 = any FAIL
#   * read-only: this script observes production, it never mutates it
#
# This is a starting skeleton. Keep the helpers and the exit contract; replace
# the example checks with whatever actually tells you THIS app is healthy.

set -uo pipefail

# --- config — edit these -----------------------------------------------------
PROD_URL="{{PROD_URL}}"            # e.g. https://app.example.com
# SSH_ALIAS="myhost"               # uncomment if a check needs the deploy box
# REPO_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

WARN=0
FAIL=0
START_TS=$(date +%s)

ok()      { printf "  \033[32mOK  \033[0m %-12s %s\n" "$1" "$2"; }
warn()    { printf "  \033[33mWARN\033[0m %-12s %s\n" "$1" "$2"; WARN=$((WARN+1)); }
fail()    { printf "  \033[31mFAIL\033[0m %-12s %s\n" "$1" "$2"; FAIL=$((FAIL+1)); }
section() { printf "\n\033[1m── %s ──\033[0m\n" "$1"; }

printf "\033[1m{{PROJECT}} — health\033[0m  %s\n" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# --- app reachable -----------------------------------------------------------
# The one check almost every web app wants. Point it at a cheap health route
# (Laravel ships /up; otherwise the homepage or a dedicated /health route).
section "app"
CODE=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 5 "$PROD_URL" 2>/dev/null || echo "000")
case "$CODE" in
  200|204) ok   "reachable" "$PROD_URL → $CODE" ;;
  000)     fail "reachable" "no response (timeout/network)" ;;
  *)       fail "reachable" "$PROD_URL → $CODE" ;;
esac

# --- example: disk on the deploy box (uncomment + adapt) ---------------------
# Anything you can check over one SSH roundtrip — disk, a process, a queue.
# section "deploy box"
# PCT=$(ssh -o ConnectTimeout=5 "$SSH_ALIAS" 'df --output=pcent / | tail -1 | tr -dc 0-9' 2>/dev/null)
# if   [[ -z "$PCT" ]];     then fail "ssh"  "couldn't reach $SSH_ALIAS"
# elif [[ "$PCT" -ge 90 ]]; then fail "disk" "${PCT}% full on /"
# elif [[ "$PCT" -ge 75 ]]; then warn "disk" "${PCT}% full on /"
# else                           ok   "disk" "${PCT}% used on /"
# fi

# --- example: deployed code in sync with origin/main (uncomment + adapt) -----
# section "deploy"
# PROD_SHA=$(ssh -o ConnectTimeout=5 "$SSH_ALIAS" 'cd /srv/app/current && git rev-parse HEAD' 2>/dev/null)
# LOCAL_SHA=$(git -C "$REPO_PATH" rev-parse origin/main 2>/dev/null)
# if   [[ -z "$PROD_SHA" ]];              then fail "deploy" "couldn't read prod SHA"
# elif [[ "$PROD_SHA" == "$LOCAL_SHA" ]]; then ok   "deploy" "in sync (${PROD_SHA:0:7})"
# else                                         warn "deploy" "prod ${PROD_SHA:0:7} ≠ main ${LOCAL_SHA:0:7}"
# fi

# Add the checks that prove THIS app is alive: queue depth, worker/daemon
# status, failed-job count, error rate, TLS cert expiry, a critical cron's
# last run. One SSH roundtrip can carry several — batch them.

# --- summary -----------------------------------------------------------------
section "summary"
printf "  %d WARN · %d FAIL · %ss elapsed\n" "$WARN" "$FAIL" "$(( $(date +%s) - START_TS ))"

if   [[ $FAIL -gt 0 ]]; then exit 2
elif [[ $WARN -gt 0 ]]; then exit 1
else                          exit 0
fi
