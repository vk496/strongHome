FROM nextcloud:16.0.3

RUN apt-get update && apt-get install --no-install-recommends -y \
    redis-server \
    python3-pip \
    python3-setuptools \
    sqlite3 \
    jq

RUN pip3 install yq

COPY misc/entry.sh /

ENTRYPOINT ["/entry.sh"]
