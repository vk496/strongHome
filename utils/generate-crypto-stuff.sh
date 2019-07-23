#!/bin/bash
set -e

sudo rm -rf openssl-ca
mkdir openssl-ca

docker run --rm -it -v $PWD/openssl-ca:/certs \
-e SSL_SIZE=4096 \
-e CA_SUBJECT="AAA ROOT CA strongHome" \
-e CA_EXPIRE=3650 `# 10 years to expire the CA` \
vk496/omgwtfssl

(cd openssl-ca && sudo rm secret.yaml key.* cert.pem)

source .env

[[ ${LOCAL_DOMAIN} ]] || ( echo "Error, \$LOCAL_DOMAIN not defined"; exit 1 )

docker run --rm -it -v $PWD/openssl-ca:/certs \
-e SSL_SIZE=4096 \
-e CA_SUBJECT="AAA ROOT CA strongHome" \
-e CA_EXPIRE=3650 `# 10 years to expire the CA` \
-e SSL_KEY=ldap.${LOCAL_DOMAIN}-key.pem \
-e SSL_CSR=ldap.${LOCAL_DOMAIN}.csr \
-e SSL_CERT=ldap.${LOCAL_DOMAIN}.pem \
-e SSL_EXPIRE=730 `# 2 years` \
-e SSL_SUBJECT=openldap \
vk496/omgwtfssl

docker run --rm -it -v $PWD/openssl-ca:/certs \
-e SSL_SIZE=4096 \
-e CA_SUBJECT="AAA ROOT CA strongHome" \
-e CA_EXPIRE=3650 `# 10 years to expire the CA` \
-e SSL_KEY=radius.${LOCAL_DOMAIN}-key.pem \
-e SSL_CSR=radius.${LOCAL_DOMAIN}.csr \
-e SSL_CERT=radius.${LOCAL_DOMAIN}.pem \
-e SSL_EXPIRE=730 `# 2 years` \
-e SSL_SUBJECT=freeradius \
vk496/omgwtfssl

(cd openssl-ca && sudo rm secret.yaml)

#radius shared secret
docker run -v $PWD/openssl-ca:/certs --rm alpine sh -c "< /dev/urandom tr -dc \#@_\$%/\(\)=?A-Z-a-z-0-9 | head -c54 > /certs/radius-shared-secret"
docker run -v $PWD/openssl-ca:/certs --rm alpine sh -c "< /dev/urandom tr -dc \#@_\$%/\(\)=?A-Z-a-z-0-9 | head -c54 > /certs/admin-ro-pw"

curl https://2ton.com.au/dhparam/3072 -o openssl-ca/dh
