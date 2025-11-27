#!/usr/bin/env bash
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then echo "Run as root." >&2; exit 1; fi

# Kintamieji
SRC_DIR="/opt/src"
PHP_VERSION="${PHP_VERSION:-8.2.12}"
PHP_PREFIX="/opt/php"
export MAKEFLAGS="-j$(nproc)"

echo "=== [1/4] Preparing build environment ==="
mkdir -p "${SRC_DIR}"
cd "${SRC_DIR}"

# PATAISYMAS: Pridedame libpcre2-dev ir libpcre3-dev (kad tikrai rastų)
apt-get update
apt-get install -y build-essential wget libssl-dev zlib1g-dev libxml2-dev \
libsqlite3-dev libcurl4-openssl-dev libonig-dev libpq-dev pkg-config \
libpcre3 libpcre3-dev libpcre2-dev

echo "=== [2/4] Downloading NGINX ==="
NGINX_VERSION="1.25.3"
if [ ! -f "nginx-${NGINX_VERSION}.tar.gz" ]; then
   wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
fi
rm -rf "nginx-${NGINX_VERSION}"
tar -xzf "nginx-${NGINX_VERSION}.tar.gz"
cd "nginx-${NGINX_VERSION}"

echo "=== Configuring NGINX ==="
# Priverstinai nurodome PCRE kelią, jei automatiškai nerastų, bet su dev paketais turėtų rasti.
./configure \
  --prefix=/opt/nginx \
  --sbin-path=/opt/nginx/sbin/nginx \
  --conf-path=/opt/nginx/conf/nginx.conf \
  --pid-path=/opt/nginx/logs/nginx.pid \
  --with-http_ssl_module \
  --with-http_stub_status_module

make
make install
mkdir -p /opt/nginx/logs

echo "=== [3/4] Downloading PHP ${PHP_VERSION} ==="
cd "${SRC_DIR}"
TARBALL="php-${PHP_VERSION}.tar.gz"
if [[ ! -f "${TARBALL}" ]]; then
  wget "https://www.php.net/distributions/${TARBALL}"
fi
rm -rf "php-${PHP_VERSION}"
tar xzf "${TARBALL}"
cd "php-${PHP_VERSION}"

echo "=== [4/4] Configuring PHP-FPM ==="
./configure \
  --prefix="${PHP_PREFIX}" \
  --with-fpm-user=www-data \
  --with-fpm-group=www-data \
  --enable-fpm \
  --with-zlib \
  --enable-mbstring \
  --with-openssl \
  --with-mysqli \
  --with-pdo-mysql \
  --with-pdo-pgsql \
  --with-pgsql \
  --without-pear \
  --disable-opcache \
  --disable-fileinfo \
  --disable-phar \
  --disable-dom \
  --disable-simplexml \
  --disable-xmlreader \
  --disable-xmlwriter \
  --disable-exif

echo "=== Compiling PHP ==="
make
make install

echo "=== Configuration ==="
mkdir -p "${PHP_PREFIX}/etc"
cat > "${PHP_PREFIX}/etc/php.ini" <<INI
[PHP]
memory_limit = 256M
display_errors = On
error_reporting = E_ALL
date.timezone = Europe/Vilnius
INI

mkdir -p "${PHP_PREFIX}/etc/php-fpm.d"
cat > "${PHP_PREFIX}/etc/php-fpm.conf" <<CONF
[global]
daemonize = no
include=${PHP_PREFIX}/etc/php-fpm.d/*.conf
CONF

cat > "${PHP_PREFIX}/etc/php-fpm.d/www.conf" <<WWW
[www]
user = www-data
group = www-data
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
WWW

ln -sf "${PHP_PREFIX}/bin/php" /usr/local/bin/php
ln -sf "${PHP_PREFIX}/sbin/php-fpm" /usr/local/sbin/php-fpm
