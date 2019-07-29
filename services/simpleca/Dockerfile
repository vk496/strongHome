FROM nginx:alpine-perl

RUN apk add --update \
      fcgiwrap \
      spawn-fcgi \
      redis \
      perl-cgi \
      openssl \
      util-linux \
      nano

COPY web/* /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
COPY lib/template.mobileconfig.sh /


COPY misc/entry.sh /

ENTRYPOINT ["/entry.sh"]
