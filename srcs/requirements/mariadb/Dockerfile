FROM debian:bookworm

RUN apt-get update && apt-get install --no-install-recommends -y mariadb-server

COPY conf/99-bind.cnf /etc/mysql/mariadb.conf.d/

COPY tools/entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
