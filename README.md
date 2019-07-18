# strongHome

## Deploy
### Define a domain

Create a `.env` file with the `LOCAL_DOMAIN` variable at the root path of the project. For example:
```
LOCAL_DOMAIN=um.es
```

### Generate certs
First, we need all the certificates that will be used by the services.

```bash
sudo rm -rf openssl-ca
mkdir openssl-ca

docker run --rm -it -v $PWD/openssl-ca:/certs \
-e SSL_SIZE=4096 \
-e CA_SUBJECT="AAA ROOT CA strongHome" \
-e CA_EXPIRE=3650 `# 10 years to expire the CA` \
vk496/omgwtfssl

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

(cd openssl-ca && sudo rm secret.yaml key.* cert.pem)

#radius shared secret
docker run -v $PWD/openssl-ca:/certs --rm alpine sh -c "< /dev/urandom tr -dc \#@_\$%/\(\)=?A-Z-a-z-0-9 | head -c54 > /certs/radius-shared-secret"
```

### Generate config
TODO

For test pruposes, you can use the example config:

```bash
cp config/strongHome-config-example.yaml config/strongHome-config.yaml
```

### Validate config
Check if your config is correct before continue:
```bash
docker run --rm -v $PWD:/remote vk496/stronghome-utils pykwalify -s config/strongHome-schema.yaml -d config/strongHome-config.yaml
```

### Start the project
```bash
docker-compose up --build --abort-on-container-exit
```

## Unit tests
```bash
docker-compose -f docker-compose.yml -f test/docker-compose.test.yml up --build; docker-compose down
```


## TODO list
- [x] PKI
- [X] LDAP
  - [ ] Define admin permissions with YAML
  - [X] Auto-generate config
  - [X] Unit tests
- [ ] 802.11X
  - [x] Auto-generate config
  - [ ] Tests for all kind of radius auth methods
- [x] YAML config
  - [x] Schema
- [ ] Email server
- [ ] VoIP?
- [x] Sync startup containers
- [ ] Web for manager LDAP/restore passwords
- [ ] Design optional services (torrents, plex, etc.)
- [ ] Dynamic auto-configuration stuff should be in a aislated service
- [ ] Beautiful way to generate strongHome YAML config
- [ ] Scalable services
