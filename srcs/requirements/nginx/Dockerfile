FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl \
    && rm /etc/nginx/sites-enabled/default

RUN mkdir -p /etc/nginx/ssl && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/enchevri.key \
    -out /etc/nginx/ssl/enchevri.crt \
    -subj "/C=FR/L=Lyon/O=42/CN=enchevri.42.fr"

COPY conf/nginx.conf /etc/nginx/conf.d/

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
