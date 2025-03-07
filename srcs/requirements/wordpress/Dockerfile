FROM debian:buster

# Argumentos necesarios para configurar WordPress
ARG DB_NAME
ARG DB_USER
ARG DB_PASSWORD
ARG DB_HOST
ARG WP_TITLE
ARG WP_ADMIN_USER
ARG WP_ADMIN_PASSWORD
ARG WP_ADMIN_EMAIL
ARG WP_URL
ARG DOMAIN_NAME

# Instalación de dependencias
RUN apt-get update && apt-get install -y \
    php7.3 \
    php7.3-fpm \
    php7.3-mysql \
    php7.3-curl \
    php7.3-json \
    php7.3-mbstring \
    php7.3-xml \
    php7.3-zip \
    php7.3-gd \
    php7.3-soap \
    mariadb-client \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Configuración de PHP-FPM para escuchar en todas las interfaces
RUN sed -i 's/listen = \/run\/php\/php7.3-fpm.sock/listen = 0.0.0.0:9000/g' /etc/php/7.3/fpm/pool.d/www.conf

# Instalación de WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Crear directorio de trabajo
WORKDIR /var/www/html

# Descargar WordPress y configurarlo
RUN wp core download --allow-root

# Copiar script de inicialización
COPY ./tools/init_wordpress.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_wordpress.sh

# Exponer el puerto
EXPOSE 9000

# Variables de entorno
ENV DB_NAME=$DB_NAME \
    DB_USER=$DB_USER \
    DB_PASSWORD=$DB_PASSWORD \
    DB_HOST=$DB_HOST \
    WP_TITLE=$WP_TITLE \
    WP_ADMIN_USER=$WP_ADMIN_USER \
    WP_ADMIN_PASSWORD=$WP_ADMIN_PASSWORD \
    WP_ADMIN_EMAIL=$WP_ADMIN_EMAIL \
    WP_URL=$WP_URL \
    DOMAIN_NAME=$DOMAIN_NAME

# Iniciar PHP-FPM y configurar WordPress
CMD ["/usr/local/bin/init_wordpress.sh"]