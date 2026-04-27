FROM nginx:alpine

# Создание непривилегированного пользователя
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Установка необходимых пакетов
RUN apk update && apk add --no-cache \
    gcc \
    spawn-fcgi \
    fcgi-dev \
    musl-dev \
    shadow \
 && rm -f /usr/bin/gpasswd /usr/bin/passwd /usr/bin/chage /usr/bin/chfn /usr/bin/expiry /usr/bin/chsh /sbin/unix_chkpwd

# Создание рабочего каталога с нужными правами
WORKDIR /app
COPY ./server/server.c /app/server.c
RUN gcc /app/server.c -o /app/server -lfcgi \
 && chown -R appuser:appgroup /app

# Копирование конфигурации nginx
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
RUN chown -R appuser:appgroup /etc/nginx /var/cache/nginx /var/run /run || true

# Переключение на непривилегированного пользователя
USER appuser

# HEALTHCHECK
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s CMD wget -qO- http://localhost:80 || exit 1

EXPOSE 80

CMD spawn-fcgi -p 8080 /app/server && nginx -g "daemon off;"

