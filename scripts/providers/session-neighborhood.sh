#!/usr/bin/env bash
# Dashboard provider: active sibling sessions and recent sessions for this agent identity
# Output: active 019e002f-d66b recent 019df64c-a7eb
set -euo pipefail

SESSION_ID="${HOOKERS_SESSION_ID:-}"
[ -z "$SESSION_ID" ] && exit 0

IDENTITY="${CHAT_IDENTITY:-${GIT_AUTHOR_NAME:-default}}"
# Keep identity safe as a directory name while preserving readability.
IDENTITY_SAFE=$(printf '%s' "$IDENTITY" | sed 's/[^A-Za-z0-9._@-]/_/g')

STATE_ROOT="${ESCORT_SESSION_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/escort/sessions}"
IDENTITY_DIR="$STATE_ROOT/$IDENTITY_SAFE"
mkdir -p "$IDENTITY_DIR"

NOW=$(date +%s)
ACTIVE_TTL="${ESCORT_SESSION_ACTIVE_TTL:-1800}"
RECENT_LIMIT="${ESCORT_SESSION_RECENT_LIMIT:-1}"
PREFIX_LEN="${ESCORT_SESSION_ID_PREFIX_LEN:-13}"
CWD_VALUE="${HOOKERS_CWD:-${PWD:-}}"
CURRENT_FILE="$IDENTITY_DIR/$SESSION_ID.json"

FIRST_SEEN="$NOW"
if [ -f "$CURRENT_FILE" ]; then
  existing_first=$(jq -r '.first_seen_at // empty' "$CURRENT_FILE" 2>/dev/null || true)
  if [ -n "$existing_first" ]; then
    FIRST_SEEN="$existing_first"
  fi
fi

TMP_FILE="$CURRENT_FILE.tmp.$$"
jq -n \
  --arg session_id "$SESSION_ID" \
  --arg cwd "$CWD_VALUE" \
  --argjson first_seen_at "$FIRST_SEEN" \
  --argjson last_seen_at "$NOW" \
  '{session_id: $session_id, first_seen_at: $first_seen_at, last_seen_at: $last_seen_at, cwd: $cwd}' \
  > "$TMP_FILE"
mv "$TMP_FILE" "$CURRENT_FILE"

ACTIVE_FILE=$(mktemp)
RECENT_FILE=$(mktemp)
trap 'rm -f "$ACTIVE_FILE" "$RECENT_FILE"' EXIT

for f in "$IDENTITY_DIR"/*.json; do
  [ -f "$f" ] || continue

  sid=$(jq -r '.session_id // empty' "$f" 2>/dev/null || true)
  last_seen=$(jq -r '.last_seen_at // empty' "$f" 2>/dev/null || true)

  [ -z "$sid" ] && continue
  [ -z "$last_seen" ] && continue
  [ "$sid" = "$SESSION_ID" ] && continue
  case "$last_seen" in
    *[!0-9]* ) continue ;;
  esac

  short_sid=$(printf '%s' "$sid" | cut -c "1-${PREFIX_LEN}")
  age=$((NOW - last_seen))
  if [ "$age" -le "$ACTIVE_TTL" ]; then
    printf '%s %s\n' "$last_seen" "$short_sid" >> "$ACTIVE_FILE"
  else
    printf '%s %s\n' "$last_seen" "$short_sid" >> "$RECENT_FILE"
  fi
done

OUT=""
if [ -s "$ACTIVE_FILE" ]; then
  active=$(sort -nr "$ACTIVE_FILE" | awk '{print $2}' | paste -sd ' ' -)
  if [ -n "$active" ]; then
    OUT="active $active"
  fi
fi

if [ -s "$RECENT_FILE" ] && [ "$RECENT_LIMIT" -gt 0 ]; then
  recent=$(sort -nr "$RECENT_FILE" | awk '{print $2}' | head -n "$RECENT_LIMIT" | paste -sd ' ' -)
  if [ -n "$recent" ]; then
    if [ -n "$OUT" ]; then
      OUT="$OUT recent $recent"
    else
      OUT="recent $recent"
    fi
  fi
fi

[ -n "$OUT" ] && echo "$OUT"
exit 0
