# strongHome
![x86_64](https://badges.herokuapp.com/travis/vk496/strongHome?branch=dev&env=BUILDPLATFORM=linux/amd64&label=dev-x86_64)
![arm32v6](https://badges.herokuapp.com/travis/vk496/strongHome?branch=dev&env=BUILDPLATFORM=linux/arm/v6&label=dev-arm32v6)
![arm32v7](https://badges.herokuapp.com/travis/vk496/strongHome?branch=dev&env=BUILDPLATFORM=linux/arm/v7&label=dev-arm32v7)
![arm64](https://badges.herokuapp.com/travis/vk496/strongHome?branch=dev&env=BUILDPLATFORM=linux/arm64&label=dev-arm64)
![ppc64le](https://badges.herokuapp.com/travis/vk496/strongHome?branch=dev&env=BUILDPLATFORM=linux/ppc64le&label=dev-ppc64le)
![s390x](https://badges.herokuapp.com/travis/vk496/strongHome?branch=dev&env=BUILDPLATFORM=linux/s390x&label=dev-s390x)

## Deploy

### Generate certs
First, we need all the certificates that will be used by the services. Generate them with this:

```bash
./utils/generate-crypto-stuff.sh
```

### Generate config
For simple configuration of the project, I strongly recommend to use "StrongHome Configurator". Launch it with:

```bash
docker run -it --rm -v $PWD:/remote vk496/stronghome-utils config
```

For test pruposes, you can use directly the example config:

```bash
cp config/strongHome-config-test.yaml config/strongHome-config.yaml
```

### Validate config
Check if your config is correct before continue. You can ommit this step if you have used "StrongHome Configurator" or the example config:
```bash
docker run --rm -v $PWD:/remote vk496/stronghome-utils pykwalify -s config/strongHome-schema.yaml -d config/strongHome-config.yaml
```

### Start the project
```bash
docker-compose --compatibility up --build -d
```

## Unit tests
```bash
docker-compose --compatibility -f docker-compose.yml -f docker-compose.test.yml up --build; docker-compose down
```


## TODO list
- [x] PKI
- [X] LDAP
  - [X] Define admin permissions with YAML
  - [X] Auto-generate config
  - [X] Unit tests
  - [ ] Define ACL policies for each application (Radius, VoIP, etc.) to have restricted access
- [X] 802.11X
  - [x] Auto-generate config
  - [ ] Tests for all kind of radius auth methods
- [x] YAML config
  - [x] Schema
- [X] NextCloud
  - [X] LDAP
  - [ ] Unit tests
  - [ ] Server side encryption
- [ ] Email server
- [ ] VoIP?
- [x] Sync startup containers
- [ ] Web for manager LDAP/restore passwords
- [ ] Design optional services (torrents, plex, etc.)
- [ ] Dynamic auto-configuration stuff should be in a aislated service
- [X] Beautiful way to generate strongHome YAML config
- [ ] Scalable services
