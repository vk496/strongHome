#!/bin/bash
set -e

trap "exit 0" SIGTERM

function wait_and_exit () {
  while [ "$(redis-cli -h redis get STRONGHOME_TEST_END)" != "READY" ]; do
    sleep 1
  done

  kill -s SIGTERM 1
}

if [[ $STRONGHOME_TEST ]]; then
  wait_and_exit &
  STRONGHOME_CONFIG_FILE=/strongHome/strongHome-config-test.yaml
else
  STRONGHOME_CONFIG_FILE=/strongHome/strongHome-config.yaml
fi

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

}


while read line; do
  if [[ $line == *"Nextcloud was successfully installed"* ]]; then
    setup_service &
  fi
  echo "$line"
done < <(/entrypoint.sh "${@:-apache2-foreground}")

# cat <&3
