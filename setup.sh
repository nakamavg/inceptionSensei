#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}     Configuración de Inception${NC}"
echo -e "${BLUE}===========================================${NC}"

# Verificar que Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker no está instalado. Por favor, instale Docker antes de continuar.${NC}"
    exit 1
fi

# Verificar que Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose no está instalado. Por favor, instale Docker Compose antes de continuar.${NC}"
    exit 1
fi

# Obtener el nombre de usuario actual
USERNAME=$(whoami)
DOMAIN="${USERNAME}.42.fr"
echo -e "${GREEN}Nombre de usuario detectado: ${USERNAME}${NC}"
echo -e "${GREEN}Dominio a configurar: ${DOMAIN}${NC}"

# Configurar entrada en /etc/hosts si no existe
if ! grep -q "${DOMAIN}" /etc/hosts; then
    echo -e "${YELLOW}Añadiendo entrada para ${DOMAIN} en /etc/hosts...${NC}"
    echo "127.0.0.1 ${DOMAIN}" | sudo tee -a /etc/hosts > /dev/null
    echo -e "${GREEN}Entrada añadida correctamente.${NC}"
else
    echo -e "${GREEN}La entrada para ${DOMAIN} ya existe en /etc/hosts.${NC}"
fi

echo -e "${GREEN}Detectando sistema operativo...${NC}"
# Ejecutar script de detección de sistema operativo
cd srcs
./configs/detect_os.sh
cd ..

# Copiar archivo .env de ejemplo si no existe
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creando archivo .env desde el ejemplo...${NC}"
    cp srcs/.env.example .env
    
    # Leer la ruta de datos generada por detect_os.sh
    if [ -f srcs/configs/path.env ]; then
        DATA_PATH=$(grep DATA_PATH srcs/configs/path.env | cut -d= -f2)
        echo "DATA_PATH=$DATA_PATH" >> .env
        echo -e "${GREEN}Configurado DATA_PATH=$DATA_PATH en el archivo .env${NC}"
    else
        echo -e "${RED}No se pudo determinar la ruta de datos. Por favor, configure DATA_PATH manualmente en el archivo .env${NC}"
    fi
    
    echo -e "${YELLOW}Por favor, revise y modifique el archivo .env si es necesario.${NC}"
else
    echo -e "${GREEN}El archivo .env ya existe. Usando configuración existente.${NC}"
    # Asegurar que el dominio está correctamente configurado en el .env existente
    if ! grep -q "DOMAIN_NAME=${DOMAIN}" .env; then
        echo -e "${YELLOW}Actualizando DOMAIN_NAME en el archivo .env...${NC}"
        sed -i "s/DOMAIN_NAME=.*/DOMAIN_NAME=${DOMAIN}/g" .env
        if [ $? -ne 0 ]; then
            # Si sed falla (puede ocurrir en macOS), intentar otra aproximación
            sed -i "" "s/DOMAIN_NAME=.*/DOMAIN_NAME=${DOMAIN}/g" .env
        fi
        echo -e "${GREEN}DOMAIN_NAME actualizado a ${DOMAIN} en el archivo .env${NC}"
    fi
fi

echo -e "${BLUE}===========================================${NC}"
echo -e "${GREEN}Configuración completada.${NC}"
echo -e "${GREEN}Para iniciar los servicios, ejecute: make${NC}"
echo -e "${GREEN}Para acceder al sitio, visite https://${DOMAIN}${NC}"
echo -e "${GREEN}Para detener los servicios, ejecute: make down${NC}"
echo -e "${BLUE}===========================================${NC}"