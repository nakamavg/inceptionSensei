#!/bin/bash

# Wait for MySQL to be ready
while ! mysqladmin ping -h"mariadb" --silent; do
    sleep 1
done

# Download and configure WordPress if not already done
if [ ! -f "wp-config.php" ]; then
    # Download WordPress core
    wp core download --allow-root

    # Create wp-config.php
    wp config create --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb"

    # Install WordPress
    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"

    # Create additional user
    wp user create --allow-root \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role="author"
fi

# Start PHP-FPM
exec php-fpm7.3 -F