FROM alpine

RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    python3 \
    bash \
    newt \
    jo \
    jq \
    cracklib \
    mkpasswd


RUN pip3 install pykwalify yq

RUN set -e; \
      cd /root; \
      wget -O- https://github.com/cracklib/cracklib/raw/master/words/files/cracklib/words.bz2 \
      | bunzip2 -c -d | gzip -c > words.gz; \
      create-cracklib-dict words.gz; \
      rm words.gz


WORKDIR /root

COPY configurator.sh configurator_libs.sh entry.sh /root/

ENTRYPOINT ["/root/entry.sh"]
