.PHONY: all down clean fclean re exec-mariadb
SRCS =  "./srcs/docker-compose.yml"

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
