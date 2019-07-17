#!/bin/bash
set -e

if [[ $STRONGHOME_TEST ]]; then
  # set -x
  # set +e

  echo "Hola mundo"

  tmp_fifo=ldap_output.txt
  mkfifo $tmp_fifo || exit 1
  # bats /test
  /container/tool/run "$@" &> $tmp_fifo &

  while read line; do
    if [[ $line == *" slapd starting"* ]]; then
      # echo "<$line>"
      break
    fi

    # case $line in
    #     "slapd starting") echo "Y found, breaking out."; break;;
    #     *) echo "<$line>";;
    # esac
  done < $tmp_fifo

  echo "@strongHome@ - Running tests"



  bats /test

  rm $tmp_fifo

  exit 0
fi


if [ ! /strongHome/strongHome-config.yaml ]; then
  >&2 echo "Missing /strongHome/strongHome-config.yaml - config YAML"
  exit 1
fi

if [ ! /strongHome/strongHome-schema.yaml ]; then
  >&2 echo "Missing /strongHome/strongHome-schema.yaml - schema"
  exit 1
fi


pykwalify -s /strongHome/strongHome-schema.yaml -d /strongHome/strongHome-config.yaml

#Check if exist
hash yq



/strongHome/ldap.sh /strongHome/strongHome-config.yaml /strongHome/strongHome-schema.yaml > /container/service/slapd/assets/config/bootstrap/ldif/custom/strongHome.ldif

echo "@strongHome@ - Done"

/container/tool/run "$@"
