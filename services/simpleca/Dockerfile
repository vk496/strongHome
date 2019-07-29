FROM nginx:alpine-perl

RUN apk add --update \
      fcgiwrap \
      spawn-fcgi

COPY web/* /usr/share/nginx/html/

CMD spawn-fcgi -s /run/fcgi.sock /usr/bin/fcgiwrap && nginx -g "daemon off;"
