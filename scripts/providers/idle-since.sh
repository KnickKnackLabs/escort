#!/usr/bin/env bash
# Dashboard provider: time the agent has been idle (waiting for human input)
# Reads timestamp written by the Stop hook (agent finished responding).
# On each UserPromptSubmit, shows how long the agent was waiting.
# Output: "3m" or "1h12m" or "<1m"

source "$MISE_CONFIG_ROOT/scripts/lib/format-duration.sh"

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/escort/agent-stop"

[ ! -f "$STATE_FILE" ] && exit 0

read -r STOP_TIME < "$STATE_FILE"
[ -z "$STOP_TIME" ] && exit 0

NOW=$(date +%s)
ELAPSED=$((NOW - STOP_TIME))

format_duration "$ELAPSED"
