#!/usr/bin/env bats

@test "Listen port 389" {
  run nc -z 127.0.0.1 389

  [[ "$status" -eq 0 ]]
}

@test "Listen port 636" {
  run nc -z 127.0.0.1 636

  [[ "$status" -eq 0 ]]
}

@test "Not listen port 443" {
  run nc -z 127.0.0.1 443

  [[ "$status" -ne 0 ]]
}
