#!/bin/bash

# Este script detecta el sistema operativo actual y configura las rutas adecuadas
# para los volúmenes persistentes según el sistema.

# Detectar sistema operativo
OS=$(uname -s)
USER=$(whoami)

# Determinar la ruta de datos según el sistema operativo
if [ "$OS" = "Darwin" ]; then
    # macOS
    echo "Sistema operativo detectado: macOS"
    DATA_PATH=~/data
    mkdir -p "$DATA_PATH/mariadb"
    mkdir -p "$DATA_PATH/wordpress"
    echo "Directorios de datos creados en $DATA_PATH"
elif [ "$OS" = "Linux" ]; then
    # Linux
    echo "Sistema operativo detectado: Linux"
    # Detectar si es Lubuntu
    if grep -qi "lubuntu" /etc/os-release 2>/dev/null; then
        echo "Distribución: Lubuntu"
    else
        echo "Distribución: Linux genérico"
    fi
    DATA_PATH=/home/$USER/data
    mkdir -p "$DATA_PATH/mariadb"
    mkdir -p "$DATA_PATH/wordpress"
    echo "Directorios de datos creados en $DATA_PATH"
else
    # Sistema operativo no reconocido
    echo "Sistema operativo no reconocido: $OS"
    DATA_PATH=./data
    mkdir -p "$DATA_PATH/mariadb"
    mkdir -p "$DATA_PATH/wordpress"
    echo "Directorios de datos creados en $DATA_PATH (ubicación por defecto)"
fi

# Exportar la ruta de datos para su uso en otros scripts
echo "DATA_PATH=$DATA_PATH" > ./configs/path.env

echo "Configuración completada. Ruta de datos: $DATA_PATH"