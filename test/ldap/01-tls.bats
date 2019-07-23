#!/usr/bin/env bats

load '/bats/bats-support/load.bash'
load '/bats/bats-assert/load.bash'

@test "Confidentiality required for non-encrypted communication" {
  run ldapsearch -H ldap://localhost -x -D "cn=admin,dc=um,dc=es" -w admin -b "dc=um,dc=es"

  assert_output --partial "Confidentiality required (13)"
}


@test "Accept TLS connection" {
  run ldapsearch -H ldaps://localhost:636 -D "cn=admin,dc=um,dc=es" -w admin -b "dc=um,dc=es" "" -Z

  assert_success
}
