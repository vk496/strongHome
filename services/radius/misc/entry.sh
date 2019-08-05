#!/bin/bash
set -e

# Register possible unit test as soon as possible
redis-cli -h redis rpush STRONGHOME_SERVICES_TESTING freeradius

STRONGHOME_CONFIG_FILE=/strongHome/strongHome-config.yaml

if [[ $STRONGHOME_SERVICE_NAME ]] && [[ ! $(cat $STRONGHOME_CONFIG_FILE | yq -r '.strongHome.list_services[]') == *"$STRONGHOME_SERVICE_NAME"* ]]; then
  echo "@strongHome@ - Service was not defined in YAML config. Shutting down...."
  exit 0
fi


echo "@strongHome@ - Waiting for LDAP"

while [[ $(redis-cli -h redis get STRONGHOME_LDAP) != "READY" ]]; do
  sleep 1
done

echo "@strongHome@ - LDAP ready!"

#{{ RADIUS_SHARED_SECRET }}

RADIUS_LDAP_PW=$(cat /cert/admin-ro-pw)

if [[ $STRONGHOME_TEST ]]; then
  RADIUS_SHARED_SECRET=testing123
else
  RADIUS_SHARED_SECRET=$(cat /cert/radius-shared-secret)
fi

for file in $(find /etc/raddb/ -type f -name \*.strongHome); do
  renamed_file=$(echo $file | rev | cut -d\. -f2- | rev)
  cat $file \
    | sed "s|{{ RADIUS_SHARED_SECRET }}|${RADIUS_SHARED_SECRET}|g" \
    | sed "s|{{ RADIUS_LDAP_PW }}|${RADIUS_LDAP_PW}|g" \
  > $renamed_file

  rm $file
  echo "@strongHome@ - $renamed_file patched!"
done

if [[ $STRONGHOME_TEST ]]; then
  set -E

  tmp_fifo=radius_output.txt
  mkfifo $tmp_fifo || exit 1


  echo "@strongHome@ - Starting service..."

  radiusd -l /dev/stdout -f "$@" &> $tmp_fifo &
  # exec radiusd -l /dev/stdout -f "$@" 2>&1 | tee $tmp_fifo &

  while read line; do
    if [[ $line == *"Ready to process requests"* ]]; then
      # echo "<$line>"
      break
    fi

  done < $tmp_fifo

  echo "@strongHome@ - Running tests"

  bats /test
  the_exit_code=$?

  # Service finished unit tests
  redis-cli -h redis lrem STRONGHOME_SERVICES_TESTING 0 freeradius

  exit $the_exit_code
fi


echo "@strongHome@ - Done"

exec radiusd -l /dev/stdout -f "$@"
