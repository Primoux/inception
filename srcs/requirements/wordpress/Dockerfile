FROM debian:bookworm

RUN apt-get update && \
	apt-get install --no-install-recommends -y php-fpm \
	php-mysql php-curl curl ca-certificates php8.2-gd

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp && \
	chmod +x /usr/local/bin/wp

RUN mkdir -p /run/php

WORKDIR /var/www/html

EXPOSE 9000

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
