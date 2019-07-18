#!/bin/bash
set -e

echo "@strongHome@ - Waiting for LDAP"

while [[ $(redis-cli -h redis get STRONGHOME_LDAP) != "READY" ]]; do
  sleep 1
done

echo "@strongHome@ - LDAP ready!"

#{{ RADIUS_SHARED_SECRET }}

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
    | sed "s|{{ LOCAL_DOMAIN_DC }}|${LOCAL_DOMAIN_DC}|g" \
  > $renamed_file

  rm $file
  echo "@strongHome@ - $renamed_file patched!"
done

if [[ $STRONGHOME_TEST ]]; then
  set +e

  tmp_fifo=radius_output.txt
  mkfifo $tmp_fifo || exit 1


  /docker-entrypoint.sh "$@" &> $tmp_fifo &
  # /docker-entrypoint.sh "$@" 2>&1 | tee $tmp_fifo &

  while read line; do
    if [[ $line == *"Ready to process requests"* ]]; then
      # echo "<$line>"
      break
    fi

  done < $tmp_fifo

  echo "@strongHome@ - Running tests"

  bats /test

  redis-cli -h redis setnx STRONGHOME_TEST_END READY

  exit 0
fi


echo "@strongHome@ - Done"

/docker-entrypoint.sh "$@"
