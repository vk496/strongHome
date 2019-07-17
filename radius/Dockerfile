FROM freeradius/freeradius-server:3.0.19-alpine

RUN apk add --no-cache \
  bash \
  git

RUN set -e; \
    git clone https://github.com/sstephenson/bats; \
    cd bats; \
    git checkout 03608115df2071fff4eaaff1605768c275e5f81f; \
    ( ./install.sh /usr/local ); \
    cd ..; \
    rm -Rf bats

COPY misc/entry.sh /strongHome/

COPY conf/clients.conf /etc/raddb/clients.conf
COPY conf/users /etc/raddb/mods-config/files/authorize

COPY conf/sites-available/default /etc/raddb/sites-available/default
COPY conf/sites-available/inner-tunnel /etc/raddb/sites-available/inner-tunnel

COPY conf/mods-available/ldap /etc/raddb/mods-enabled/ldap.strongHome
COPY conf/mods-available/eap /etc/raddb/mods-enabled/eap.strongHome


ENTRYPOINT ["/strongHome/entry.sh"]
