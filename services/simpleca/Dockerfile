FROM nginx:alpine-perl

RUN apk add --update \
      fcgiwrap \
      spawn-fcgi \
      redis

COPY web/* /usr/share/nginx/html/
COPY misc/entry.sh /

ENTRYPOINT ["/entry.sh"]
