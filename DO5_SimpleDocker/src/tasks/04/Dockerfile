FROM nginx:alpine

RUN apk update && apk add --no-cache \
    gcc \
    spawn-fcgi \
    fcgi-dev \
    musl-dev

COPY ./server/server.c /app/server.c
RUN gcc /app/server.c -o /app/server -lfcgi

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD spawn-fcgi -p 8080 /app/server && nginx -g "daemon off;"
