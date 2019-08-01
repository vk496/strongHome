FROM nextcloud:16.0.3

RUN apt-get update && apt-get install --no-install-recommends -y \
    redis-server

COPY misc/entry.sh /

ENTRYPOINT ["/entry.sh"]
