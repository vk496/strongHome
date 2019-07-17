#!/usr/bin/env bats

@test "Listen port 1812 UDP" {
  NMAP="$(nmap -sU -p 1812 127.0.0.1)"

  [[ $NMAP == *"Host is up"* && $NMAP == *"open"* ]]
}

@test "Listen port 1813 UDP" {
  NMAP="$(nmap -sU -p 1813 127.0.0.1)"

  [[ $NMAP == *"Host is up"* && $NMAP == *"open"* ]]
}


@test "Not listen port 443 TCP" {
  NMAP="$(nmap -sT -p 443 127.0.0.1)"

  [[ $NMAP == *"Host is up"* && $NMAP == *"close"* ]]
}

# @test "Listen port 636" {
#   run nc -z 127.0.0.1 636
#
#   [[ "$status" -eq 0 ]]
# }
#
# @test "Not listen port 443" {
#   run nc -z 127.0.0.1 443
#
#   [[ "$status" -ne 0 ]]
# }
