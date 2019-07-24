#!/bin/bash

declare -A STRONGHOME_USERS


function arr_exists(){
  # https://stackoverflow.com/questions/13219634/easiest-way-to-check-for-an-index-or-a-key-in-an-array
  [ ${STRONGHOME_USERS[$1]+vk496} ]
}

function add_user() {
  if ! arr_exists $1; then
     STRONGHOME_USERS[$1]=INIT
  else
    echo "$1 ALREADY EXISTS"
    exit 1
  fi
}

function get_usernames() {
  echo ${!STRONGHOME_USERS[@]}
}

function hello() {
  echo gola
}


# $1 - a domain
# ret - Valid or no
function valid_domain() {
  if echo "$1" | grep -qP '(?=^.{4,253}$)(^(?:[a-zA-Z0-9](?:(?:[a-zA-Z0-9\-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$)'; then
    return 0
  else
    return 1
  fi
}


# stdin - a cleartext password
# ret - Valid or no
function valid_pw() {
  PW_STRENGTH=$(cat - | cracklib-check | rev | cut -d: -f1 | rev | cut -d" " -f2-)
  if [[ $PW_STRENGTH == *"OK"* ]]; then
    return 0
  else
    echo "$PW_STRENGTH"
    return 2
  fi
}

# stdin - cleartext password
# ret - Encrypted password
function generate_pw() {
  cat - | mkpasswd -m sha512crypt -R 10000 -S `head -c 40 /dev/random | base64 | sed -e 's/+/./g' |  cut -b 10-25` -s
}
