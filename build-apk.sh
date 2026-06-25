#!/bin/bash
# DuitKita — Build Release APK
# Usage: bash build-apk.sh https://api.yourdomain.com

set -e

API_URL="${1:-https://api.yourdomain.com}"

echo "Building APK with API_URL=$API_URL/api"

cd mobile

flutter clean
flutter pub get

flutter build apk \
  --release \
  --split-per-abi \
  --dart-define=API_BASE_URL="$API_URL/api"

echo ""
echo "APK files:"
ls -lh build/app/outputs/flutter-apk/*.apk
echo ""
echo "Install to device:"
echo "  adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
