FROM debian:buster

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    dos2unix

# Configure MariaDB to listen on all interfaces
RUN sed -i 's/bind-address\s*=\s*127\.0\.0\.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Ensure the MariaDB data directory exists
RUN mkdir -p /var/lib/mysql

# Copy and prepare initialization script
COPY tools/init_db.sh /usr/local/bin/
RUN dos2unix /usr/local/bin/init_db.sh && \
    chmod +x /usr/local/bin/init_db.sh

EXPOSE 3306

CMD ["bash", "/usr/local/bin/init_db.sh"]