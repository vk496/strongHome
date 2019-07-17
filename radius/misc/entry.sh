#!/bin/bash
set -e

sleep 6

LOCAL_DOMAIN_DC=$(echo $LOCAL_DOMAIN | sed "s/\./,dc=/g" | cat <(echo -n "dc=") -)

for file in $(find /etc/raddb/ -type f -name \*.strongHome); do
  renamed_file=$(echo $file | rev | cut -d\. -f2- | rev)
  cat $file \
    | sed "s|{{ LOCAL_DOMAIN }}|${LOCAL_DOMAIN}|g" \
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

  sleep 2222

  exit 1
fi



#sed -i "s|{{ LOCAL_DOMAIN }}|${LOCAL_DOMAIN}|g"

echo "@strongHome@ - Done"

/docker-entrypoint.sh "$@"
