#!/bin/sh
set -e

su www-data -s /bin/ash -c "php -d memory_limit=-1 bin/console cache:clear --no-warmup"
su www-data -s /bin/ash -c "php -d memory_limit=-1 bin/console cache:warmup"

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php "$@"
fi

if [ "$1" = "php-fpm" ]; then
  # Run nginx in background
  nginx -g 'pid /tmp/nginx.pid;'
fi

exec "$@"