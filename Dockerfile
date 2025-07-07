FROM registry.2le.net/2le/2le:base-sf7

COPY ./docker/php/php.ini /usr/local/etc/php/
COPY ./docker/apache/default.conf /etc/apache2/conf.d/000-default.conf
COPY . /var/www/html/

WORKDIR /var/www/html

ENV APP_NAME="[PROJECT]"
ARG app_version=dev
ENV APP_VERSION=$app_version

RUN COMPOSER_MEMORY_LIMIT=-1 COMPOSER_ALLOW_SUPERUSER=1 composer install  --no-scripts
RUN bin/console assets:install --symlink
RUN npm install
RUN npm run build

VOLUME ["/var/www/html/var/cache"]

EXPOSE 80
