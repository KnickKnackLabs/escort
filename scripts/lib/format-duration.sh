#!/usr/bin/env bash
# Format a duration in seconds as a human-readable string.
# Usage: format_duration <seconds>
# Output: "<1m", "3m", "1h12m", "2h"
set -euo pipefail

format_duration() {
  local elapsed=$1

  if [ "$elapsed" -lt 60 ]; then
    echo "<1m"
  elif [ "$elapsed" -lt 3600 ]; then
    echo "$((elapsed / 60))m"
  else
    local h=$((elapsed / 3600))
    local m=$(( (elapsed % 3600) / 60 ))
    if [ "$m" -gt 0 ]; then
      echo "${h}h${m}m"
    else
      echo "${h}h"
    fi
  fi
}
