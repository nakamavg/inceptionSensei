#!/bin/bash

# Initialize the MySQL data directory if it's empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MySQL server temporarily to set up the database
mysqld_safe --datadir=/var/lib/mysql --no-watch &

# Wait for MySQL to be ready
until mysqladmin ping >/dev/null 2>&1; do
    echo "Waiting for MySQL server to be ready..."
    sleep 1
done

# Create database and users
mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
mariadb -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mariadb -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO \`${MYSQL_USER}\`@'%';"
mariadb -e "FLUSH PRIVILEGES;"

# Shutdown MySQL server
mysqladmin shutdown

# Start MySQL server with proper configuration
exec mysqld --port=3306 \
    --bind-address=0.0.0.0 \
    --datadir='/var/lib/mysql' \
    --user=mysql
