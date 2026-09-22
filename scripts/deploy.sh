#!/bin/bash
# ==================== DUITKITA — DEPLOY ====================
# Pemakaian: ./scripts/deploy.sh [--skip-pull]
#
# Catatan desain:
# - Build dulu, baru ganti container. Kalau build gagal, container lama tetap
#   melayani sehingga aplikasi tidak mati.
# - JANGAN memakai `docker-compose down`: itu mematikan seluruh project
#   termasuk MySQL, padahal aplikasi lain di server ini berbagi Caddy.
# - Folder data/mysql hanya diperbaiki kalau owner-nya memang salah.
#   Di dalam container, MySQL berjalan sebagai uid 999.

set -euo pipefail

APP_DIR="/home/ubuntu/apps/duitkita"
BRANCH="main"
NETWORK="duitkita_network"
SKIP_PULL=false

[[ "${1:-}" == "--skip-pull" ]] && SKIP_PULL=true

cd "$APP_DIR"

# ---------- Kunci deploy: cegah dua deploy berjalan bersamaan ----------
LOCK_FILE="/tmp/duitkita-deploy.lock"
exec 9>"$LOCK_FILE"
if ! flock -w 900 9; then
  echo "❌ Deploy lain masih berjalan (>15 menit menunggu). Dibatalkan."
  exit 1
fi

echo "📥 [1/6] Ambil kode terbaru..."
if [[ "$SKIP_PULL" == false ]]; then
  git fetch origin "$BRANCH"
  git reset --hard "origin/$BRANCH"
else
  echo "   (dilewati)"
fi

echo "📁 [2/6] Siapkan direktori persistent..."
mkdir -p data/mysql data/storage

# MySQL di dalam container berjalan sebagai uid 999.
if [[ -d data/mysql && "$(stat -c %u data/mysql)" != "999" ]]; then
  echo "   memperbaiki owner data/mysql (uid 999)..."
  sudo chown -R 999:999 data/mysql
fi

echo "🔐 [3/6] Periksa berkas .env..."
if [[ ! -f .env ]]; then
  echo "❌ .env tidak ada. Deploy dibatalkan supaya tidak menjalankan app tanpa konfigurasi."
  exit 1
fi

echo "🏗️  [4/6] Build image (container lama tetap jalan)..."
sudo docker-compose build

echo "🚀 [5/6] Nyalakan container..."
# MySQL dinyalakan terpisah, lalu container app dihapus dulu. Urutan ini
# menghindari bug 'KeyError: ContainerConfig' pada docker-compose v1.29 yang
# muncul saat compose mencoba membuat ulang container yang sudah ada.
sudo docker-compose up -d --no-build --no-deps mysql
# Bersihkan sisa container app, termasuk sisa deploy gagal yang namanya
# berawalan hash (contoh: "0020a6a47c58_duitkita-app") — kalau tidak, compose
# tetap mencoba membuat ulang dan bug ContainerConfig muncul lagi.
sudo docker ps -a --filter "name=duitkita-app" -q | xargs -r sudo docker rm -f >/dev/null 2>&1 || true
sudo docker-compose up -d --no-build --no-deps app

echo "⏳      menunggu aplikasi siap..."
for i in $(seq 1 40); do
  if sudo docker exec duitkita-app curl -fsS -m 5 http://localhost/up >/dev/null 2>&1; then
    echo "   aplikasi merespons."
    break
  fi
  if [[ "$i" == "40" ]]; then
    echo "❌ Aplikasi tidak merespons setelah 200 detik. Cek: sudo docker logs duitkita-app"
    exit 1
  fi
  sleep 5
done

echo "🗄️  [6/6] Jalankan migrasi database..."
sudo docker exec duitkita-app php artisan migrate --force

echo
echo "✅ Deploy selesai."
sudo docker-compose ps
