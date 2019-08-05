#!/usr/bin/env bats

load '/bats/bats-support/load.bash'
load '/bats/bats-assert/load.bash'

@test "Listen port 80 TCP" {
  run nc -zvw3 127.0.0.1 80

  assert_output --partial "open"
}

@test "Listen port 443 TCP" {
  run nc -zvw3 127.0.0.1 443

  assert_output --partial "open"
}
