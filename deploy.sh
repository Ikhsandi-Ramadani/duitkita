#!/bin/bash
# DuitKita — Fresh VPS Deploy Script (Ubuntu 22.04/24.04 + Nginx)
# Usage: bash deploy.sh
# Fill in the variables below before running.

set -e

# ─── CONFIG — EDIT THESE ─────────────────────────────────────────────────────
REPO_URL="https://github.com/YOUR_USERNAME/duitkita.git"   # ganti
DOMAIN="api.yourdomain.com"                                 # ganti, atau pakai IP VPS
DB_NAME="duitkita"
DB_USER="duitkita"
DB_PASS="$(openssl rand -base64 24)"                        # auto-generate, disimpan di /root/.duitkita-db-pass
APP_DIR="/var/www/duitkita"
PHP="php8.3"
# ──────────────────────────────────────────────────────────────────────────────

echo "============================================"
echo "  DuitKita Backend — Fresh Deploy"
echo "============================================"

# 1. System update
echo "[1/12] Update system..."
apt-get update -qq && apt-get upgrade -y -qq

# 2. PHP 8.3 + extensions
echo "[2/12] Install PHP 8.3..."
apt-get install -y -qq software-properties-common
add-apt-repository -y ppa:ondrej/php
apt-get update -qq
apt-get install -y -qq \
  php8.3 php8.3-fpm php8.3-cli \
  php8.3-mysql php8.3-mbstring php8.3-xml php8.3-curl \
  php8.3-zip php8.3-bcmath php8.3-intl php8.3-gd \
  php8.3-tokenizer php8.3-fileinfo

# 3. Nginx
echo "[3/12] Install Nginx..."
apt-get install -y -qq nginx

# 4. MySQL
echo "[4/12] Install MySQL..."
apt-get install -y -qq mysql-server

# 5. Composer
echo "[5/12] Install Composer..."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# 6. Git + clone repo
echo "[6/12] Clone repo..."
apt-get install -y -qq git
git clone "$REPO_URL" "$APP_DIR"

# 7. MySQL — create DB + user
echo "[7/12] Setup MySQL..."
echo "$DB_PASS" > /root/.duitkita-db-pass
chmod 600 /root/.duitkita-db-pass
mysql -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
echo "  DB password saved to /root/.duitkita-db-pass"

# 8. Laravel setup
echo "[8/12] Laravel setup..."
cd "$APP_DIR/backend"

composer install --no-dev --optimize-autoloader --no-interaction -q

cp .env.example .env
sed -i "s|APP_ENV=local|APP_ENV=production|g" .env
sed -i "s|APP_DEBUG=true|APP_DEBUG=false|g" .env
sed -i "s|APP_URL=http://localhost|APP_URL=https://$DOMAIN|g" .env
sed -i "s|DB_CONNECTION=sqlite|DB_CONNECTION=mysql|g" .env
sed -i "s|# DB_HOST=127.0.0.1|DB_HOST=127.0.0.1|g" .env
sed -i "s|# DB_PORT=3306|DB_PORT=3306|g" .env
sed -i "s|# DB_DATABASE=laravel|DB_DATABASE=$DB_NAME|g" .env
sed -i "s|# DB_USERNAME=root|DB_USERNAME=$DB_USER|g" .env
sed -i "s|# DB_PASSWORD=|DB_PASSWORD=$DB_PASS|g" .env
sed -i "s|QUEUE_CONNECTION=database|QUEUE_CONNECTION=database|g" .env
sed -i "s|FILESYSTEM_DISK=local|FILESYSTEM_DISK=public|g" .env

php artisan key:generate --force
php artisan migrate --force
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 9. Permissions
echo "[9/12] Set permissions..."
chown -R www-data:www-data "$APP_DIR/backend"
chmod -R 755 "$APP_DIR/backend"
chmod -R 775 "$APP_DIR/backend/storage"
chmod -R 775 "$APP_DIR/backend/bootstrap/cache"

# 10. Nginx config
echo "[10/12] Configure Nginx..."
cat > /etc/nginx/sites-available/duitkita <<NGINX
server {
    listen 80;
    server_name $DOMAIN;
    root $APP_DIR/backend/public;

    index index.php;
    charset utf-8;

    client_max_body_size 10M;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
NGINX

ln -sf /etc/nginx/sites-available/duitkita /etc/nginx/sites-enabled/duitkita
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx

# 11. Supervisor — queue worker + scheduler
echo "[11/12] Setup Supervisor..."
apt-get install -y -qq supervisor

cat > /etc/supervisor/conf.d/duitkita-worker.conf <<SUPERVISOR
[program:duitkita-worker]
process_name=%(program_name)s_%(process_num)02d
command=php $APP_DIR/backend/artisan queue:work database --sleep=3 --tries=3 --max-time=3600
directory=$APP_DIR/backend
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=$APP_DIR/backend/storage/logs/worker.log
stopwaitsecs=3600
SUPERVISOR

cat > /etc/supervisor/conf.d/duitkita-scheduler.conf <<SUPERVISOR
[program:duitkita-scheduler]
process_name=%(program_name)s
command=php $APP_DIR/backend/artisan schedule:work
directory=$APP_DIR/backend
autostart=true
autorestart=true
user=www-data
redirect_stderr=true
stdout_logfile=$APP_DIR/backend/storage/logs/scheduler.log
SUPERVISOR

supervisorctl reread
supervisorctl update
supervisorctl start duitkita-worker:*
supervisorctl start duitkita-scheduler

# 12. UFW firewall
echo "[12/12] Configure firewall..."
apt-get install -y -qq ufw
ufw --force enable
ufw allow OpenSSH
ufw allow 'Nginx Full'

echo ""
echo "============================================"
echo "  Deploy DONE!"
echo "============================================"
echo "  URL     : http://$DOMAIN"
echo "  DB pass : $(cat /root/.duitkita-db-pass)"
echo ""
echo "  Next steps:"
echo "  1. Point domain DNS A record → VPS IP"
echo "  2. Run: certbot --nginx -d $DOMAIN   (HTTPS)"
echo "  3. Build APK with API_URL=https://$DOMAIN/api"
echo "============================================"
