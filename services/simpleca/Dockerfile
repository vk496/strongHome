FROM nginx:alpine-perl

RUN apk add --update \
      fcgiwrap \
      spawn-fcgi \
      redis \
      perl-cgi \
      openssl \
      util-linux \
      nano \
      git \
      nmap \
      bash \
      file


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


COPY web/* /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
COPY lib/template.mobileconfig.sh /


COPY misc/entry.sh /

ENTRYPOINT ["/entry.sh"]
