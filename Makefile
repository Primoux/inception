.PHONY: help all down clean fclean re exec-mariadb exec-nginx
.DEFAULT_GOAL := help
SRCS =  "./srcs/docker-compose.yml"

help:
	@echo "---------------------------------"
	@echo "Available commands:"
	@echo "  make all		Build and start all containers"
	@echo "  make down		Stop the containers"
	@echo "  make clean		Stop the containers and remove volumes/data"
	@echo "  make fclean		Same as clean, also removes local images"
	@echo "  make re		Run fclean then all"
	@echo "  make exec-mariadb	Open a shell inside the mariadb container"
	@echo "  make exec-nginx	Open a shell inside the nginx container"
	@echo "  make exec-wordpress	Open a shell inside the wordpress container"
	@echo "  make setup		Launch the config makefile"
	@echo "---------------------------------"

setup:
	@make -C tools/ --no-print-directory 
all:
	mkdir -p /home/$(USER)/data/mariadb
	docker compose -f $(SRCS) up --build -d
down:
	docker compose -f $(SRCS) down
clean:
	docker compose -f $(SRCS) down -v
	docker run --rm -v /home/$(USER)/data:/data debian:bookworm rm -rf /data/mariadb
fclean:
	docker compose -f $(SRCS) down -v --rmi local
	docker run --rm -v /home/$(USER)/data:/data debian:bookworm rm -rf /data/mariadb
re: fclean all
exec-mariadb:
	docker exec -it mariadb bash
exec-nginx:
	docker exec -it nginx bash
exec-wordpress:
	docker exec -it wordpress bash
