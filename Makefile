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

re: down all

clean: down
	@docker system prune -a

fclean: clean
	@docker volume rm -f srcs_wordpress_data srcs_mariadb_data 2>/dev/null || true
	@rm -rf $(shell pwd)/data/wordpress/*
	@rm -rf $(shell pwd)/data/mariadb/*
	@docker system prune -a --volumes

.PHONY: all build down re clean fclean