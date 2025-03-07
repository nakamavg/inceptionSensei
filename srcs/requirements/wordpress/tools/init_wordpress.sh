#!/bin/bash

# Verificar si el archivo de configuración de WordPress ya existe
if [ ! -f /var/www/html/wp-config.php ]; then
    # Esperar a que la base de datos esté lista
    until mysqladmin ping -h"$DB_HOST" --silent; do
        echo "Esperando a que MariaDB esté disponible..."
        sleep 1
    done

    echo "Configurando WordPress..."

    # Configurar WordPress
    cd /var/www/html

    # Crear el archivo de configuración
    wp config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST" \
        --allow-root

    # Instalar WordPress
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    # Crear un usuario adicional (opcional)
    wp user create editor editor@example.com --role=editor --user_pass=editorpass --allow-root

    echo "WordPress configurado con éxito."
else
    echo "WordPress ya está configurado."
fi

# Establecer permisos adecuados
chown -R www-data:www-data /var/www/html

# Iniciar PHP-FPM en primer plano
echo "Iniciando PHP-FPM..."
exec php-fpm7.3 -F