# strongHome

## Deploy
### Define a domain

Create a `.env` file with the `LOCAL_DOMAIN` variable at the root path of the project with the DNS name that you would like to use. In this example I will use `um.es`:
```bash
echo "LOCAL_DOMAIN=um.es" > .env
```

### Generate certs
First, we need all the certificates that will be used by the services. Generate them with this:

```bash
./utils/generate-crypto-stuff.sh .env
```

### Generate config
TODO

For test pruposes, you can use the example config:

```bash
cp test/strongHome-config-test.yaml config/strongHome-config.yaml
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
  - [ ] Define ACL policies for each application (Radius, VoIP, etc.) to have restricted access
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
