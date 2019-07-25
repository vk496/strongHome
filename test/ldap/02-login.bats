#!/usr/bin/env bats

load '/bats/bats-support/load.bash'
load '/bats/bats-assert/load.bash'

@test "Read config with admin-ro" {
  run ldapsearch -H ldaps://localhost:636 -D "cn=admin-ro,ou=Services,dc=strongHome,dc=vk496" -w $(cat /cert/admin-ro-pw) -b "uid=bob,ou=People,dc=strongHome,dc=vk496" userPassword

  assert_success
}

@test "Not default admin password " {
  run ldapsearch -H ldaps://localhost:636 -D "cn=admin,dc=strongHome,dc=vk496" -w admin -b "dc=strongHome,dc=vk496"

  assert_failure
}
