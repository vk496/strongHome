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

@test "Port 443 Accept SSL request" {
  run echo "Q" |openssl s_client -connect 127.0.0.1:443

  assert_success
}

@test "Port 443 SSL signed by CA" {
  run echo "Q" |openssl s_client -connect 127.0.0.1:443 -verify_return_error -verifyCAfile /cert/ca.pem

  assert_success
}


@test "Port 443 SSL support TLSv1.3" {
  run echo "Q" |openssl s_client -connect 127.0.0.1:443 -tls1_3

  assert_success
}

@test "Port 443 HSTS enabled" {
  run curl -k --fail -I https://127.0.0.1

  assert_output --partial "Strict-Transport-Security:"
}

# @test "HTTP/2 enabled" {
#   run curl -k -sI https://127.0.0.1:443 -o/dev/null -w '%{http_version}\n'
#
#   assert_output "2"
# }

# @test "testssl connection" {
#   run testssl --mode parallel -c 127.0.0.1:443
#
#   refute_output --partial "No connection"
# }

@test "testssl vulnerabilities" {
  run testssl --mode parallel -U 127.0.0.1:443

  refute_output --partial "VULNERABLE (NOT ok)"
}


@test "testssl bugs" {
  run testssl --mode parallel -g 127.0.0.1:443

  assert_output --partial "No bugs found"
}


@test "testssl headers" {
  run testssl --mode parallel -h 127.0.0.1:443

  refute_output --partial "misconfiguration:"
}
