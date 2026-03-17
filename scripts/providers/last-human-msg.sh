#!/usr/bin/env bash
# Dashboard provider: time since previous human message
# Self-updating: reads previous timestamp, outputs delta, writes current timestamp.
# Runs on every UserPromptSubmit via the dashboard hook.
# Output: "3m" or "1h12m" or "<1m"

source "$MISE_CONFIG_ROOT/scripts/lib/format-duration.sh"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/escort"
STATE_FILE="$STATE_DIR/last-human-msg"

mkdir -p "$STATE_DIR"

NOW=$(date +%s)

# Read previous timestamp (if any)
if [ -f "$STATE_FILE" ]; then
  read -r PREV < "$STATE_FILE"

  if [ -n "$PREV" ]; then
    ELAPSED=$((NOW - PREV))
    format_duration "$ELAPSED"
  fi
fi

# Write current timestamp for next invocation
echo "$NOW" > "$STATE_FILE"
