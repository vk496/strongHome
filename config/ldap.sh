#!/bin/sh

SERVICES="Services"
PEOPLE="People"

if [ ! -s "$1" ]; then
  >&2 echo "First argument missing strongHome config YAML"
  exit 1
fi

if [ ! -s "$2" ]; then
  >&2 echo "Second argument missing strongHome schema"
  exit 1
fi

set -e
pykwalify -s $2 -d $1 >/dev/null
set +e

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

EOF

echo "$FILE" | yq -r '.strongHome.list_services[]' | while read service; do

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

done
