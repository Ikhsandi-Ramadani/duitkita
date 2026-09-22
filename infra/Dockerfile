# ==================== TAHAP 1: bangun aset frontend ====================
# Inertia + Vue 3 + Vite. Folder public/build tidak ada di repo (masuk
# .gitignore), jadi harus dibangun di sini.
FROM node:24-alpine AS assets

WORKDIR /build
COPY backend/package*.json ./
# Kalau package-lock.json ada, npm ci memakai versi paket yang terkunci.
# Kalau belum ada, npm install dipakai supaya build tetap bisa jalan.
RUN if [ -f package-lock.json ]; then \
        npm ci --no-audit --no-fund; \
    else \
        echo "package-lock.json tidak ada — memakai npm install"; \
        npm install --no-audit --no-fund; \
    fi

COPY backend/vite.config.js ./
COPY backend/resources ./resources
RUN npm run build


# ==================== TAHAP 2: aplikasi PHP ====================
FROM php:8.5-fpm-alpine

# nginx      : web server yang menerima permintaan HTTP
# supervisor : menjalankan php-fpm + nginx + queue worker + scheduler
# unzip      : Composer butuh ini untuk membuka paket berbentuk .zip
#
# Image php:8.5-fpm-alpine sudah menyertakan ctype, curl, dom, fileinfo,
# mbstring, openssl, session, SimpleXML, tokenizer, xml, dan OPcache.
# Yang perlu ditambahkan: pdo_mysql (penghubung MySQL), bcmath (hitung uang),
# dan zip (Composer).
RUN apk add --no-cache \
        nginx supervisor bash curl tzdata unzip libzip \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS libzip-dev \
    && docker-php-ext-install -j"$(nproc)" pdo_mysql bcmath zip \
    && apk del --no-network .build-deps

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Kode backend (folder mobile/ dan screenshots/ dikecualikan lewat .dockerignore)
COPY backend/ .

# Aset hasil build dari tahap 1
COPY --from=assets /build/public/build ./public/build

# Dependensi PHP versi produksi. --no-scripts karena bootstrap/cache belum ada;
# package:discover dijalankan entrypoint saat container mulai (env sudah ada).
# Diulang sampai 3x: unduhan dist dari api.github.com pernah balas HTTP 504
# (gangguan sesaat) dan langsung menggagalkan seluruh build.
RUN set -e; \
    for i in 1 2 3; do \
        if composer install \
            --no-dev \
            --no-interaction \
            --prefer-dist \
            --optimize-autoloader \
            --no-scripts; then \
            exit 0; \
        fi; \
        echo "composer install gagal (percobaan $i/3), ulangi..."; \
        sleep 5; \
    done; \
    exit 1

RUN rm -f /etc/nginx/http.d/default.conf \
    && mkdir -p /run/nginx

COPY infra/nginx.conf         /etc/nginx/http.d/app.conf
COPY infra/supervisord.conf   /etc/supervisord.conf
COPY infra/php.ini            /usr/local/etc/php/conf.d/99-app.ini
COPY infra/entrypoint.sh      /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
