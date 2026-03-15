#!/usr/bin/env bash
# Dashboard provider: time since previous human message
# Self-updating: reads previous timestamp, outputs delta, writes current timestamp.
# Runs on every UserPromptSubmit via the dashboard hook.
# Output: "3m" or "1h12m" or "<1m"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/escort"
STATE_FILE="$STATE_DIR/last-human-msg"

mkdir -p "$(dirname "$STATE_FILE")"

NOW=$(date +%s)

# Read previous timestamp (if any)
if [ -f "$STATE_FILE" ]; then
  PREV=$(cat "$STATE_FILE")

  if [ -n "$PREV" ]; then
    ELAPSED=$((NOW - PREV))

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
  fi
fi

# Write current timestamp for next invocation
echo "$NOW" > "$STATE_FILE"
