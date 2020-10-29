FROM ubuntu:20.04

MAINTAINER Jose Fonseca <jose@ditecnologia.com>

RUN apt-get clean && apt-get -y update && apt-get install -y locales && locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' LC_ALL='en_US.UTF-8'

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx curl zip unzip git software-properties-common supervisor sqlite3 libxrender1 libxext6 mysql-client libssh2-1-dev autoconf libz-dev \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y php7.4-fpm php7.4-cli php7.4-gd php7.4-mysql php7.4-intl php7.4-pgsql \
       php7.4-imap php-memcached php7.4-mbstring php7.4-xml php7.4-curl \
       php7.4-sqlite3 php7.4-zip php7.4-pdo-dblib php7.4-bcmath php7.4-ssh2 php7.4-dev php7.4-redis php-pear \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && mkdir /run/php

COPY datadog-php-tracer_0.41.1_amd64.deb /datadog-php-tracer_0.41.1_amd64.deb

RUN dpkg -i datadog-php-tracer_0.41.1_amd64.deb \
    && update-ca-certificates \
    && apt-get remove -y --purge software-properties-common \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "daemon off;" >> /etc/nginx/nginx.conf \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY default /etc/nginx/sites-available/default
COPY www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf
COPY php.ini /etc/php/7.4/fpm/php.ini

EXPOSE 80

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]
