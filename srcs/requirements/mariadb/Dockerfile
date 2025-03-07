FROM debian:buster

# Argumentos para configuración de base de datos
ARG DB_NAME
ARG DB_USER
ARG DB_PASSWORD
ARG DB_ROOT_PASSWORD

# Instalación de MariaDB
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Configuración para permitir conexiones desde cualquier host
RUN sed -i 's/bind-address            = 127.0.0.1/bind-address            = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Copiar script de inicialización
COPY ./tools/init_mariadb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_mariadb.sh

# Exponer puerto de MariaDB
EXPOSE 3306

# Definir variables de entorno para el script de inicialización
ENV DB_NAME=$DB_NAME \
    DB_USER=$DB_USER \
    DB_PASSWORD=$DB_PASSWORD \
    DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD

# Iniciar MariaDB y configurar la base de datos
CMD ["/usr/local/bin/init_mariadb.sh"]