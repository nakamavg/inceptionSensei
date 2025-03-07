# Proyecto Inception - Documentación de Fallos y Soluciones

## Introducción

Este documento detalla los fallos comunes encontrados durante el desarrollo del proyecto Inception y sus respectivas soluciones. El proyecto consiste en la implementación de una infraestructura de servicios utilizando Docker Compose, incluyendo NGINX, WordPress y MariaDB.

## Estructura del Proyecto

```
├── Makefile
├── data/
│   ├── mariadb/
│   └── wordpress/
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   └── tools/
        │       └── init_db.sh
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        └── wordpress/
            ├── Dockerfile
            └── tools/
                └── wordpress_setup.sh
```

## Fallos Comunes y Soluciones

### 1. Problemas con MariaDB

#### Fallo: Base de datos no se inicializa correctamente

**Síntomas:**
- WordPress no puede conectarse a la base de datos
- Errores en los logs de MariaDB
- El contenedor de MariaDB se reinicia constantemente

**Causas:**
- Permisos incorrectos en el directorio de datos
- Variables de entorno mal configuradas
- Script de inicialización con errores

**Solución:**
- Verificar que las variables de entorno en `.env` estén correctamente definidas
- Asegurar que el script `init_db.sh` tenga permisos de ejecución
- Comprobar que el directorio `/var/lib/mysql` tenga los permisos adecuados
- Revisar la sintaxis de los comandos SQL en el script de inicialización

#### Fallo: Problemas de conexión entre WordPress y MariaDB

**Síntomas:**
- Error "Error establishing database connection" en WordPress

**Causas:**
- Configuración incorrecta de la dirección de bind en MariaDB
- Nombre de host incorrecto en la configuración de WordPress

**Solución:**
- Verificar que MariaDB esté configurado para escuchar en todas las interfaces (`bind-address = 0.0.0.0`)
- Comprobar que WordPress use `mariadb` como nombre de host para la conexión
- Asegurar que ambos contenedores estén en la misma red de Docker

### 2. Problemas con WordPress

#### Fallo: WordPress no se instala automáticamente

**Síntomas:**
- Al acceder al sitio, aparece el instalador de WordPress en lugar del sitio configurado

**Causas:**
- El script `wordpress_setup.sh` no se ejecuta correctamente
- Problemas de timing: WordPress intenta instalarse antes de que MariaDB esté listo

**Solución:**
- Mejorar el mecanismo de espera en el script de WordPress:
```bash
while ! mysqladmin ping -h"mariadb" --silent; do
    echo "Esperando a que MariaDB esté disponible..."
    sleep 1
done
```
- Verificar que todas las variables de entorno necesarias estén disponibles

#### Fallo: Problemas con los permisos de archivos

**Síntomas:**
- WordPress no puede crear directorios o subir archivos
- Errores al intentar actualizar plugins o temas

**Causas:**
- Permisos incorrectos en el volumen montado
- Usuario incorrecto ejecutando PHP-FPM

**Solución:**
- Ajustar los permisos del directorio `/var/www/html`
- Asegurar que el usuario que ejecuta PHP-FPM tenga permisos de escritura

### 3. Problemas con NGINX

#### Fallo: Certificado SSL no funciona correctamente

**Síntomas:**
- Advertencias de certificado no confiable en el navegador
- Errores de SSL en los logs de NGINX

**Causas:**
- Certificado autofirmado no reconocido por el navegador
- Configuración incorrecta de SSL en NGINX

**Solución:**
- Añadir el certificado a las excepciones del navegador
- Verificar la configuración SSL en `nginx.conf`
- Asegurar que los archivos de certificado y clave estén correctamente referenciados

#### Fallo: Redirección infinita o problemas de acceso

**Síntomas:**
- El navegador muestra error de "demasiadas redirecciones"
- No se puede acceder al sitio de WordPress

**Causas:**
- Configuración incorrecta de redirección HTTP a HTTPS
- Problemas con la configuración de `fastcgi_pass`

**Solución:**
- Revisar la configuración de redirección en `nginx.conf`
- Verificar que `fastcgi_pass` apunte correctamente al contenedor de WordPress

### 4. Problemas con Docker y Volúmenes

#### Fallo: Problemas de persistencia de datos

**Síntomas:**
- Los datos se pierden al reiniciar los contenedores
- Base de datos vacía después de reconstruir

**Causas:**
- Configuración incorrecta de volúmenes en `docker-compose.yml`
- Problemas de compatibilidad entre sistemas de archivos (especialmente en macOS)

**Solución:**
- Verificar la configuración de volúmenes en `docker-compose.yml`
- Usar la opción `driver: local` con las opciones adecuadas
- Asegurar que los directorios de datos existan antes de iniciar los contenedores

#### Fallo: Problemas de red entre contenedores

**Síntomas:**
- Los contenedores no pueden comunicarse entre sí
- Errores de conexión rechazada

**Causas:**
- Configuración incorrecta de la red en `docker-compose.yml`
- Nombres de host incorrectos

**Solución:**
- Verificar que todos los servicios estén en la misma red (`inception`)
- Usar los nombres de los servicios como nombres de host para la comunicación

### 5. Problemas Específicos de macOS

#### Fallo: Problemas de rendimiento con volúmenes

**Síntomas:**
- Operaciones de archivo muy lentas
- Tiempos de carga excesivos

**Causas:**
- Problemas de rendimiento conocidos con volúmenes montados en macOS

**Solución:**
- Considerar el uso de Docker Desktop con la nueva implementación de volúmenes
- Minimizar el número de archivos en volúmenes compartidos

#### Fallo: Problemas con la resolución de nombres de host

**Síntomas:**
- No se puede acceder al sitio usando el nombre de dominio configurado

**Causas:**
- Configuración incorrecta del archivo `/etc/hosts`

**Solución:**
- Añadir la siguiente línea al archivo `/etc/hosts`:
```
127.0.0.1 nakama.42.fr
```

## Consejos Generales

### Depuración

- **Revisar logs de contenedores:**
```bash
docker logs <nombre_contenedor>
```

- **Acceder a un contenedor para depuración:**
```bash
docker exec -it <nombre_contenedor> /bin/bash
```

- **Verificar la configuración de red:**
```bash
docker network inspect inception
```

### Comandos Útiles del Makefile

- `make`: Construye e inicia todos los contenedores
- `make build`: Reconstruye los contenedores sin caché
- `make down`: Detiene todos los contenedores
- `make re`: Reinicia todos los contenedores
- `make clean`: Limpia contenedores y imágenes
- `make fclean`: Limpieza completa incluyendo volúmenes

## Conclusión

La mayoría de los problemas en el proyecto Inception están relacionados con la configuración de los servicios, la comunicación entre contenedores y la gestión de volúmenes. Siguiendo esta guía, deberías poder identificar y resolver los fallos más comunes que puedas encontrar durante el desarrollo del proyecto.

Recuerda que la depuración es una parte esencial del proceso. Utiliza los logs de los contenedores y las herramientas de Docker para identificar la causa raíz de los problemas.

¡Buena suerte con tu proyecto Inception!