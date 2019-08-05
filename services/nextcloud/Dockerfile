FROM nextcloud:16.0.3

RUN apt-get update && apt-get install --no-install-recommends -y \
    redis-server \
    python3-pip \
    python3-setuptools \
    sqlite3 \
    jq \
    netcat \
    git

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

COPY conf/ /etc/apache2/sites-enabled/
RUN a2enmod ssl

COPY misc/entry.sh /

ENTRYPOINT ["/entry.sh"]
