#!/usr/bin/env bash
# Dashboard provider: total unread chat messages
# Output: "19" or empty if no unread
# Requires: chat CLI, CHAT_IDENTITY env var
set -euo pipefail

command -v chat &>/dev/null || exit 0
[ -z "${CHAT_IDENTITY:-}" ] && exit 0

# Use bulk unread command (single invocation, parallel internally)
chat unread 2>/dev/null || exit 0
