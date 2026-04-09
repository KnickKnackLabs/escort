#!/usr/bin/env bats

setup() {
  load helpers
  setup_test_state
}

# ============ last-human-msg ============

@test "last-human-msg: no previous timestamp produces no output" {
  run escort provider last-human-msg
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "last-human-msg: writes timestamp for next invocation" {
  escort provider last-human-msg
  [ -f "$XDG_STATE_HOME/escort/last-human-msg" ]
  # File should contain a unix timestamp
  [[ "$(cat "$XDG_STATE_HOME/escort/last-human-msg")" =~ ^[0-9]+$ ]]
}

@test "last-human-msg: shows delta from previous timestamp" {
  local now
  now=$(date +%s)
  write_timestamp "last-human-msg" $((now - 300))

  run escort provider last-human-msg
  [ "$status" -eq 0 ]
  [ "$output" = "5m" ]
}

@test "last-human-msg: short gap shows <1m" {
  local now
  now=$(date +%s)
  write_timestamp "last-human-msg" $((now - 10))

  run escort provider last-human-msg
  [ "$status" -eq 0 ]
  [ "$output" = "<1m" ]
}

@test "last-human-msg: long gap shows hours" {
  local now
  now=$(date +%s)
  write_timestamp "last-human-msg" $((now - 7200))

  run escort provider last-human-msg
  [ "$status" -eq 0 ]
  [ "$output" = "2h" ]
}

# ============ session-elapsed ============

@test "session-elapsed: no state file exits cleanly" {
  run escort provider session-elapsed
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "session-elapsed: shows time since session start" {
  local now
  now=$(date +%s)
  write_timestamp "session-start" $((now - 2700))

  run escort provider session-elapsed
  [ "$status" -eq 0 ]
  [ "$output" = "45m" ]
}

@test "session-elapsed: empty state file exits cleanly" {
  echo "" > "$XDG_STATE_HOME/escort/session-start"

  run escort provider session-elapsed
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# ============ unread-chat ============

@test "unread-chat: no chat CLI exits cleanly" {
  # Provide a PATH with only essential binaries, no chat
  mkdir -p "$BATS_TEST_TMPDIR/no-chat-bin"
  ln -sf /bin/bash "$BATS_TEST_TMPDIR/no-chat-bin/bash"
  PATH="$BATS_TEST_TMPDIR/no-chat-bin" \
  CHAT_IDENTITY=zeke \
  run bash "$ESCORT_ROOT/scripts/providers/unread-chat.sh"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "unread-chat: no CHAT_IDENTITY exits cleanly" {
  unset CHAT_IDENTITY
  run escort provider unread-chat
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "unread-chat: shows total unread count" {
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat > "$BATS_TEST_TMPDIR/bin/chat" <<'MOCK'
#!/usr/bin/env bash
case "$1" in
  list) echo '[{"name":"den"},{"name":"zeke"}]' ;;
  read)
    for arg in "$@"; do
      [ "$arg" = "den" ] && echo '[{},{},{}]' && exit 0
      [ "$arg" = "zeke" ] && echo '[{}]' && exit 0
    done
    echo '[]' ;;
esac
MOCK
  chmod +x "$BATS_TEST_TMPDIR/bin/chat"

  PATH="$BATS_TEST_TMPDIR/bin:$PATH" \
  CHAT_IDENTITY=zeke \
  run escort provider unread-chat
  [ "$status" -eq 0 ]
  [ "$output" = "4" ]
}

@test "unread-chat: no unread messages produces no output" {
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat > "$BATS_TEST_TMPDIR/bin/chat" <<'MOCK'
#!/usr/bin/env bash
case "$1" in
  list) echo '[{"name":"den"}]' ;;
  read) echo '[]' ;;
esac
MOCK
  chmod +x "$BATS_TEST_TMPDIR/bin/chat"

  PATH="$BATS_TEST_TMPDIR/bin:$PATH" \
  CHAT_IDENTITY=zeke \
  run escort provider unread-chat
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# ============ hostname ============

@test "hostname: outputs short hostname" {
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat > "$BATS_TEST_TMPDIR/bin/hostname" <<'MOCK'
#!/usr/bin/env bash
[ "$1" = "-s" ] && echo "test-machine"
MOCK
  chmod +x "$BATS_TEST_TMPDIR/bin/hostname"

  PATH="$BATS_TEST_TMPDIR/bin:$PATH" \
  run bash "$ESCORT_ROOT/scripts/providers/hostname.sh"
  [ "$status" -eq 0 ]
  [ "$output" = "test-machine" ]
}

@test "hostname: exits cleanly when hostname fails" {
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat > "$BATS_TEST_TMPDIR/bin/hostname" <<'MOCK'
#!/usr/bin/env bash
exit 1
MOCK
  chmod +x "$BATS_TEST_TMPDIR/bin/hostname"

  PATH="$BATS_TEST_TMPDIR/bin:$PATH" \
  run bash "$ESCORT_ROOT/scripts/providers/hostname.sh"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# ============ XDG compliance ============

@test "last-human-msg: respects XDG_STATE_HOME" {
  escort provider last-human-msg
  [ -f "$XDG_STATE_HOME/escort/last-human-msg" ]
  # Should NOT be in the default location
  [ ! -f "$HOME/.local/state/escort/last-human-msg" ] || \
    [ "$XDG_STATE_HOME" != "$HOME/.local/state" ]
}

@test "session-elapsed: respects XDG_STATE_HOME" {
  local now
  now=$(date +%s)
  write_timestamp "session-start" $((now - 60))

  run escort provider session-elapsed
  [ "$status" -eq 0 ]
  [ "$output" = "1m" ]
}
