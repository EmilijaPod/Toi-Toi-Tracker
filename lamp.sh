#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
  echo "You need root permission." >&2
  exit 1
fi

mkdir -p /opt/src
cd /opt/src

sudo apt update
sudo apt install -y build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev wget

# NGINX

NGINX_VERSION="1.25.3"
NGINX_DIR="nginx-${NGINX_VERSION}"
mkdir -p /opt/src/${NGINX_DIR}
cd /opt/src

if [ ! -f "${NGINX_DIR}.tar.gz" ]; then
    wget http://nginx.org/download/${NGINX_DIR}.tar.gz
fi

tar -xzf ${NGINX_DIR}.tar.gz -C /opt/src
cd /opt/src/${NGINX_DIR}

echo "Configuring NGINX"
./configure \
  --prefix=/opt/nginx \
  --sbin-path=/opt/nginx/sbin/nginx \
  --conf-path=/opt/nginx/conf/nginx.conf \
  --pid-path=/opt/nginx/logs/nginx.pid \
  --with-http_ssl_module \
  --with-http_gzip_static_module \
  --with-http_stub_status_module

echo  "Compiling NGINX"
make
make install

mkdir -p /opt/nginx/logs
echo "Installed NGINX"

# PHP

PHP_VERSION="8.2.18"
PHP_DIR="php-${PHP_VERSION}"
mkdir -p /opt/src/${PHP_DIR}
cd /opt/src

if [ ! -f "php-${PHP_VERSION}.tar.gz" ]; then
    wget https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz
fi

tar -xvzf php-${PHP_VERSION}.tar.gz -C /opt/src
cd /opt/src/${PHP_DIR}

sudo apt update
sudo apt install -y build-essential libxml2-dev libssl-dev \
libcurl4-openssl-dev libjpeg-dev libpng-dev libwebp-dev libxpm-dev \
libfreetype6-dev libonig-dev libzip-dev libsqlite3-dev pkg-config \
bison re2c libreadline-dev

echo "Configuring PHP"
./configure \
  --prefix=/opt/php \
  --with-fpm-user=www-data \
  --with-fpm-group=www-data \
  --enable-fpm \
  --with-mysqli \
  --with-pdo-mysql \
  --with-openssl \
  --with-zlib \
  --enable-mbstring \
  --enable-zip \
  --enable-soap \
  --with-curl \
  --with-jpeg \
  --with-webp \
  --with-xpm \
  --with-freetype \
  --enable-bcmath \
  --enable-exif \
  --enable-sockets \
  --with-readline

echo "Compiling PHP"
make -j"$(nproc)"
make install

echo "Installed PHP"
/opt/php/bin/php -v

# MariaDB

MARIADB_VERSION="10.6.16"
MARIADB_DIR="mariadb-${MARIADB_VERSION}"
mkdir -p /opt/src/${MARIADB_DIR}
cd /opt/src

sudo apt install -y cmake make gcc g++ libncurses5-dev libssl-dev bison libaio-dev

if [ ! -f "${MARIADB_DIR}.tar.gz" ]; then
    wget "https://archive.mariadb.org/mariadb-${MARIADB_VERSION}/source/${MARIADB_DIR}.tar.gz"
fi

tar -xzf "${MARIADB_DIR}.tar.gz" -C /opt/src
cd /opt/src/${MARIADB_DIR}
mkdir -p build && cd build
