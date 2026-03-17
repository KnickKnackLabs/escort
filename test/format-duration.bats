#!/usr/bin/env bats

setup() {
  load helpers
}

# ============ Basic formatting ============

@test "format_duration: under 60s shows <1m" {
  run format_duration 0
  [ "$output" = "<1m" ]

  run format_duration 30
  [ "$output" = "<1m" ]

  run format_duration 59
  [ "$output" = "<1m" ]
}

@test "format_duration: exact minutes" {
  run format_duration 60
  [ "$output" = "1m" ]

  run format_duration 300
  [ "$output" = "5m" ]

  run format_duration 3540
  [ "$output" = "59m" ]
}

@test "format_duration: hours with minutes" {
  run format_duration 3660
  [ "$output" = "1h1m" ]

  run format_duration 7920
  [ "$output" = "2h12m" ]
}

@test "format_duration: exact hours (no minutes)" {
  run format_duration 3600
  [ "$output" = "1h" ]

  run format_duration 7200
  [ "$output" = "2h" ]
}

@test "format_duration: large values" {
  run format_duration 86400
  [ "$output" = "24h" ]

  run format_duration 90060
  [ "$output" = "25h1m" ]
}
