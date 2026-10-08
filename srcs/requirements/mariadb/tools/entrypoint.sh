#!/bin/bash
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld
if [ ! -d /var/lib/mysql/mysql ]; then
	mariadb-install-db --datadir=/var/lib/mysql --user=mysql
fi
cat > /tmp/init.sql <<EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};
CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL
exec mariadbd --init-file=/tmp/init.sql --user=mysql
