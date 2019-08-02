#!/usr/bin/env bats

load '/bats/bats-support/load.bash'
load '/bats/bats-assert/load.bash'

@test "Listen port 1812 UDP" {
  run nmap -sU -p 1812 127.0.0.1

  assert_output --partial "Host is up"
  assert_output --partial "open"
}

@test "Listen port 1813 UDP" {
  run nmap -sU -p 1813 127.0.0.1

  assert_output --partial "Host is up"
  assert_output --partial "open"
}


@test "Not listen port 443 TCP" {
  run nmap -sT -p 443 127.0.0.1

  assert_output --partial "Host is up"
  assert_output --partial "closed"
}
