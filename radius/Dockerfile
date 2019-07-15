FROM freeradius/freeradius-server:3.0.19-alpine

COPY misc/entry.sh /strongHome/

COPY conf/clients.conf /etc/raddb/clients.conf
COPY conf/users /etc/raddb/mods-config/files/authorize
COPY conf/sites-available/default /etc/raddb/sites-available/default
COPY conf/sites-available/inner-tunnel /etc/raddb/sites-available/inner-tunnel
COPY conf/mods-available/ldap /etc/raddb/mods-enabled/ldap


ENTRYPOINT ["/strongHome/entry.sh"]
