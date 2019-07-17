FROM osixia/openldap:1.2.4

RUN apt-get update && apt-get install --no-install-recommends -y \
    python3-pip \
    python3-setuptools \
    git \
    netcat

RUN pip3 install pykwalify yq

RUN set -e; \
    git clone https://github.com/bats-core/bats-core bats; \
    cd bats; \
    git checkout 3adff324319193b3754974766e7119cad7ca862c; \
    ( ./install.sh /usr/local ); \
    cd ..; \
    rm -Rf bats

#COPY um.ldif /container/service/slapd/assets/config/bootstrap/ldif/custom/
COPY ldap.sh misc/entry.sh /strongHome/


COPY lib/asterisk.schema /container/service/slapd/assets/config/bootstrap/schema/mmc/
COPY lib/03-memberOf.ldif /container/service/slapd/assets/config/bootstrap/ldif/03-memberOf.ldif

ENTRYPOINT ["/strongHome/entry.sh"]
