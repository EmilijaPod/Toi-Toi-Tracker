#!/usr/bin/env bash

set -euo pipefail

#
# LAMP – Docker variant (P = PHP build)
# Structure intentionally mirrors a UNIX LAMP installer:
# - root check
# - /opt/src build directory
# - installing dependencies
# - building PHP from source
#

if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root (or with sudo)." >&2
  exit 1
fi

# Global variables
SRC_DIR="/opt/src"
PHP_VERSION="${PHP_VERSION:-8.2.12}"
PHP_PREFIX="/opt/php"

# Reduce memory usage during build
export MAKEFLAGS="-j1"

echo "=== [1/4] Preparing build environment ==="
mkdir -p "${SRC_DIR}"
cd "${SRC_DIR}"

apt-get update
apt-get install -y \
  build-essential \
  wget \
  libssl-dev \
  zlib1g-dev \
  libxml2-dev \
  libsqlite3-dev \
  libcurl4-openssl-dev \
  libonig-dev

echo "=== [2/4] Downloading PHP ${PHP_VERSION} ==="
TARBALL="php-${PHP_VERSION}.tar.gz"

if [[ ! -f "${TARBALL}" ]]; then
  wget "https://www.php.net/distributions/${TARBALL}"
fi

rm -rf "php-${PHP_VERSION}"
tar xzf "${TARBALL}"
cd "php-${PHP_VERSION}"

echo "=== [3/4] Configuring PHP-FPM (minimal build) ==="
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
  --without-pear \
  --disable-opcache \
  --disable-fileinfo \
  --disable-phar \
  --disable-dom \
  --disable-simplexml \
  --disable-xmlreader \
  --disable-xmlwriter \
  --disable-exif

echo "=== Compiling PHP (this may take a while) ==="
make -j1
make install

echo "=== [4/4] Creating PHP configuration and FPM pool ==="

# php.ini
mkdir -p "${PHP_PREFIX}/etc"

cat > "${PHP_PREFIX}/etc/php.ini" <<'EOF'
[PHP]
memory_limit = 256M
post_max_size = 32M
upload_max_filesize = 32M
max_execution_time = 60
display_errors = On
error_reporting = E_ALL

[Date]
date.timezone = Europe/Vilnius

[Session]
session.save_handler = files
session.save_path = "/tmp"
EOF

# PHP-FPM configuration
mkdir -p "${PHP_PREFIX}/etc/php-fpm.d"

cat > "${PHP_PREFIX}/etc/php-fpm.conf" <<EOF
[global]
daemonize = no
include=${PHP_PREFIX}/etc/php-fpm.d/*.conf
EOF

cat > "${PHP_PREFIX}/etc/php-fpm.d/www.conf" <<EOF
[www]
user = www-data
group = www-data
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
EOF

# Add PHP to PATH
if ! grep -q "${PHP_PREFIX}/bin" /etc/profile; then
  echo "export PATH=${PHP_PREFIX}/bin:${PHP_PREFIX}/sbin:\$PATH" >> /etc/profile
fi

ln -sf "${PHP_PREFIX}/bin/php" /usr/local/bin/php
ln -sf "${PHP_PREFIX}/sbin/php-fpm" /usr/local/sbin/php-fpm

echo
echo "PHP build completed:"
echo "  - Installed to: ${PHP_PREFIX}"
echo "  - php.ini: ${PHP_PREFIX}/etc/php.ini"
echo "  - PHP-FPM listening on 127.0.0.1:9000"
