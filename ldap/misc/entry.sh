#!/bin/bash
set -e

if [ ! /strongHome/strongHome-schema.yaml ]; then
  >&2 echo "Missing /strongHome/strongHome-schema.yaml - schema"
  exit 1
fi

if [[ $STRONGHOME_TEST ]]; then
  # set -x
  # set +e

  if [ ! /strongHome/strongHome-config-test.yaml ]; then
    >&2 echo "Missing /strongHome/strongHome-config-test.yaml - config YAML"
    exit 1
  fi

  pykwalify -s /strongHome/strongHome-schema.yaml -d /strongHome/strongHome-config-test.yaml
  hash yq

  /strongHome/ldap.sh /strongHome/strongHome-config-test.yaml /strongHome/strongHome-schema.yaml \
    > /container/service/slapd/assets/config/bootstrap/ldif/custom/strongHome-test.ldif

  echo "@strongHome@ - Starting service..."

  tmp_fifo=ldap_output.txt
  mkfifo $tmp_fifo || exit 1


  /container/tool/run "$@" &> $tmp_fifo &
  # /container/tool/run "$@" 2>&1 | tee $tmp_fifo &

  while read line; do
    if [[ $line == *" slapd starting"* ]]; then
      # echo "<$line>"
      break
    fi

  done < $tmp_fifo

  echo "@strongHome@ - Running tests"

  bats /test

  sleep 2222

  rm $tmp_fifo

  exit 0
fi


if [ ! /strongHome/strongHome-config.yaml ]; then
  >&2 echo "Missing /strongHome/strongHome-config.yaml - config YAML"
  exit 1
fi

pykwalify -s /strongHome/strongHome-schema.yaml -d /strongHome/strongHome-config.yaml

#Check if exist
hash yq



/strongHome/ldap.sh /strongHome/strongHome-config.yaml /strongHome/strongHome-schema.yaml > /container/service/slapd/assets/config/bootstrap/ldif/custom/strongHome.ldif

echo "@strongHome@ - Done"

/container/tool/run "$@"
