FROM debian:buster

RUN apt-get update && apt-get install -y \
    php7.3-fpm \
    php7.3-mysql \
    php7.3-common \
    php7.3-json \
    php7.3-curl \
    curl \
    mariadb-client

# Configure PHP-FPM to listen on network
RUN sed -i 's/listen = \/run\/php\/php7.3-fpm.sock/listen = 9000/g' /etc/php/7.3/fpm/pool.d/www.conf

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Create directory for PHP-FPM socket and logs
RUN mkdir -p /run/php

# Copy WordPress setup script
COPY tools/wordpress_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress_setup.sh

WORKDIR /var/www/html

EXPOSE 9000

# Start PHP-FPM and run setup script
CMD ["/usr/local/bin/wordpress_setup.sh"]