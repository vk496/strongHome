#!/bin/bash
set -e

if [ ! /strongHome/strongHome-schema.yaml ]; then
  >&2 echo "Missing /strongHome/strongHome-schema.yaml - schema"
  exit 1
fi

if [[ $STRONGHOME_TEST ]]; then
  STRONGHOME_CONFIG_FILE=/strongHome/strongHome-config-test.yaml
else
  STRONGHOME_CONFIG_FILE=/strongHome/strongHome-config.yaml
fi

if [ ! ${STRONGHOME_CONFIG_FILE} ]; then
  >&2 echo "Missing ${STRONGHOME_CONFIG_FILE} - config YAML"
  exit 1
fi

pykwalify -s /strongHome/strongHome-schema.yaml -d ${STRONGHOME_CONFIG_FILE}
#Check if exist
hash yq

/strongHome/ldap.sh ${STRONGHOME_CONFIG_FILE} /strongHome/strongHome-schema.yaml > /container/service/slapd/assets/config/bootstrap/ldif/custom/strongHome.ldif


if [[ $STRONGHOME_TEST ]]; then
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

  redis-cli -h redis setnx STRONGHOME_LDAP READY

  echo "@strongHome@ - Running tests"
  bats /test

  rm $tmp_fifo

  while [[ $(redis-cli -h redis get STRONGHOME_TEST_END) != "READY" ]]; do
    sleep 1
  done

  exit 0
fi


echo "@strongHome@ - Done"

while read line; do
  if [[ $line == *" slapd starting"* ]]; then
    redis-cli -h redis setnx STRONGHOME_LDAP READY
  fi

  echo "$line"
done < <(/container/tool/run "$@" 2>&1)
