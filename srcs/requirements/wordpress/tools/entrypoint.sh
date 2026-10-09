#!/bin/sh
set -e

USER_PASSWORD=$(cat /run/secrets/wp_password_user)
ADMIN_PASSWORD=$(cat /run/secrets/wp_password_admin)
MARIADB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASS=$(cat /run/secrets/wp_password_admin)

#

# mkdir -p /var/www/html
# cd /var/www/html

# if [ ! -d /var/www/html/wordpress ]; then
#   curl -LO https://wordpress.org/latest.tar.gz
#   tar -xzf latest.tar.gz
#   rm latest.tar.gz
# fi

if [ ! -f /var/www/html/wp-cli.phar ]; then
  curl -LO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
fi


if [ ! -L /usr/bin/wp ]; then
	ln -s /var/www/html/wp-cli.phar /usr/bin/wp
fi

chmod +x /var/www/html/wp-cli.phar

if [ ! -f /var/www/html/wp-load.php ]; then
  echo "Downloading wordpress..."
  php /usr/bin/wp core download --path=/var/www/html --allow-root
fi

echo "Waiting for database..."
until MP="${MARIADB_PASSWORD}" php -r 'new mysqli("mariadb", getenv("MARIADB_USER"), getenv("MP"), getenv("MARIADB_DATABASE"));' >/dev/null 2>&1; do
  echo "Waiting for database..."
  sleep 2
done

echo "Database is ready."

if [ ! -f /var/www/html/wp-config.php ]; then
  echo "initializing wp-config..."
  php /usr/bin/wp config create \
    --path=/var/www/html \
    --dbname="${MARIADB_DATABASE}" \
    --dbuser="${MARIADB_USER}" \
    --dbpass="${MARIADB_PASSWORD}" \
    --dbhost="mariadb:3306" \
    --allow-root


fi

if ! php /var/www/html/wp-cli.phar core is-installed --path=/var/www/html --allow-root >/dev/null 2>&1; then
  echo "Installing wordpress..."
  php /usr/bin/wp core install \
    --path=/var/www/html \
    --url="https://${DOMAIN_NAME}" \
    --title="Primoux" \
    --admin_user="${WP_ADMIN}" \
    --admin_password="${ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --locale=fr_FR \
    --skip-email \
    --allow-root
  echo "Creating contributor..."
  php /usr/bin/wp user create ${WP_USER} ${WP_USER_EMAIL} \
    --path=/var/www/html \
    --role=subscriber \
    --user_pass=${USER_PASSWORD} \
    --allow-root
fi

chown -R www-data:www-data /var/www/html

echo "WordPress is ready."

exec /usr/sbin/php-fpm8.2 -F
