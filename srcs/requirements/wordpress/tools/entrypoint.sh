#!/bin/bash

set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_PASSWORD_ADMIN=$(cat /run/secrets/wp_password_admin)
WP_PASSWORD_USER=$(cat /run/secrets/wp_password_user)

exec php-fpm8.2 -F
