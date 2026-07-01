#!/bin/bash
# DuitKita — Release orchestrator (run from project root on dev machine)
#
# Builds the release APK, uploads it to the server's storage/app/releases/,
# flips app_settings to the new version/build, then tags + pushes git.
#
# Usage:
#   bash release.sh                      # release current pubspec version
#   bash release.sh 1.0.2                # bump pubspec to 1.0.2 first, then release
#
# Env (override in ~/.duitkita-release.env or shell):
#   SSH_HOST   — e.g. root@duitkita.ikhsandi.web.id  (or a Host alias from ~/.ssh/config)
#   APP_DIR    — server path to project     (default: /var/www/duitkita)
#   API_URL    — public base URL, no /api   (default: https://duitkita.ikhsandi.web.id)
#   SKIP_UPLOAD=1 — skip scp (APK already on server), only flip settings

set -euo pipefail

# ─── Load config ────────────────────────────────────────────────────────────
[ -f ~/.duitkita-release.env ] && source ~/.duitkita-release.env

SSH_HOST="${SSH_HOST:-root@duitkita.ikhsandi.web.id}"
APP_DIR="${APP_DIR:-/var/www/duitkita}"
API_URL="${API_URL:-https://duitkita.ikhsandi.web.id}"
ABI="${ABI:-arm64-v8a}"   # target Android ABI

# ─── Helpers ────────────────────────────────────────────────────────────────
cya='\033[0;36m'; grn='\033[0;32m'; ylw='\033[0;33m'; rst='\033[0m'
step(){ echo -e "${cya}▶ $1${rst}"; }
ok(){   echo -e "${grn}✓ $1${rst}"; }
warn(){ echo -e "${ylw}! $1${rst}"; }

# ─── 1. Determine version + build ───────────────────────────────────────────
step "Read version from mobile/pubspec.yaml"
VERSION="$(grep -E '^version:' mobile/pubspec.yaml | head -1 | cut -d' ' -f2 | cut -d'+' -f1)"
BUILD="$(grep -E '^version:' mobile/pubspec.yaml | head -1 | cut -d' ' -f2 | cut -d'+' -f2)"
echo "  current: $VERSION+$BUILD"

if [ -n "${1:-}" ]; then
  NEW_VERSION="$1"
  NEW_BUILD="${NEW_BUILD:-$((BUILD+1))}"
  step "Bump pubspec → ${NEW_VERSION}+${NEW_BUILD}"
  # cross-platform sed: write a temp file
  sed "s/^version: .*/version: ${NEW_VERSION}+${NEW_BUILD}/" mobile/pubspec.yaml > /tmp/_pubspec.yaml
  mv /tmp/_pubspec.yaml mobile/pubspec.yaml
  grep '^version:' mobile/pubspec.yaml
  VERSION="$NEW_VERSION"; BUILD="$NEW_BUILD"
fi

echo ""
warn "About to release version=${VERSION} build=${BUILD}"
warn "Server: ${SSH_HOST}  API: ${API_URL}"
warn "APK ABI: ${ABI}"
read -rp "Proceed? [y/N] " confirm
[ "$confirm" = "y" ] || { echo "Aborted."; exit 1; }

# ─── 2. Build APK ───────────────────────────────────────────────────────────
step "Build release APK (API_BASE_URL=${API_URL}/api)"
cd mobile
flutter clean
flutter pub get
flutter build apk --release --split-per-abi \
  --dart-define=API_BASE_URL="${API_URL}/api"
cd ..

APK="mobile/build/app/outputs/flutter-apk/app-${ABI}-release.apk"
[ -f "$APK" ] || { echo "APK not found at $APK"; exit 1; }
SIZE="$(ls -lh "$APK" | cut -d' ' -f5)"
ok "Built $APK ($SIZE)"

# ─── 3. Upload to server ────────────────────────────────────────────────────
REMOTE_DIR="${APP_DIR}/backend/storage/app/releases"
REMOTE_APK="${REMOTE_DIR}/duitkita-${VERSION}.apk"
REMOTE_LATEST="${REMOTE_DIR}/duitkita-latest.apk"

if [ "${SKIP_UPLOAD:-0}" = "1" ]; then
  warn "SKIP_UPLOAD=1 — skipping scp"
else
  step "Upload to ${SSH_HOST}:${REMOTE_DIR}/"
  ssh "$SSH_HOST" "mkdir -p '${REMOTE_DIR}' && chown -R www-data:www-data '${REMOTE_DIR}'"
  scp "$APK" "${SSH_HOST}:${REMOTE_APK}"
  ssh "$SSH_HOST" "cp '${REMOTE_APK}' '${REMOTE_LATEST}' && chown www-data:www-data '${REMOTE_APK}' '${REMOTE_LATEST}'"
  ok "Uploaded duitkita-${VERSION}.apk + duitkita-latest.apk"
fi

# ─── 4. Flip app_settings on server ─────────────────────────────────────────
step "Update app_settings → version=${VERSION} build=${BUILD}"
ssh "$SSH_HOST" bash -s <<EOF
set -e
cd ${APP_DIR}/backend
php artisan tinker --execute="
  App\\\Models\\\AppSetting::set('app_version', '${VERSION}');
  App\\\Models\\\AppSetting::set('app_build', (string) ${BUILD});
  App\\\Models\\\AppSetting::set('app_download_url', '${API_URL}/api/download/apk');
"
php artisan config:clear
EOF
ok "app_settings updated"

# ─── 5. Verify ───────────────────────────────────────────────────────────────
step "Verify /api/version"
REMOTE_JSON="$(curl -fsS "${API_URL}/api/version")"
echo "  $REMOTE_JSON"
echo "$REMOTE_JSON" | grep -q "\"version\":\"${VERSION}\"" && ok "Remote version matches" || warn "Version mismatch — check server"

# ─── 6. Git tag + push ──────────────────────────────────────────────────────
step "Git tag v${VERSION}+${BUILD}"
git add mobile/pubspec.yaml
git commit -m "chore(mobile): release ${VERSION}+${BUILD}" || warn "nothing to commit"
git tag -f "v${VERSION}+${BUILD}"
git push origin main
git push origin "v${VERSION}+${BUILD}" || true
ok "Tagged v${VERSION}+${BUILD}"

echo ""
ok "Release ${VERSION}+${BUILD} complete"
echo "  APK: ${API_URL}/api/download/apk"
echo "  App update flow: /api/version → build ${BUILD} > installed → prompt"
