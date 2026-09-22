#!/bin/sh
# ==================== Persiapan saat container mulai ====================
# Dijalankan sebelum supervisor menyalakan php-fpm, nginx, queue worker,
# dan scheduler.
set -e

cd /var/www/html

echo "[entrypoint] Menyiapkan direktori storage..."

# data/storage di-host di-mount menimpa isi storage bawaan image, jadi folder
# yang dibutuhkan Laravel harus dibuat ulang di sini.
mkdir -p \
    storage/logs \
    storage/app/public \
    storage/framework/cache/data \
    storage/framework/sessions \
    storage/framework/views \
    bootstrap/cache

chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Tautan public/storage -> storage/app/public (untuk berkas unggahan)
php artisan storage:link >/dev/null 2>&1 || true

echo "[entrypoint] Menyegarkan cache Laravel..."

# package:discover dilakukan di sini (bukan saat build) karena bootstrap/cache
# belum ada pada tahap build dan variabel lingkungan baru tersedia sekarang.
php artisan package:discover --ansi >/dev/null 2>&1 || true

# config:cache menyimpan nilai env ke berkas cache. Dijalankan tiap kali
# container mulai supaya perubahan .env ikut terbaca.
php artisan config:cache >/dev/null 2>&1 || echo "[entrypoint] PERINGATAN: config:cache gagal"
php artisan view:cache   >/dev/null 2>&1 || echo "[entrypoint] PERINGATAN: view:cache gagal"

echo "[entrypoint] Menyalakan php-fpm, nginx, queue worker, dan scheduler..."

exec /usr/bin/supervisord -c /etc/supervisord.conf
