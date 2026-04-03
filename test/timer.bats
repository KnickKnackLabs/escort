#!/usr/bin/env bats

setup() {
  load helpers
  TEST_DIR="$(mktemp -d)"
  export ESCORT_STATE_DIR="$TEST_DIR/escort"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "timer start creates session-start file" {
  run escort timer start
  [ "$status" -eq 0 ]
  [ -f "$ESCORT_STATE_DIR/session-start" ]
  CONTENT=$(cat "$ESCORT_STATE_DIR/session-start")
  [[ "$CONTENT" =~ ^[0-9]+$ ]]
}

@test "timer stop creates agent-stop file" {
  run escort timer stop
  [ "$status" -eq 0 ]
  [ -f "$ESCORT_STATE_DIR/agent-stop" ]
  CONTENT=$(cat "$ESCORT_STATE_DIR/agent-stop")
  [[ "$CONTENT" =~ ^[0-9]+$ ]]
}

@test "timer rejects unknown action" {
  run escort timer invalid
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown action"* ]]
}

@test "timer start is idempotent" {
  escort timer start
  FIRST=$(cat "$ESCORT_STATE_DIR/session-start")

  sleep 1
  escort timer start
  SECOND=$(cat "$ESCORT_STATE_DIR/session-start")

  [ "$SECOND" -ge "$FIRST" ]
}
