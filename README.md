# Inception

## Descripción del Proyecto
Este proyecto consiste en configurar una pequeña infraestructura compuesta por diferentes servicios bajo Docker. Cada servicio se ejecuta en su propio contenedor, construido desde cero con Debian Buster como imagen base, siguiendo las reglas específicas del sujeto de 42.

## Servicios

### NGINX
- Servidor web que acepta solo conexiones TLSv1.2 o TLSv1.3
- Implementa un certificado SSL autofirmado
- Redirecciona todas las peticiones a WordPress

### WordPress
- Sitio web con PHP-FPM (sin nginx)
- Configurado para utilizar el dominio de usuario (login.42.fr)

### MariaDB
- Base de datos para WordPress
- Datos persistentes almacenados fuera de los contenedores

## Por Qué y Cómo: Explicaciones Detalladas

### Certificados SSL Autofirmados
Los certificados SSL son necesarios para implementar conexiones HTTPS seguras. En entornos de producción se utilizan certificados emitidos por autoridades de certificación reconocidas, pero para desarrollo y testing podemos crear certificados autofirmados.

#### ¿Por qué autofirmados?
- No requieren pago ni validación externa
- Perfectos para entornos de desarrollo y pruebas
- Cumplen con el requisito de TLSv1.2/TLSv1.3 del proyecto

#### Cómo se implementan
El certificado autofirmado se genera durante la construcción del contenedor NGINX:

```bash
# Generación del certificado autofirmado
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=42Madrid/OU=Inception/CN=${DOMAIN_NAME}"
```

Esta implementación:
1. Crea una clave privada RSA de 2048 bits
2. Genera un certificado X.509 válido por 365 días
3. Utiliza el nombre de dominio del usuario como Common Name (CN)
4. No requiere contraseña (-nodes)

### Manejo de Rutas y Persistencia de Datos

#### El Problema de las Rutas
Un desafío principal es que el proyecto debe funcionar en diferentes sistemas operativos (principalmente en Linux para evaluación oficial, pero también en macOS para desarrollo). Las rutas absolutas para los volúmenes de Docker pueden variar significativamente entre estos sistemas:

- En macOS, las rutas de usuario suelen ser `/Users/username/...`
- En Linux, las rutas de usuario suelen ser `/home/username/...`

#### Solución Implementada
Para resolver este problema, el Makefile detecta automáticamente el sistema operativo y configura la ruta de datos correspondiente:

```makefile
# Detectar sistema operativo y configurar rutas
UNAME_S := $(shell uname -s)
USER := $(shell whoami)
DOMAIN := $(USER).42.fr

ifeq ($(UNAME_S),Darwin)
    # macOS
    DATA_PATH = ~/data
else ifeq ($(UNAME_S),Linux)
    # Linux
    DATA_PATH = /home/$(USER)/data
else
    # Otro sistema operativo (usar ruta por defecto)
    DATA_PATH = ./data
endif
```

Esta configuración:
1. Detecta automáticamente el sistema operativo usando `uname -s`
2. Establece rutas específicas para macOS (Darwin) y Linux
3. Proporciona una ruta por defecto para otros sistemas operativos
4. Exporta la ruta correcta al archivo .env para que docker-compose pueda utilizarla

### Estructura de Volúmenes
El proyecto utiliza volúmenes Docker para la persistencia de datos:

- **mariadb_data**: Almacena la base de datos
- **wordpress_data**: Almacena archivos de WordPress

Estos volúmenes se configuran en docker-compose.yml utilizando la variable `DATA_PATH` para garantizar que los datos persistan fuera de los contenedores y sobrevivan a reconstrucciones:

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/mariadb
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/wordpress
```

### Configuración del Dominio
El proyecto requiere que el sitio sea accesible desde un dominio con el formato `login.42.fr`. Esto se logra mediante:

1. Detección automática del nombre de usuario (`USER := $(shell whoami)`)
2. Configuración del dominio (`DOMAIN := $(USER).42.fr`)
3. Adición de una entrada en `/etc/hosts` que apunta `login.42.fr` a `127.0.0.1`
4. Propagación del nombre de dominio a través de variables de entorno a los contenedores

## Guía de Instalación y Uso

### Requisitos Previos
- Docker y Docker Compose instalados
- Permisos de administrador para modificar `/etc/hosts`

### Instrucciones Paso a Paso

1. **Clonar el repositorio:**
   ```bash
   git clone <url-del-repositorio> inception
   cd inception
   ```

2. **Configurar el entorno:**
   ```bash
   make setup
   ```
   Este comando:
   - Detecta tu sistema operativo
   - Crea los directorios necesarios para volúmenes persistentes
   - Genera un archivo .env con las variables de entorno requeridas
   - Configura una entrada en `/etc/hosts` para tu dominio .42.fr

3. **Construir y levantar los contenedores:**
   ```bash
   make up
   ```

4. **Acceder a WordPress:**
   Abre tu navegador web y visita `https://tu_login.42.fr`
   
   > **Nota:** Como el certificado es autofirmado, el navegador mostrará una advertencia de seguridad. Puedes proceder de manera segura aceptando el riesgo.

### Comandos Disponibles

| Comando | Función |
|---------|---------|
| `make setup` | Configura el entorno (crea directorios, archivo .env, etc.) |
| `make up` | Construye y levanta todos los contenedores |
| `make down` | Detiene y elimina los contenedores |
| `make restart` | Reinicia todos los contenedores |
| `make logs` | Muestra los logs de los contenedores |
| `make ps` | Lista los contenedores en ejecución |
| `make clean` | Limpia contenedores, imágenes y volúmenes |
| `make fclean` | Limpia todo, incluyendo directorios de datos |
| `make re` | Reconstruye todo desde cero |

## Variables de Entorno

El proyecto utiliza un archivo `.env` para configurar los servicios. Las principales variables son:

| Variable | Descripción |
|----------|-------------|
| `DB_NAME` | Nombre de la base de datos para WordPress |
| `DB_USER` | Usuario de base de datos para WordPress |
| `DB_PASSWORD` | Contraseña de base de datos para el usuario |
| `DB_ROOT_PASSWORD` | Contraseña root para MariaDB |
| `DB_HOST` | Hostname de la base de datos |
| `WP_TITLE` | Título del sitio WordPress |
| `WP_ADMIN_USER` | Usuario administrador de WordPress |
| `WP_ADMIN_PASSWORD` | Contraseña del administrador |
| `WP_ADMIN_EMAIL` | Email del administrador |
| `DOMAIN_NAME` | Nombre de dominio del sitio (login.42.fr) |
| `DATA_PATH` | Ruta para almacenamiento persistente de datos |

## Estructura de Archivos

```
.
├── Makefile                # Comandos principales para gestionar el proyecto
├── setup.sh                # Script auxiliar para configuración
├── srcs
│   ├── configs/            # Utilidades de configuración
│   │   └── detect_os.sh    # Script para detectar SO y configurar rutas
│   ├── docker-compose/     # Configuración de Docker Compose
│   │   └── docker-compose.yml
│   └── requirements/       # Directorios de servicios individuales
│       ├── mariadb/        # Servicio de base de datos
│       │   ├── Dockerfile
│       │   └── tools/
│       │       └── init_mariadb.sh
│       ├── nginx/          # Servidor web
│       │   ├── Dockerfile
│       │   └── conf/
│       │       └── nginx.conf
│       └── wordpress/      # Servicio WordPress + PHP-FPM
│           ├── Dockerfile
│           └── tools/
│               └── init_wordpress.sh
└── .env                    # Variables de entorno (creado por setup)
```

## Resolución de Problemas

### Certificado SSL no confiable
**Problema:** El navegador muestra advertencia sobre certificado no confiable.
**Solución:** Es el comportamiento esperado para certificados autofirmados. Puedes:
- Aceptar el riesgo en el navegador (para uso en desarrollo)
- Añadir el certificado a tus autoridades de confianza (solo para pruebas)

### Error de "No se puede conectar al servidor"
**Problema:** No puedes acceder a https://login.42.fr
**Solución:** Verifica:
- Que la entrada en `/etc/hosts` esté correctamente configurada
- Que los contenedores estén ejecutándose (`make ps`)
- Los logs de NGINX por posibles errores (`make logs`)

### Error en rutas de volúmenes
**Problema:** Docker no puede montar los volúmenes.
**Solución:**
- Ejecuta `make fclean` y luego `make setup` de nuevo
- Verifica los permisos en el directorio DATA_PATH
- Comprueba que el directorio existe (`ls -la ~/data` o `/home/username/data`)

## Notas Adicionales

- El proyecto está diseñado para ser evaluado principalmente en Linux, pero funcionará en macOS con las configuraciones de rutas automáticas.
- Los certificados autofirmados son solo para desarrollo y no deben usarse en producción.
- Las contraseñas incluidas en el archivo .env generado son solo para desarrollo. En un entorno real, deberían ser más seguras.

---

Este proyecto fue desarrollado como parte del currículo de 42.# inceptionSensei
