#!/bin/sh

trap "exit 0" SIGUSR1
trap "exit 1" SIGUSR2


# Register possible unit test as soon as possible
redis-cli -h redis rpush STRONGHOME_SERVICES_TESTING simpleca


echo "@strongHome@ - Starting SimpleCA"

chmod g+r /cert/radius-key.pem
adduser nginx root

spawn-fcgi -u nginx -s /run/fcgi.sock /usr/bin/fcgiwrap && nginx -g "daemon off;" &
MAIN_PROCESS=$!

if [[ $STRONGHOME_TEST ]]; then
  echo "@strongHome@ - Running tests"

  sleep 2 # Wait a little bit the web server before start tests

  bats /test
  the_exit_code=$?
  # Service finished unit tests
  redis-cli -h redis lrem STRONGHOME_SERVICES_TESTING 0 simpleca

  if [[ $the_exit_code -eq 0 ]]; then
    kill -s SIGUSR1 1
  else
    kill -s SIGUSR2 1
  fi

fi

wait $MAIN_PROCESS
