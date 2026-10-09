NAME     = inception
SRCS     = ./srcs/docker-compose.yml
DATA_DIR = /home/$(USER)/data
COMPOSE  = docker compose -f $(SRCS)
WIPE     = docker run --rm -v $(DATA_DIR):/data debian:bookworm sh -c 'rm -rf /data/mariadb /data/wordpress'

.PHONY: all up dirs down stop start restart re clean fclean \
	up-wordpress up-nginx up-mariadb \
	down-wordpress down-nginx down-mariadb \
	exec-mariadb exec-nginx exec-wordpress \
	logs ps setup help

.DEFAULT_GOAL := help

help:
	@echo "---------------------------------"
	@echo "Available commands:"
	@echo "  make all               Create data dirs, build and start all containers"
	@echo "  make up                Same as all"
	@echo "  make down              Stop and remove the containers"
	@echo "  make stop              Stop the containers (keep them)"
	@echo "  make start             Start stopped containers"
	@echo "  make restart           Restart all containers"
	@echo "  make clean             Remove containers, volumes and data"
	@echo "  make fclean            Same as clean, also removes images"
	@echo "  make re                Run fclean then all"
	@echo "  make up-<service>      Build and start one service (wordpress, nginx, mariadb)"
	@echo "  make down-<service>    Stop and remove one service"
	@echo "  make exec-<service>    Open a shell inside a container"
	@echo "  make logs              Follow the logs"
	@echo "  make ps                List the containers"
	@echo "  make setup             Launch the config makefile"
	@echo "---------------------------------"

setup:
	@make -C tools/ --no-print-directory

dirs:
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress

all: dirs
	$(COMPOSE) up --build -d

up: all

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

restart:
	$(COMPOSE) restart

up-wordpress up-nginx up-mariadb: up-%: dirs
	$(COMPOSE) up --build -d $*

down-wordpress down-nginx down-mariadb: down-%:
	$(COMPOSE) rm -sf $*

clean:
	$(COMPOSE) down -v
	-$(WIPE)
	-rm -rf $(DATA_DIR)

fclean:
	$(COMPOSE) down -v --rmi all
	-$(WIPE)
	-rm -rf $(DATA_DIR)

re: fclean all

exec-mariadb exec-nginx exec-wordpress: exec-%:
	docker exec -it $* bash

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps
