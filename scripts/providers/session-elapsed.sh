#!/usr/bin/env bash
# Dashboard provider: time since session started
# Reads timestamp from $XDG_STATE_HOME/escort/session-start
# Written by the session-timer hook (catalog/session-timer.json)
# Output: "47m" or "2h13m"
set -euo pipefail

source "$MISE_CONFIG_ROOT/scripts/lib/format-duration.sh"

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/escort/session-start"
[ ! -f "$STATE_FILE" ] && exit 0

read -r START < "$STATE_FILE"
[ -z "$START" ] && exit 0

NOW=$(date +%s)
ELAPSED=$((NOW - START))

format_duration "$ELAPSED"
