# strongHome

## Generate certs
```bash
sudo rm openssl-ca/*

docker run --rm -it -v $PWD/openssl-ca:/certs \
-e SSL_SIZE=4096 \
-e CA_SUBJECT="AAA ROOT CA strongHome" \
-e CA_EXPIRE=3650 `# 10 years to expire the CA` \
paulczar/omgwtfssl

(cd openssl-ca && sudo rm secret.yaml key.* cert.pem)

source .env

docker run --rm -it -v $PWD/openssl-ca:/certs \
-e SSL_SIZE=4096 \
-e CA_SUBJECT="AAA ROOT CA strongHome" \
-e CA_EXPIRE=3650 `# 10 years to expire the CA` \
-e SSL_KEY=ldap.${LOCAL_DOMAIN}-key.pem \
-e SSL_CSR=ldap.${LOCAL_DOMAIN}.csr \
-e SSL_CERT=ldap.${LOCAL_DOMAIN}.pem \
-e SSL_EXPIRE=730 `# 2 years` \
-e SSL_SUBJECT=ldap.${LOCAL_DOMAIN} \
paulczar/omgwtfssl
```

## Deploy
```bash
docker-compose up
```

## TODO list
- [ ] PKI
- [ ] LDAP
- [ ] 802.11X
- [ ] Configuration in JSON
- [ ] JSON Schema
- [ ] Email server
- [ ] VoIP?
- [ ] Web for manager LDAP/restore passwords
- [ ] Design optional services (torrents, plex, etc.)
- [ ] Scalable services
