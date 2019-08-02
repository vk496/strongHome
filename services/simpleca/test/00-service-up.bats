#!/usr/bin/env bats

load '/bats/bats-support/load.bash'
load '/bats/bats-assert/load.bash'

@test "Listen port 80 TCP" {
  run nmap -sT -p 80 127.0.0.1

  assert_output --partial "Host is up"
  assert_output --partial "open"
}
