FROM vk496/openldap:1.2.4

RUN apt-get update && apt-get install --no-install-recommends -y \
    python3-pip \
    python3-setuptools \
    git \
    netcat \
    redis-server \
    bc

RUN pip3 install pykwalify yq

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

COPY test /test

COPY lib/asterisk.schema /container/service/slapd/assets/config/bootstrap/schema/mmc/

COPY lib/03-memberOf.ldif /container/service/slapd/assets/config/bootstrap/ldif/03-memberOf.ldif
COPY lib/02-security.ldif /container/service/slapd/assets/config/bootstrap/ldif/custom/
COPY lib/admins-pw-change.ldif /container/service/slapd/assets/config/bootstrap/ldif/custom/zz-admin-pw.ldif.strongHome
COPY lib/06-root-pw-change.ldif /container/service/slapd/assets/config/bootstrap/ldif/custom/06-root-pw-change.ldif.strongHome

COPY ldap.sh misc/entry.sh /strongHome/

ENTRYPOINT ["/strongHome/entry.sh"]
