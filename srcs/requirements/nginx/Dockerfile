FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl gettext-base \
    && rm /etc/nginx/sites-enabled/default

RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/conf.d/
COPY tools/entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
