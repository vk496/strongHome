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

docker run --rm -it -v $PWD/openssl-ca:/certs \
-e SSL_SIZE=4096 \
-e CA_SUBJECT="AAA ROOT CA strongHome" \
-e CA_EXPIRE=3650 `# 10 years to expire the CA` \
-e SSL_KEY=ldap-key.pem \
-e SSL_CSR=ldap.csr \
-e SSL_CERT=ldap.pem \
-e SSL_EXPIRE=730 `# 2 years` \
-e SSL_SUBJECT=openldap \
vk496/omgwtfssl

docker run --rm -it -v $PWD/openssl-ca:/certs \
-e SSL_SIZE=4096 \
-e CA_SUBJECT="AAA ROOT CA strongHome" \
-e CA_EXPIRE=3650 `# 10 years to expire the CA` \
-e SSL_KEY=radius-key.pem \
-e SSL_CSR=radius.csr \
-e SSL_CERT=radius.pem \
-e SSL_EXPIRE=730 `# 2 years` \
-e SSL_SUBJECT=freeradius \
vk496/omgwtfssl

(cd openssl-ca && sudo rm secret.yaml)

#radius shared secret
docker run -v $PWD/openssl-ca:/certs --rm alpine sh -c "< /dev/urandom tr -dc \#@_\$%/\(\)=?A-Z-a-z-0-9 | head -c54 > /certs/radius-shared-secret"
docker run -v $PWD/openssl-ca:/certs --rm alpine sh -c "< /dev/urandom tr -dc \#@_\$%/\(\)=?A-Z-a-z-0-9 | head -c54 > /certs/admin-ro-pw"

curl https://2ton.com.au/dhparam/3072 -o openssl-ca/dh
