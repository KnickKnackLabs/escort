#!/usr/bin/env bash
# Dashboard provider: unread mail breakdown by source
# Output: "2h 8a 1g" (human, agent, github)
# Agent: *@ricon.family senders
# GitHub: *-ricon senders (notification bots)
# Human: everything else
set -euo pipefail

MAIL=$(shimmer email:list -n 200 2>/dev/null | grep ' \*' || true)
[ -z "$MAIL" ] && exit 0

HUMAN=0
AGENT=0
GITHUB=0

while IFS= read -r line; do
  FROM=$(echo "$line" | awk -F'|' '{print $5}' | tr -d ' ')
  case "$FROM" in
    *@ricon.family) AGENT=$((AGENT + 1)) ;;
    *-ricon)        GITHUB=$((GITHUB + 1)) ;;
    *)              HUMAN=$((HUMAN + 1)) ;;
  esac
done <<< "$MAIL"

PARTS=()
[ "$HUMAN" -gt 0 ] && PARTS+=("${HUMAN}h")
[ "$AGENT" -gt 0 ] && PARTS+=("${AGENT}a")
[ "$GITHUB" -gt 0 ] && PARTS+=("${GITHUB}g")

IFS=" "
echo "${PARTS[*]}"
