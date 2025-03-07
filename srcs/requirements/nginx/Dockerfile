FROM debian:buster

# Instalar Nginx, herramientas SSL, y gettext-base para envsubst
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    vim \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Crear directorios para SSL y contenido web
RUN mkdir -p /etc/nginx/ssl /var/www/html

# Generar certificado SSL autofirmado
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=42/CN=localhost"

# Copiar configuración de Nginx
COPY ./conf/nginx.conf /etc/nginx/nginx.template

# Crear script de inicio
RUN echo '#!/bin/bash\n\
envsubst < /etc/nginx/nginx.template > /etc/nginx/conf.d/default.conf\n\
nginx -g "daemon off;"' > /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# Exponer puerto 443 para HTTPS
EXPOSE 443

# Ejecutar script de inicio
CMD ["/docker-entrypoint.sh"]