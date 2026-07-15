FROM debian:bookworm

RUN apt-get update && apt-get install mariadb-server -y

COPY conf/99-bind.cnf /etc/mysql/mariadb.conf.d/

COPY tools/entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
