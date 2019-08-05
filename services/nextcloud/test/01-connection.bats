#!/usr/bin/env bats

load '/bats/bats-support/load.bash'
load '/bats/bats-assert/load.bash'

@test "Port 80 accept plain HTTP" {
  run curl --fail -I http://127.0.0.1:80

  assert_success
  assert_output --partial "Content-Type: text/html"
}

@test "Port 80 redirect to HTTPS" {
  run curl --fail -I http://127.0.0.1:80

  assert_success
  assert_output --partial "Location: https://"
}

@test "Port 443 reject plain HTTP" {
  run curl --fail -I http://127.0.0.1:443

  assert_failure
  assert_output --partial "400 Bad Request"
}
