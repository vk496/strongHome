#!/bin/bash
set -e

trap "exit 0" SIGUSR1
trap "exit 1" SIGUSR2

# Register possible unit test as soon as possible
redis-cli -h redis rpush STRONGHOME_SERVICES_TESTING nextcloud

function execute_tests () {
  set +e
  echo "@strongHome@ - Running tests"

  cd /
  bats /test
  the_exit_code=$?

  # Service finished unit tests
  redis-cli -h redis lrem STRONGHOME_SERVICES_TESTING 0 nextcloud

  if [[ $the_exit_code -eq 0 ]]; then
    kill -s SIGUSR1 1
  else
    kill -s SIGUSR2 1
  fi

}

STRONGHOME_CONFIG_FILE=/strongHome/strongHome-config.yaml

if [[ $STRONGHOME_SERVICE_NAME ]] && [[ ! $(cat $STRONGHOME_CONFIG_FILE | yq -r '.strongHome.list_services[]') == *"$STRONGHOME_SERVICE_NAME"* ]]; then
  echo "@strongHome@ - Service was not defined in YAML config. Shutting down...."
  exit 0
fi




openssl x509 -in /cert/ca.pem -inform PEM -out /usr/local/share/ca-certificates/strongHome_ca.crt

update-ca-certificates


# exec 3< <(/entrypoint.sh "${@:-apache2-foreground}")

function setup_service() {


echo "@strongHome@ - Nextcloud started!"

# Set LDAP link
bash <<"EOF"
su - www-data -s /bin/bash
cd /var/www/html/

php occ app:enable user_ldap
ldap_conf=$(php occ ldap:create-empty-config | rev | cut -d" " -f1 | rev)

php occ ldap:set-config $ldap_conf ldapHost openldap
php occ ldap:set-config $ldap_conf ldapPort 389
php occ ldap:set-config $ldap_conf ldapTLS 1
php occ ldap:set-config $ldap_conf ldapAgentName cn=admin-ro,ou=Services,dc=stronghome,dc=vk496
php occ ldap:set-config $ldap_conf ldapAgentPassword "$(cat /cert/admin-ro-pw)"
php occ ldap:set-config $ldap_conf ldapBase dc=strongHome,dc=vk496
php occ ldap:set-config $ldap_conf ldapUserFilter '(&(objectClass=inetOrgPerson)(memberOf=cn=NextCloud,ou=Services,dc=strongHome,dc=vk496))'
php occ ldap:set-config $ldap_conf ldapLoginFilter '(&(&(objectClass=inetOrgPerson)(memberOf=cn=NextCloud,ou=Services,dc=strongHome,dc=vk496))(uid=%uid))'
php occ ldap:set-config $ldap_conf ldapUserDisplayName uid
php occ ldap:set-config $ldap_conf ldapUserFilterObjectclass inetOrgPerson
php occ ldap:set-config $ldap_conf ldapConfigurationActive 1
php occ ldap:set-config $ldap_conf hasMemberOfFilterSupport 1
EOF

# Fix admin password
sqlite3 /var/www/html/data/${SQLITE_DATABASE}.db <<END_SQL
.timeout 2000
UPDATE oc_users SET password = '2|$(cat /strongHome/strongHome-config.yaml | yq -r '.strongHome.admin_password' | cut -d"}" -f2-)' WHERE uid = '$NEXTCLOUD_ADMIN_USER';
END_SQL

if [[ $STRONGHOME_TEST ]]; then
  execute_tests
fi

}


while read line; do
  if [[ $line == *"Nextcloud was successfully installed"* ]]; then
    setup_service &
  fi
  echo "$line"
done < <(/entrypoint.sh "${@:-apache2-foreground}")

# cat <&3
