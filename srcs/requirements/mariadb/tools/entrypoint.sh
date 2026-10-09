#!/bin/bash
set -e

MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld
if [ ! -d /var/lib/mysql/mysql ]; then
	mariadb-install-db --datadir=/var/lib/mysql --user=mysql
fi
INIT_SQL=/tmp/init.sql
umask 077
cat > ${INIT_SQL} <<EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};
CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
ALTER USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL
chown mysql:mysql ${INIT_SQL}

(
	until mariadb-admin ping -uroot -p"${MYSQL_ROOT_PASSWORD}" --silent >/dev/null 2>&1; do
		sleep 1
	done
	rm -f ${INIT_SQL}
) &

exec mariadbd --init-file=${INIT_SQL} --user=mysql
