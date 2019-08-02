#!/usr/bin/env bats

load '/bats/bats-support/load.bash'
load '/bats/bats-assert/load.bash'

@test "Confidentiality required for non-encrypted communication" {
  run ldapsearch -H ldap://localhost -x -D "cn=admin,dc=strongHome,dc=vk496" -w admin -b "dc=strongHome,dc=vk496"

  assert_output --partial "Confidentiality required (13)"
}


@test "Accept TLS connection" {
  run ldapsearch -H ldaps://localhost:636 -D "cn=admin,dc=strongHome,dc=vk496" -w Asdfaksdnjasdnjasnjdas -b "dc=strongHome,dc=vk496" "" -Z

  assert_success
}
