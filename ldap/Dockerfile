FROM osixia/openldap:1.2.4

RUN apt-get update && apt-get install --no-install-recommends -y \
    python3-pip \
    python3-setuptools

RUN pip3 install pykwalify yq

#COPY um.ldif /container/service/slapd/assets/config/bootstrap/ldif/custom/
COPY ldap.sh misc/entry.sh /strongHome/


COPY lib/asterisk.schema /container/service/slapd/assets/config/bootstrap/schema/mmc/
COPY lib/03-memberOf.ldif /container/service/slapd/assets/config/bootstrap/ldif/03-memberOf.ldif

ENTRYPOINT ["/strongHome/entry.sh"]
