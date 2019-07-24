#!/bin/bash
set -e

exit_on_error() {
  send_redis
  echo "@strongHome@ - Shutting down...."
}

send_redis() {
  redis-cli -h redis setnx STRONGHOME_TEST_END READY
  sleep 4
  redis-cli -h redis shutdown nosave
}

echo "@strongHome@ - Waiting for LDAP"
trap exit_on_error ERR

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

LOCAL_DOMAIN_DC=$(echo $LOCAL_DOMAIN | sed "s/\./,dc=/g" | cat <(echo -n "dc=") -)

for file in $(find /etc/raddb/ -type f -name \*.strongHome); do
  renamed_file=$(echo $file | rev | cut -d\. -f2- | rev)
  cat $file \
    | sed "s|{{ LOCAL_DOMAIN }}|${LOCAL_DOMAIN}|g" \
    | sed "s|{{ RADIUS_SHARED_SECRET }}|${RADIUS_SHARED_SECRET}|g" \
    | sed "s|{{ RADIUS_LDAP_PW }}|${RADIUS_LDAP_PW}|g" \
    | sed "s|{{ LOCAL_DOMAIN_DC }}|${LOCAL_DOMAIN_DC}|g" \
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

  send_redis

  exit 0
fi


echo "@strongHome@ - Done"

exec radiusd -l /dev/stdout -f "$@"