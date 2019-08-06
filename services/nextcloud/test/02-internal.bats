#!/usr/bin/env bats

load '/bats/bats-support/load.bash'
load '/bats/bats-assert/load.bash'

@test "No default admin password" {
  #run curl --fail -H "OCS-APIRequest:true" -k "https://admin:admin@127.0.0.1:443/ocs/v1.php/cloud/users"
  run curl -k -X POST https://127.0.0.1:443/ocs/v1.php/person/check -H 'OCS-APIREQUEST: true' -d "login=admin&password=admin"

  assert_output --partial "<status>failure</status>"
}

@test "Admin changed password" {
  run curl -k -X POST https://127.0.0.1:443/ocs/v1.php/person/check -H 'OCS-APIREQUEST: true' -d "login=admin&password=Asdfaksdnjasdnjasnjdas"

  assert_output --partial "<status>ok</status>"
}

@test "LDAP login" {
  run curl -k -X POST https://127.0.0.1:443/ocs/v1.php/person/check -H 'OCS-APIREQUEST: true' -d "login=pedro&password=Asdfaksdnjasdnjasnjdas"

  assert_output --partial "<status>ok</status>"
}

@test "LDAP restricted users not allowed to login" {
  run curl -k -X POST https://127.0.0.1:443/ocs/v1.php/person/check -H 'OCS-APIREQUEST: true' -d "login=bob&password=hello"

  assert_output --partial "<status>failure</status>"
}
