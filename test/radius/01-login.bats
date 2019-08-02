#!/usr/bin/env bats

load '/bats/bats-support/load.bash'
load '/bats/bats-assert/load.bash'

generate_config() {
  USER=bob
  PASS=hello
  local eap="$1"
  local phase2="$2"

  if [[ $eap == "TTLS" || $eap == "PEAP" || $eap == "MSCHAPV2" ]]; then
    key_mgmt=WPA-EAP
  elif [[ $eap == *"AKA"* ]]; then
    key_mgmt="WPA-EAP IEEE8021X"
  else
    key_mgmt=NONE
  fi


  cat << EOF > $BATS_TMPDIR/eapol_test.conf
  network={
          ssid="example"
          key_mgmt=$key_mgmt
          eap=$eap
          identity="$USER"
          password="$PASS"
          `if [[ $key_mgmt == "WPA-EAP" && $eap != "MSCHAPV2" ]]; then
            echo phase2=\"$phase2\"
            echo anonymous_identity=\"anonymous\"

            if [[ $eap == "PEAP" ]]; then
              echo phase1=\"peapver=0\"
            fi

          fi`
  }
EOF

}



@test "EAP-TTLS/EAP-MD5 Accept" {
  generate_config TTLS autheap=MD5

  run eapol_test -t 5 -s testing123 -c $BATS_TMPDIR/eapol_test.conf
  assert_success
}

@test "EAP-TTLS/EAP-GTC Accept" {
  generate_config TTLS autheap=GTC

  run eapol_test -t 5 -s testing123 -c $BATS_TMPDIR/eapol_test.conf
  assert_success
}

@test "EAP-TTLS/EAP-MSCHAPV2 Accept" {
  generate_config TTLS autheap=MSCHAPV2

  run eapol_test -t 5 -s testing123 -c $BATS_TMPDIR/eapol_test.conf
  assert_success
}

@test "EAP-TTLS/PAP Accept" {
  generate_config TTLS auth=PAP

  run eapol_test -t 5 -s testing123 -c $BATS_TMPDIR/eapol_test.conf
  assert_success
}

@test "EAP-TTLS/MSCHAPV2 Reject" {
  generate_config TTLS auth=MSCHAPV2

  run eapol_test -t 5 -s testing123 -c $BATS_TMPDIR/eapol_test.conf
  assert_failure
}

@test "EAP-TTLS/CHAP Reject" {
  generate_config TTLS auth=CHAP

  run eapol_test -t 5 -s testing123 -c $BATS_TMPDIR/eapol_test.conf
  assert_failure
}

@test "PEAP/EAP-MSCHAPV2 Accept" {
  generate_config PEAP autheap=MSCHAPV2

  run eapol_test -t 5 -s testing123 -c $BATS_TMPDIR/eapol_test.conf
  assert_success
}

@test "PEAP/EAP-GTC Accept" {
  generate_config PEAP auth=GTC

  run eapol_test -t 5 -s testing123 -c $BATS_TMPDIR/eapol_test.conf
  assert_success
}

@test "GTC Reject" {
  generate_config GTC

  # cat $BATS_TMPDIR/eapol_test.conf >&3
  run eapol_test -t 5 -s testing123 -c $BATS_TMPDIR/eapol_test.conf
  assert_failure
}

@test "LEAP Reject" {
  generate_config LEAP

  # cat $BATS_TMPDIR/eapol_test.conf >&3
  run eapol_test -t 5 -s testing123 -c $BATS_TMPDIR/eapol_test.conf
  assert_failure
}

@test "MD5 Reject" {
  generate_config MD5

  # cat $BATS_TMPDIR/eapol_test.conf >&3
  run eapol_test -t 5 -s testing123 -c $BATS_TMPDIR/eapol_test.conf
  assert_failure
}

@test "MSCHAPV2 Reject" {
  generate_config MSCHAPV2

  # cat $BATS_TMPDIR/eapol_test.conf >&3
  run eapol_test -t 5 -s testing123 -c $BATS_TMPDIR/eapol_test.conf
  assert_failure
}
