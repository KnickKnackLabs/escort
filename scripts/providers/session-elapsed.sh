#!/usr/bin/env bash
# Dashboard provider: time since session started
# Reads timestamp from ~/.local/state/escort/session-start
# Written by the session-timer hook (catalog/session-timer.json)
# Output: "47m" or "2h13m"

STATE_FILE="${HOME}/.local/state/escort/session-start"
[ ! -f "$STATE_FILE" ] && exit 0

START=$(cat "$STATE_FILE")
[ -z "$START" ] && exit 0

NOW=$(date +%s)
ELAPSED=$((NOW - START))

if [ "$ELAPSED" -lt 60 ]; then
  echo "<1m"
elif [ "$ELAPSED" -lt 3600 ]; then
  echo "$((ELAPSED / 60))m"
else
  H=$((ELAPSED / 3600))
  M=$(( (ELAPSED % 3600) / 60 ))
  if [ "$M" -gt 0 ]; then
    echo "${H}h${M}m"
  else
    echo "${H}h"
  fi
fi
