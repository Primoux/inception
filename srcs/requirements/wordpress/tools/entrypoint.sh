#!/bin/bash

set -e

DB_PASSWORD=$(cat /run/secrets/db_password)


exec php-fpm8.2 -F
