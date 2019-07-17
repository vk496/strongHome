FROM freeradius/freeradius-server:3.0.19-alpine

RUN apk add --no-cache \
  bash \
  git

RUN set -e; \
    git clone https://github.com/bats-core/bats-core bats; \
    cd bats; \
    git checkout 3adff324319193b3754974766e7119cad7ca862c; \
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
