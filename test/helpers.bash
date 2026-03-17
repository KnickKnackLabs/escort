# Shared helpers for escort BATS tests
#
# ESCORT_ROOT must be set by the test runner (mise task).

# Source the format-duration library
source "$ESCORT_ROOT/scripts/lib/format-duration.sh"

# Create an isolated state directory for testing providers
# Sets: XDG_STATE_HOME (overridden for isolation)
setup_test_state() {
  export XDG_STATE_HOME="$BATS_TEST_TMPDIR/xdg-state-$$"
  mkdir -p "$XDG_STATE_HOME/escort"
}

# Write a timestamp to a state file
# Usage: write_timestamp <filename> <epoch_seconds>
write_timestamp() {
  local filename="$1" epoch="$2"
  echo "$epoch" > "$XDG_STATE_HOME/escort/$filename"
}

# Run a provider script with MISE_CONFIG_ROOT set
# Usage: run_provider <provider_name>
run_provider() {
  local name="$1"
  MISE_CONFIG_ROOT="$ESCORT_ROOT" bash "$ESCORT_ROOT/scripts/providers/${name}.sh"
}
