#!/bin/sh
set -e

USER_PASSWORD=$(cat /run/secrets/wp_password_user)
ADMIN_PASSWORD=$(cat /run/secrets/wp_password_admin)
MARIADB_PASSWORD=$(cat /run/secrets/db_password)

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

if [ ! -d /var/www/html/wp-load.php ]; then
  echo "Downloading wordpress..."
  php /usr/bin/wp core download --path=/var/www/html --allow-root
fi

# until php /usr/bin/wp db check --path=/var/www/html/wordpress --allow-root >/dev/null 2>&1; do
#   echo "Waiting for WordPress DB access..."
#   sleep 2
# done

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
    --url="http://${DOMAIN_NAME}" \
    --title="Primoux" \
    --admin_user="${WP_ADMIN}" \
    --admin_password="${WP_ADMIN_PASS}" \
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
echo "WordPress is ready."
# exec /usr/sbin/php-fpm -F
exec /usr/sbin/php-fpm8.2 -F
