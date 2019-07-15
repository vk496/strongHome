#!/bin/bash
set -e


if [ ! /strongHome/strongHome-config.yaml ]; then
  >&2 echo "Missing /strongHome/strongHome-config.yaml - config YAML"
  exit 1
fi

if [ ! /strongHome/strongHome-schema.yaml ]; then
  >&2 echo "Missing /strongHome/strongHome-schema.yaml - schema"
  exit 1
fi


pykwalify -s /strongHome/strongHome-schema.yaml -d /strongHome/strongHome-config.yaml

#Check if exist
hash yq



/strongHome/ldap.sh /strongHome/strongHome-config.yaml /strongHome/strongHome-schema.yaml > /container/service/slapd/assets/config/bootstrap/ldif/custom/strongHome.ldif

echo "@strongHome@ - Done"

/container/tool/run "$@"
