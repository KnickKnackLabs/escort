#!/usr/bin/env bash
# Dashboard provider: total unread chat messages
# Output: "19" or empty if no unread
# Requires: chat CLI, CHAT_IDENTITY env var
set -euo pipefail

command -v chat &>/dev/null || exit 0
[ -z "${CHAT_IDENTITY:-}" ] && exit 0

CHANNELS=$(chat list --json 2>/dev/null) || exit 0
[ -z "$CHANNELS" ] || [ "$CHANNELS" = "[]" ] && exit 0

TOTAL=0
while IFS= read -r name; do
  [ -z "$name" ] && continue
  COUNT=$(chat read --peek --json "$name" 2>/dev/null | jq 'length' 2>/dev/null) || continue
  TOTAL=$((TOTAL + COUNT))
done < <(echo "$CHANNELS" | jq -r '.[].name')

[ "$TOTAL" -eq 0 ] && exit 0

echo "$TOTAL"
