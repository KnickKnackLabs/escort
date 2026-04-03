#!/usr/bin/env bats

setup() {
  if [ -z "${ESCORT_ROOT:-}" ]; then
    echo "ESCORT_ROOT not set — run tests via: mise run test" >&2
    exit 1
  fi
  TEST_DIR="$(mktemp -d)"
  export ESCORT_STATE_DIR="$TEST_DIR/escort"
}

teardown() {
  rm -rf "$TEST_DIR"
}

escort_timer() {
  cd "$ESCORT_ROOT" && mise run -q timer "$@"
}
export -f escort_timer

@test "timer start creates session-start file" {
  run escort_timer start
  [ "$status" -eq 0 ]
  [ -f "$ESCORT_STATE_DIR/session-start" ]
  CONTENT=$(cat "$ESCORT_STATE_DIR/session-start")
  [[ "$CONTENT" =~ ^[0-9]+$ ]]
}

@test "timer stop creates agent-stop file" {
  run escort_timer stop
  [ "$status" -eq 0 ]
  [ -f "$ESCORT_STATE_DIR/agent-stop" ]
  CONTENT=$(cat "$ESCORT_STATE_DIR/agent-stop")
  [[ "$CONTENT" =~ ^[0-9]+$ ]]
}

@test "timer rejects unknown action" {
  run escort_timer invalid
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown action"* ]]
}

@test "timer start is idempotent" {
  escort_timer start
  FIRST=$(cat "$ESCORT_STATE_DIR/session-start")

  sleep 1
  escort_timer start
  SECOND=$(cat "$ESCORT_STATE_DIR/session-start")

  [ "$SECOND" -ge "$FIRST" ]
}
