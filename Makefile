NAME = inception

all: 
	@mkdir -p /home/$(USER)/data/wordpress
	@mkdir -p /home/$(USER)/data/mariadb
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
	@sudo rm -rf /home/$(USER)/data/wordpress/*
	@sudo rm -rf /home/$(USER)/data/mariadb/*
	@docker system prune -a --volumes

.PHONY: all build down re clean fclean