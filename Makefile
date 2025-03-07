NAME = inception

all: 
	@mkdir -p $(shell pwd)/data/wordpress
	@mkdir -p $(shell pwd)/data/mariadb
	@chmod -R 777 $(shell pwd)/data
	@docker-compose -f srcs/docker-compose.yml up -d --build

build:
	@docker-compose -f srcs/docker-compose.yml build --no-cache

down:
	@docker-compose -f srcs/docker-compose.yml down

re: down
	@docker-compose -f srcs/docker-compose.yml up -d --build

clean: down
	@docker system prune -a

fclean: clean
	@docker volume rm -f inception_wordpress_data inception_mariadb_data 2>/dev/null || true
	@sudo rm -rf $(shell pwd)/data/wordpress/*
	@sudo rm -rf $(shell pwd)/data/mariadb/*
	@docker system prune -a --volumes

.PHONY: all build down re clean fclean