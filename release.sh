#!/bin/bash
# DuitKita — Release orchestrator (run from project root on dev machine)
#
# Builds the release APK, uploads it as a GitHub release, tags + pushes git.
# Server app_settings (version/build) updated manually via admin web form
# after the script finishes — see the final-step reminder at the end.
#
# Requires: gh CLI authenticated, flutter.
#
# Usage:
#   bash release.sh                  # release current pubspec version
#   bash release.sh 1.0.2            # bump pubspec to 1.0.2 first, then release
#
# Env (override in ~/.duitkita-release.env or shell):
#   API_URL    — public base URL, no /api   (default: https://duitkita.ikhsandi.web.id)
#   REPO       — GitHub repo slug           (default: Ikhsandi-Ramadani/duitkita)
#   ABI        — target Android ABI         (default: arm64-v8a)

set -euo pipefail

# ─── Load config ────────────────────────────────────────────────────────────
[ -f ~/.duitkita-release.env ] && source ~/.duitkita-release.env

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

# ─── 4. Git tag + push ──────────────────────────────────────────────────────
step "Git tag + push"
git add mobile/pubspec.yaml
git commit -m "chore(mobile): release ${VERSION}+${BUILD}" 2>/dev/null || warn "nothing to commit"
git tag -f "v${VERSION}+${BUILD}"
git push origin main
git push origin "v${VERSION}+${BUILD}" 2>/dev/null || true
ok "Tagged v${VERSION}+${BUILD}"

echo ""
ok "Release ${VERSION}+${BUILD} complete"
echo ""
echo "  GitHub release: https://github.com/${REPO}/releases/tag/v${VERSION}%2B${BUILD}"
echo "  APK download:    https://github.com/${REPO}/releases/latest/download/app-${ABI}-release.apk"
echo ""
warn "FINAL STEP (manual, ~30s):"
echo "  Buka ${API_URL}/admin/settings/app-version"
echo "  Isi: app_version=${VERSION}  app_build=${BUILD}"
echo "  app_download_url=https://github.com/${REPO}/releases/latest/download/app-${ABI}-release.apk"
echo "  Save. Lalu verify: curl ${API_URL}/api/version"
