FROM alpine

RUN apk add --no-cache \
  bash \
  git \
  nmap \
  wpa_supplicant \
  redis \
  jq \
  python3

RUN pip3 install yq


RUN apk add --no-cache \
  freeradius \
  freeradius-ldap \
  freeradius-eap


RUN sed -i 's/user = radius/user = root/g' /etc/raddb/radiusd.conf

RUN set -e; \
    git clone https://github.com/bats-core/bats-core bats; \
    cd bats; \
    git checkout 3adff324319193b3754974766e7119cad7ca862c; \
    ( ./install.sh /usr/local ); \
    cd ..; \
    rm -Rf bats

RUN set -e; \
    git clone --depth 1 https://github.com/ztombol/bats-support /bats/bats-support; \
    git clone --depth 1 https://github.com/ztombol/bats-assert /bats/bats-assert

COPY conf/clients.conf /etc/raddb/clients.conf.strongHome
COPY conf/users /etc/raddb/mods-config/files/authorize

COPY conf/sites-available/default /etc/raddb/sites-available/default
COPY conf/sites-available/inner-tunnel /etc/raddb/sites-available/inner-tunnel

COPY conf/mods-available/ldap /etc/raddb/mods-enabled/ldap.strongHome
COPY conf/mods-available/eap /etc/raddb/mods-enabled/eap.strongHome


COPY misc/entry.sh /strongHome/

ENTRYPOINT ["/strongHome/entry.sh"]
