#!/bin/bash

set -e

DOMAIN_NAME=${DOMAIN_NAME}
LOGIN_ROOT=${LOGIN_ROOT}

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/${LOGIN_ROOT}.key \
    -out /etc/nginx/ssl/${LOGIN_ROOT}.crt \
    -subj "/C=FR/L=Lyon/O=42/CN=${DOMAIN_NAME}" \
    -addext "subjectAltName=DNS:${DOMAIN_NAME},DNS:status.${DOMAIN_NAME}"

sed -i "s|\${DOMAIN_NAME}|${DOMAIN_NAME}|g" /etc/nginx/conf.d/nginx.conf
sed -i "s|\${LOGIN_ROOT}|${LOGIN_ROOT}|g" /etc/nginx/conf.d/nginx.conf

exec nginx -g "daemon off;"