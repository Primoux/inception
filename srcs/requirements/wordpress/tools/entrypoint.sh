#!/bin/sh
set -e

USER_PASSWORD=$(cat /run/secrets/wp_password_user)
ADMIN_PASSWORD=$(cat /run/secrets/wp_password_admin)
MARIADB_PASSWORD=$(cat /run/secrets/db_password)

if [ ! -f /var/www/html/wp-load.php ]; then
  echo "Downloading wordpress..."
  wp core download --path=/var/www/html --allow-root
fi

if [ ! -f /var/www/html/wp-config.php ]; then
  echo "initializing wp-config..."
  wp config create \
    --path=/var/www/html \
    --dbname="${MARIADB_DATABASE}" \
    --dbuser="${MARIADB_USER}" \
    --dbpass="${MARIADB_PASSWORD}" \
    --dbhost="mariadb:3306" \
    --allow-root
fi

if ! wp core is-installed --path=/var/www/html --allow-root >/dev/null 2>&1; then
  echo "Installing wordpress..."
  wp core install \
    --path=/var/www/html \
    --url="https://${DOMAIN_NAME}" \
    --title="Primoux" \
    --admin_user="${WP_ADMIN}" \
    --admin_password="${ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --locale=fr_FR \
    --skip-email \
    --allow-root
fi

if ! wp user get "${WP_USER}" --path=/var/www/html --allow-root >/dev/null 2>&1; then
  echo "Creating contributor..."
  wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
    --path=/var/www/html \
    --role=author \
    --user_pass="${USER_PASSWORD}" \
    --allow-root
fi

chown -R www-data:www-data /var/www/html

echo "WordPress is ready."

exec /usr/sbin/php-fpm8.2 -F
