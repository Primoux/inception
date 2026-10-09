FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx curl \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/nginx/sites-enabled/default

COPY conf/nginx.conf /etc/nginx/conf.d/
COPY site/ /var/www/html/

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
