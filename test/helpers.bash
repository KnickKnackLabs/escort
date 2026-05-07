# Shared helpers for escort BATS tests
#
# ESCORT_ROOT must be set by the test runner (mise task).

if [ -z "${ESCORT_ROOT:-}" ]; then
  echo "ESCORT_ROOT not set — run tests via: mise run test" >&2
  exit 1
fi

# Call escort tasks through mise — the only layer between tests and mise.
escort() {
  (cd "$ESCORT_ROOT" && mise run -q "$@")
}
export -f escort

# Source the format-duration library (for unit tests only)
source "$ESCORT_ROOT/scripts/lib/format-duration.sh"

# Create an isolated state directory for testing providers
# Sets: XDG_STATE_HOME (overridden for isolation)
# Also sets MISE_TRUSTED_CONFIG_PATHS so mise doesn't lose trust when
# XDG_STATE_HOME moves the trust database to a temp dir.
setup_test_state() {
  export XDG_STATE_HOME="$BATS_TEST_TMPDIR/xdg-state-$$"
  export MISE_TRUSTED_CONFIG_PATHS="$ESCORT_ROOT"
  mkdir -p "$XDG_STATE_HOME/escort"
}

# Write a timestamp to a state file
# Usage: write_timestamp <filename> <epoch_seconds>
write_timestamp() {
  local filename="$1" epoch="$2"
  echo "$epoch" > "$XDG_STATE_HOME/escort/$filename"
}

# Write a session-neighborhood heartbeat fixture
# Usage: write_session <identity> <session_id> <first_seen> <last_seen> [cwd]
write_session() {
  local identity="$1" session_id="$2" first_seen="$3" last_seen="$4" cwd="${5:-/tmp/test-workspace}"
  local dir="$XDG_STATE_HOME/escort/sessions/$identity"
  mkdir -p "$dir"
  jq -n \
    --arg session_id "$session_id" \
    --arg cwd "$cwd" \
    --argjson first_seen_at "$first_seen" \
    --argjson last_seen_at "$last_seen" \
    '{session_id: $session_id, first_seen_at: $first_seen_at, last_seen_at: $last_seen_at, cwd: $cwd}' \
    > "$dir/$session_id.json"
}
