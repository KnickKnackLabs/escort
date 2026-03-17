#!/usr/bin/env bats

setup() {
  load helpers
  setup_test_state
}

# ============ last-human-msg ============

@test "last-human-msg: no previous timestamp produces no output" {
  run run_provider last-human-msg
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "last-human-msg: writes timestamp for next invocation" {
  run_provider last-human-msg
  [ -f "$XDG_STATE_HOME/escort/last-human-msg" ]
  # File should contain a unix timestamp
  [[ "$(cat "$XDG_STATE_HOME/escort/last-human-msg")" =~ ^[0-9]+$ ]]
}

@test "last-human-msg: shows delta from previous timestamp" {
  local now
  now=$(date +%s)
  write_timestamp "last-human-msg" $((now - 300))

  run run_provider last-human-msg
  [ "$status" -eq 0 ]
  [ "$output" = "5m" ]
}

@test "last-human-msg: short gap shows <1m" {
  local now
  now=$(date +%s)
  write_timestamp "last-human-msg" $((now - 10))

  run run_provider last-human-msg
  [ "$status" -eq 0 ]
  [ "$output" = "<1m" ]
}

@test "last-human-msg: long gap shows hours" {
  local now
  now=$(date +%s)
  write_timestamp "last-human-msg" $((now - 7200))

  run run_provider last-human-msg
  [ "$status" -eq 0 ]
  [ "$output" = "2h" ]
}

# ============ session-elapsed ============

@test "session-elapsed: no state file exits cleanly" {
  run run_provider session-elapsed
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "session-elapsed: shows time since session start" {
  local now
  now=$(date +%s)
  write_timestamp "session-start" $((now - 2700))

  run run_provider session-elapsed
  [ "$status" -eq 0 ]
  [ "$output" = "45m" ]
}

@test "session-elapsed: empty state file exits cleanly" {
  echo "" > "$XDG_STATE_HOME/escort/session-start"

  run run_provider session-elapsed
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# ============ XDG compliance ============

@test "last-human-msg: respects XDG_STATE_HOME" {
  run_provider last-human-msg
  [ -f "$XDG_STATE_HOME/escort/last-human-msg" ]
  # Should NOT be in the default location
  [ ! -f "$HOME/.local/state/escort/last-human-msg" ] || \
    [ "$XDG_STATE_HOME" != "$HOME/.local/state" ]
}

@test "session-elapsed: respects XDG_STATE_HOME" {
  local now
  now=$(date +%s)
  write_timestamp "session-start" $((now - 60))

  run run_provider session-elapsed
  [ "$status" -eq 0 ]
  [ "$output" = "1m" ]
}
