#!/usr/bin/env bats

load '/bats/bats-support/load.bash'
load '/bats/bats-assert/load.bash'

@test "Answer with HTML page" {
  run wget -S --spider 127.0.0.1:80

  assert_success
  assert_output --partial "Content-Type: text/html"
}

@test "Download strongHome CA certificate" {
  run wget -S 127.0.0.1:80/ca.pem

  assert_success
  assert_output --partial "Content-Type: application/x-x509-ca-cert"

  run file ca.pem
  assert_output --partial "PEM certificate"
}

@test "strongHome.mobileconfig: Fail if no arguments supplied" {
  run wget -S --spider 127.0.0.1:80/hello.pl

  assert_failure
  assert_output --partial "HTTP/1.1 404"
}

@test "strongHome.mobileconfig: Fail if only 'hidden' supplied" {
  run wget -S --spider 127.0.0.1:80/hello.pl?hidden=true

  assert_failure
  assert_output --partial "HTTP/1.1 404"
}

@test "strongHome.mobileconfig: Success when 'wifi' is supplied" {
  run wget -S --spider "127.0.0.1:80/hello.pl?wifi=vk496"

  assert_success
  assert_output --partial "Content-Type: application/octet-stream"
}

@test "strongHome.mobileconfig: Success when 'wifi' and 'hidden' are supplied" {
  run wget -S --spider "127.0.0.1:80/hello.pl?wifi=vk496&hidden=false"

  assert_success
  assert_output --partial "Content-Type: application/octet-stream"
}

@test "strongHome.mobileconfig: File is signed by CA" {
  run wget -S -O strongHome.mobileconfig "127.0.0.1:80/hello.pl?wifi=vk496&hidden=true"

  assert_success
  assert_output --partial "Content-Type: application/octet-stream"

  run openssl smime -verify -inform DER -CAfile /usr/share/nginx/html/ca.pem -in strongHome.mobileconfig -purpose sslserver #TODO: fix certificate purpose
  assert_success
  assert_output --partial "Verification successful"
}
