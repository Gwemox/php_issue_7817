# Stage 0:. Install
FROM php:8.1.11-fpm-alpine as base

RUN apk add --update \
  acl \
  autoconf \
  curl \
  g++ \
  make \
  openssl \
  libxml2-dev \
  postgresql-dev \
  libssh2-dev \
  libzip-dev \
  rabbitmq-c-dev

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
  pdo_pgsql \
  pgsql \
  zip \
  redis \
  ssh2 \
  xmlrpc \
  amqp \
  opcache \
  pcntl \
  apcu \
  imagick \
  intl

RUN apk del \
  autoconf \
  g++

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1

WORKDIR /var/www/app

COPY composer.json composer.lock symfony.lock .env ./
COPY bin bin/
COPY config config/
COPY public public/
COPY src src/

## Install App dependencies (using composer in PROD env)
ARG APP_ENV=dev
ENV APP_ENV ${APP_ENV}
ARG APP_VERSION=development
ENV APP_VERSION ${APP_VERSION}

RUN set -eux; \
  composer install --no-interaction --prefer-dist --optimize-autoloader; \
  composer dump-autoload --optimize --classmap-authoritative;

## Set execution mod on App console binary
RUN chmod +x /var/www/app/bin/console; sync

## Clean var cache and log files
RUN set -eux; \
  mkdir -p /var/www/app/var/cache /var/www/app/var/log; \
  chmod 0755 /var/www/app/var/cache /var/www/app/var/log; \
  chown www-data:www-data /var/www/app/var/cache /var/www/app/var/log;

COPY .docker/php-dev.ini $PHP_INI_DIR/php.ini

RUN apk update && apk add --no-cache nginx \
  && rm -rf /tmp/* /var/cache/apk/*

COPY .docker/nginx.conf /etc/nginx/http.d/default.conf
COPY .docker/entrypoint.sh /entrypoint.sh

EXPOSE 80
ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "php-fpm", "-F" ]
