FROM nginx:alpine-perl

RUN apk add --update \
      fcgiwrap \
      spawn-fcgi \
      redis \
      perl-cgi \
      openssl

COPY web/* /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf

COPY misc/entry.sh /

ENTRYPOINT ["/entry.sh"]
