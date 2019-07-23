#!/usr/bin/env bats

load '/bats/bats-support/load.bash'
load '/bats/bats-assert/load.bash'

@test "Read config with admin-ro" {
  run ldapsearch -H ldaps://localhost:636 -D "cn=admin-ro,ou=Services,dc=um,dc=es" -w $(cat /cert/admin-ro-pw) -b "uid=bob,ou=People,dc=um,dc=es" userPassword

  assert_success
}
