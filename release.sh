#!/bin/bash
# DuitKita — Release orchestrator (run from project root on dev machine)
#
# Builds the release APK, uploads it as a GitHub release, flips app_settings
# on the server, then tags + pushes git.
#
# Requires: gh CLI authenticated, flutter, ssh access to server (for settings flip).
#
# Usage:
#   bash release.sh                  # release current pubspec version
#   bash release.sh 1.0.2            # bump pubspec to 1.0.2 first, then release
#
# Env (override in ~/.duitkita-release.env or shell):
#   SSH_HOST   — e.g. root@duitkita.ikhsandi.web.id  (or a Host alias from ~/.ssh/config)
#   APP_DIR    — server path to project     (default: /var/www/duitkita)
#   API_URL    — public base URL, no /api   (default: https://duitkita.ikhsandi.web.id)
#   REPO       — GitHub repo slug           (default: Ikhsandi-Ramadani/duitkita)
#   ABI        — target Android ABI         (default: arm64-v8a)
#   SKIP_FLIP=1 — skip server settings update (only build + release + tag)

set -euo pipefail

# ─── Load config ────────────────────────────────────────────────────────────
[ -f ~/.duitkita-release.env ] && source ~/.duitkita-release.env

SSH_HOST="${SSH_HOST:-root@duitkita.ikhsandi.web.id}"
APP_DIR="${APP_DIR:-/var/www/duitkita}"
API_URL="${API_URL:-https://duitkita.ikhsandi.web.id}"
REPO="${REPO:-Ikhsandi-Ramadani/duitkita}"
ABI="${ABI:-arm64-v8a}"

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
  sed "s/^version: .*/version: ${NEW_VERSION}+${NEW_BUILD}/" mobile/pubspec.yaml > /tmp/_pubspec.yaml
  mv /tmp/_pubspec.yaml mobile/pubspec.yaml
  grep '^version:' mobile/pubspec.yaml
  VERSION="$NEW_VERSION"; BUILD="$NEW_BUILD"
fi

echo ""
warn "About to release version=${VERSION} build=${BUILD}"
warn "Repo: ${REPO}  API: ${API_URL}  ABI: ${ABI}"
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

# ─── 3. GitHub release ──────────────────────────────────────────────────────
step "Create GitHub release v${VERSION}+${BUILD} (upload ${ABI} APK)"
ASSET_NAME="app-${ABI}-release.apk"
# delete existing release with same tag if rerun
gh release delete "v${VERSION}+${BUILD}" --repo "$REPO" --yes 2>/dev/null || true
gh release create "v${VERSION}+${BUILD}" "$APK#$ASSET_NAME" \
  --repo "$REPO" \
  --title "DuitKita ${VERSION} (${BUILD})" \
  --notes "Versi ${VERSION}+${BUILD}

- Download asset: \`$ASSET_NAME\`"
ok "Release published: https://github.com/${REPO}/releases/tag/v${VERSION}%2B${BUILD}"

# ─── 4. Flip app_settings on server ─────────────────────────────────────────
DL_URL="https://github.com/${REPO}/releases/latest/download/app-${ABI}-release.apk"
if [ "${SKIP_FLIP:-0}" = "1" ]; then
  warn "SKIP_FLIP=1 — server settings not updated"
else
  step "Update app_settings → version=${VERSION} build=${BUILD}"
  ssh "$SSH_HOST" bash -s <<EOF
set -e
cd ${APP_DIR}/backend
php artisan tinker --execute="
  App\\\Models\\\AppSetting::set('app_version', '${VERSION}');
  App\\\Models\\\AppSetting::set('app_build', (string) ${BUILD});
  App\\\Models\\\AppSetting::set('app_download_url', '${DL_URL}');
"
php artisan config:clear
EOF
  ok "app_settings updated (download_url → ${DL_URL})"
fi

# ─── 5. Verify ───────────────────────────────────────────────────────────────
step "Verify /api/version"
REMOTE_JSON="$(curl -fsS "${API_URL}/api/version" 2>/dev/null || echo 'FAILED')"
echo "  $REMOTE_JSON"
if echo "$REMOTE_JSON" | grep -q "\"build\":${BUILD}"; then
  ok "Remote build ${BUILD} live"
else
  warn "Remote build mismatch or API unreachable — verify server manually"
fi

# ─── 6. Git tag + push ──────────────────────────────────────────────────────
step "Git tag + push"
git add mobile/pubspec.yaml
git commit -m "chore(mobile): release ${VERSION}+${BUILD}" 2>/dev/null || warn "nothing to commit"
git tag -f "v${VERSION}+${BUILD}"
git push origin main
git push origin "v${VERSION}+${BUILD}" 2>/dev/null || true
ok "Tagged v${VERSION}+${BUILD}"

echo ""
ok "Release ${VERSION}+${BUILD} complete"
echo "  GitHub release: https://github.com/${REPO}/releases/tag/v${VERSION}%2B${BUILD}"
echo "  APK download:    ${DL_URL}"
echo "  Update check:    ${API_URL}/api/version → build ${BUILD}"
