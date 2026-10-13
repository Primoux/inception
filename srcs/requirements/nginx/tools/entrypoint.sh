#!/bin/bash

set -e

DOMAIN_NAME=${DOMAIN_NAME}
LOGIN_ROOT=${LOGIN_ROOT}

if [ ! -f /etc/nginx/ssl/${LOGIN_ROOT}.key ] || [ ! -f /etc/nginx/ssl/${LOGIN_ROOT}.crt ]; then
	echo "Generating SSL certificate for ${DOMAIN_NAME}..."
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
   		-keyout /etc/nginx/ssl/${LOGIN_ROOT}.key \
    	-out /etc/nginx/ssl/${LOGIN_ROOT}.crt \
    	-subj "/C=FR/L=Lyon/O=42/CN=${DOMAIN_NAME}"
fi

sed -i "s|\${DOMAIN_NAME}|${DOMAIN_NAME}|g" /etc/nginx/conf.d/nginx.conf
sed -i "s|\${LOGIN_ROOT}|${LOGIN_ROOT}|g" /etc/nginx/conf.d/nginx.conf

exec nginx -g "daemon off;"
