#!/bin/bash
# DuitKita — Update Deploy (jalankan setelah git push)
# Usage: bash deploy-update.sh

set -e

APP_DIR="/var/www/duitkita"

echo "[ ] Pull latest code..."
cd "$APP_DIR"
git pull origin main

echo "[ ] Composer install..."
cd "$APP_DIR/backend"
composer install --no-dev --optimize-autoloader --no-interaction -q

echo "[ ] Migrate..."
php artisan migrate --force

echo "[ ] Clear & cache config..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "[ ] Restart workers..."
supervisorctl restart duitkita-worker:*
supervisorctl restart duitkita-scheduler

echo "[ ] Fix permissions..."
chown -R www-data:www-data "$APP_DIR/backend/storage"
chown -R www-data:www-data "$APP_DIR/backend/bootstrap/cache"

echo ""
echo "Update done!"
