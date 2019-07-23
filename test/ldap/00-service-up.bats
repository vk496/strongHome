#!/usr/bin/env bats

load '/bats/bats-support/load.bash'
load '/bats/bats-assert/load.bash'

@test "Listen port 389" {
  run nc -z 127.0.0.1 389

  assert_success
}

@test "Listen port 636" {
  run nc -z 127.0.0.1 636

  assert_success
}

@test "Not listen port 443" {
  run nc -z 127.0.0.1 443

  assert_failure
}
