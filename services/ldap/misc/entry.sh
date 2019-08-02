#!/bin/bash
set -e

if [ ! /strongHome/strongHome-schema.yaml ]; then
  >&2 echo "Missing /strongHome/strongHome-schema.yaml - schema"
  exit 1
fi

STRONGHOME_CONFIG_FILE=/strongHome/strongHome-config.yaml

if [ ! ${STRONGHOME_CONFIG_FILE} ]; then
  >&2 echo "Missing ${STRONGHOME_CONFIG_FILE} - config YAML"
  exit 1
fi

pykwalify -s /strongHome/strongHome-schema.yaml -d ${STRONGHOME_CONFIG_FILE}
#Check if exist
hash yq


echo "@strongHome@ - Setting admin/config password"

LDAP_ADMIN_PASSWORD_ENCRYPTED=$(cat ${STRONGHOME_CONFIG_FILE}| yq -r ".strongHome.admin_password")

for file in $(find /container/service/slapd/assets/config/bootstrap -type f -name \*.strongHome); do
  renamed_file=$(echo $file | rev | cut -d\. -f2- | rev)
  cat $file \
    | sed "s|{{ LDAP_ADMIN_PASSWORD_ENCRYPTED }}|${LDAP_ADMIN_PASSWORD_ENCRYPTED}|g" \
  > $renamed_file

  rm $file
  echo "@strongHome@ - $renamed_file patched!"
done

# sed -i "s|{{ LDAP_ADMIN_PASSWORD_ENCRYPTED }}|${LDAP_ADMIN_PASSWORD_ENCRYPTED}|g" /container/service/slapd/assets/config/admin-pw/ldif/06-root-pw-change.ldif
# sed -i "s|{{ LDAP_ADMIN_PASSWORD_ENCRYPTED }}|${LDAP_ADMIN_PASSWORD_ENCRYPTED}|g" /container/service/slapd/assets/config/admin-pw/ldif/07-admin-pw-change.ldif

#sed -i 's/LDAP_ADMIN_PASSWORD_ENCRYPTED=/#LDAP_ADMIN_PASSWORD_ENCRYPTED=/g' /container/service/slapd/startup.sh

# Populate database
/strongHome/ldap.sh ${STRONGHOME_CONFIG_FILE} /strongHome/strongHome-schema.yaml > /container/service/slapd/assets/config/bootstrap/ldif/custom/strongHome.ldif


if [[ $STRONGHOME_TEST ]]; then
  echo "@strongHome@ - Starting service..."

  tmp_fifo=ldap_output.txt
  mkfifo $tmp_fifo || exit 1


  # /container/tool/run "$@" &> $tmp_fifo &
  /container/tool/run "$@" 2>&1 | tee $tmp_fifo &

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
