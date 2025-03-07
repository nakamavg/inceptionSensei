#!/bin/bash

# Verificar si el directorio de datos está vacío (primera inicialización)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    # Inicializar la base de datos
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

    # Iniciar el servicio de MariaDB temporalmente
    mysqld_safe --nowatch &

    # Esperar a que el servidor esté listo
    until mysqladmin ping &>/dev/null; do
        echo "Esperando a que MariaDB esté disponible..."
        sleep 1
    done

    # Configurar la base de datos
    mysql -u root <<EOF
# Establecer contraseña de root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

# Eliminar usuarios anónimos
DELETE FROM mysql.user WHERE User='';

# Eliminar acceso remoto para root
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

# Eliminar base de datos de prueba y acceso a ella
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

# Crear nueva base de datos y usuario
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';

# Aplicar cambios
FLUSH PRIVILEGES;
EOF

    # Detener el servidor que iniciamos temporalmente
    mysqladmin -u root -p${DB_ROOT_PASSWORD} shutdown
    
    echo "Inicialización de MariaDB completada."
else
    echo "La base de datos ya está inicializada."
fi

# Iniciar MariaDB en primer plano
exec mysqld_safe