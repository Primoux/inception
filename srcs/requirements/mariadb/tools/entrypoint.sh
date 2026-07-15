#!/bin/bash

if [ ! -d /var/lib/mysql/mysql ]; then
	#create the MariaDB system tables
	mariadb-install-db --datadir=/var/lib/mysql --user=mysql
	MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
	MYSQL_PASSWORD=$(cat /run/secrets/db_password)

fi
