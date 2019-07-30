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

user_get_uuid() {
  username=$1
  min_uid=1010
  max_uid=65535
  generated_number=$(echo "$1" | sha256sum | cut -d" " -f1 | sed 's/[a-zA-Z]//g')
  echo "(($generated_number-$min_uid) % ($max_uid-$min_uid+1)) + $min_uid" | bc
  #echo 3333
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
objectclass: top
objectClass: inetOrgPerson
objectClass: shadowAccount
objectClass: posixAccount
cn: $ldap_user
sn: $ldap_user
userPassword: `user_get_pw $ldap_user`
uidNumber: `user_get_uuid $ldap_user`
gidNumber: `user_get_uuid $ldap_user`
homeDirectory: /home/$ldap_user/

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
