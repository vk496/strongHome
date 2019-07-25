#!/bin/bash
set -e

SERVICES="Services"
PEOPLE="People"

RADIUS_LDAP_PW_ENCRYPTED=$(slappasswd -c '$6$rounds=10000$%.16s' -s "$(cat /cert/admin-ro-pw)")

FILE=$(cat $1)


user_get_firstName() {
  local user=$1
  echo "$FILE" | yq -r ".strongHome.list_users[] | select(.user == \"$user\") | .first_name"
}

user_get_lastName() {
  local user=$1
  echo "$FILE" | yq -r ".strongHome.list_users[] | select(.user == \"$user\") | .last_name"
}

user_get_pw() {
  local user=$1
  echo "$FILE" | yq -r ".strongHome.list_users[] | select(.user == \"$user\") | .password"
}

cat <<EOF
#Group of people
dn: ou=${PEOPLE},{{ LDAP_BASE_DN }}
ou: ${PEOPLE}
objectclass: organizationalUnit

#Group of services
dn: ou=${SERVICES},{{ LDAP_BASE_DN }}
ou: ${SERVICES}
objectclass: organizationalunit

EOF


cat <<EOF
#############################################
########### ${PEOPLE} ##########################
#############################################

EOF


echo "$FILE" | yq -r '.strongHome.list_users[].user' | while read ldap_user; do

cat <<EOF
dn: uid=${ldap_user},ou=${PEOPLE},{{ LDAP_BASE_DN }}
cn: `user_get_firstName $ldap_user`
sn: `user_get_lastName $ldap_user`
mail: ${ldap_user}@{{ LDAP_DOMAIN }}
objectClass: inetOrgPerson
objectclass: top
userPassword: `user_get_pw $ldap_user`

EOF

done

cat <<EOF
#############################################
########### ${SERVICES} ##########################
#############################################

dn: cn=admin-ro,ou=Services,{{ LDAP_BASE_DN }}
cn: admin-ro
objectclass: simpleSecurityObject
objectclass: organizationalRole
userPassword: ${RADIUS_LDAP_PW_ENCRYPTED}

#####
EOF

echo "$FILE" | yq -r '.strongHome.list_services[]' | while read service; do

if [[ "$(echo "$FILE" | yq -r ".strongHome.list_users[] | select(.services | index(\"${service}\")) | .user")" ]]; then

cat <<EOF
#${service}
dn: cn=${service},ou=${SERVICES},{{ LDAP_BASE_DN }}
cn: ${service}
objectclass: groupOfNames
objectclass: top
$(
echo "$FILE" | yq -r ".strongHome.list_users[] | select(.services | index(\"${service}\")) | .user" | while read ldap_user; do
  echo "member: uid=${ldap_user},ou=${PEOPLE},{{ LDAP_BASE_DN }}"
done
)

EOF

fi
done
