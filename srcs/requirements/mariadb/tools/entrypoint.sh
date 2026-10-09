#!/bin/bash
set -e

MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld
if [ ! -d /var/lib/mysql/mysql ]; then
	mariadb-install-db --datadir=/var/lib/mysql --user=mysql
fi

# Apply the users/database setup before the real server starts (no temporary file)
mariadbd --user=mysql --bootstrap <<EOSQL
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};
CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
ALTER USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

exec mariadbd --user=mysql
