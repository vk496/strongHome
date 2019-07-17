#!/usr/bin/env bats

@test "Confidentiality required for non-encrypted communication" {
  run ldapsearch -H ldap://localhost -x -D "cn=admin,dc=um,dc=es" -w admin -b "dc=um,dc=es"

  [[ "$status" -eq 13 ]]
}


@test "Accept TLS connection" {
  run ldapsearch -H ldaps://localhost:636 -D "cn=admin,dc=um,dc=es" -w admin -b "dc=um,dc=es" "" -Z

  [[ "$status" -eq 0 ]]
}
