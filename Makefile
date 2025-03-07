# Variables
DOCKER_COMPOSE = docker-compose -f srcs/docker-compose/docker-compose.yml

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

# Variables de entorno
ENV_FILE = .env

# Targets
all: setup up

setup: detect_os create_dirs create_env hosts

detect_os:
	@echo "Detectando sistema operativo: $(UNAME_S)"
	@echo "Usuario actual: $(USER)"
	@echo "Ruta de datos: $(DATA_PATH)"
	@echo "Dominio: $(DOMAIN)"

hosts:
	@echo "Configurando entrada en /etc/hosts para $(DOMAIN)..."
	@if ! grep -q "$(DOMAIN)" /etc/hosts; then \
		echo "127.0.0.1 $(DOMAIN)" | sudo tee -a /etc/hosts > /dev/null; \
		echo "Entrada añadida correctamente."; \
	else \
		echo "La entrada para $(DOMAIN) ya existe en /etc/hosts."; \
	fi

create_dirs:
	@echo "Creando directorios para volúmenes persistentes..."
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@echo "Directorios creados en $(DATA_PATH)"

create_env:
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "Creando archivo .env..."; \
		echo "DB_NAME=wordpress" > $(ENV_FILE); \
		echo "DB_USER=wpuser" >> $(ENV_FILE); \
		echo "DB_PASSWORD=wppassword" >> $(ENV_FILE); \
		echo "DB_ROOT_PASSWORD=rootpassword" >> $(ENV_FILE); \
		echo "DB_HOST=mariadb" >> $(ENV_FILE); \
		echo "WP_TITLE=Inception" >> $(ENV_FILE); \
		echo "WP_ADMIN_USER=admin" >> $(ENV_FILE); \
		echo "WP_ADMIN_PASSWORD=adminpassword" >> $(ENV_FILE); \
		echo "WP_ADMIN_EMAIL=admin@example.com" >> $(ENV_FILE); \
		echo "WP_URL=$(DOMAIN)" >> $(ENV_FILE); \
		echo "DOMAIN_NAME=$(DOMAIN)" >> $(ENV_FILE); \
		echo "DATA_PATH=$(DATA_PATH)" >> $(ENV_FILE); \
		echo "Archivo .env creado con éxito."; \
	else \
		echo "El archivo .env ya existe. No se sobrescribirá."; \
		if ! grep -q "DOMAIN_NAME=$(DOMAIN)" $(ENV_FILE); then \
			echo "Actualizando DOMAIN_NAME en el archivo .env..."; \
			sed -i.bak "s/DOMAIN_NAME=.*/DOMAIN_NAME=$(DOMAIN)/g" $(ENV_FILE) && rm -f $(ENV_FILE).bak || \
			sed -i "" "s/DOMAIN_NAME=.*/DOMAIN_NAME=$(DOMAIN)/g" $(ENV_FILE); \
			echo "DOMAIN_NAME actualizado a $(DOMAIN) en el archivo .env"; \
		fi; \
	fi

up:
	@echo "Levantando contenedores..."
	$(DOCKER_COMPOSE) up --build -d

down:
	@echo "Deteniendo contenedores..."
	$(DOCKER_COMPOSE) down

restart:
	@echo "Reiniciando contenedores..."
	$(DOCKER_COMPOSE) restart

logs:
	@echo "Mostrando logs..."
	$(DOCKER_COMPOSE) logs -f

ps:
	@echo "Mostrando contenedores en ejecución..."
	$(DOCKER_COMPOSE) ps

clean: down
	@echo "Limpiando contenedores, imágenes y volúmenes..."
	docker system prune -af --volumes

fclean: clean
	@echo "Eliminando directorios de datos..."
	rm -rf $(DATA_PATH)/mariadb
	rm -rf $(DATA_PATH)/wordpress
	rm -f $(ENV_FILE)

re: fclean all

.PHONY: all setup detect_os hosts create_dirs create_env up down restart logs ps clean fclean re