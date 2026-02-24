#!/bin/bash

# Script chuẩn bị release: copy APK từ Android project và push
# Sử dụng: ./scripts/prepare-release.sh [message]

set -e

# Path tới Android project
ANDROID_PROJECT="D:/sports_data/LuongSon_Android_TV"
APK_SOURCE="$ANDROID_PROJECT/app/build/outputs/apk/release/app-release.apk"
RELEASE_DIR="releases"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Tạo thư mục releases nếu chưa có
mkdir -p "$RELEASE_DIR"

# Kiểm tra APK tồn tại
if [ ! -f "$APK_SOURCE" ]; then
  echo "Error: APK not found: $APK_SOURCE"
  echo "Please build APK first: gradlew build"
  exit 1
fi

# Lấy version từ build.gradle (từ Android project)
if [ -f "$ANDROID_PROJECT/app/build.gradle" ]; then
  VERSION=$(grep -oP 'versionName\s*=\s*"\K[^"]+' "$ANDROID_PROJECT/app/build.gradle" || echo "1.0.0")
else
  VERSION="1.0.0"
fi

# Cập nhật .release-config.json với version mới
if [ -f ".release-config.json" ]; then
  if command -v jq &> /dev/null; then
    jq ".name = \"LuongSon TV Release v${VERSION}\"" ".release-config.json" > ".release-config.json.tmp"
    mv ".release-config.json.tmp" ".release-config.json"
    echo "Updated .release-config.json with version v${VERSION}"
  else
    echo "Warning: jq not installed, skipping .release-config.json update"
  fi
fi

# Copy APK (fixed filename - không thay đổi)
APK_DEST="$RELEASE_DIR/sports-tv.apk"
cp "$APK_SOURCE" "$APK_DEST"
echo "APK copied: $APK_DEST"

# Lấy version code
if [ -f "$ANDROID_PROJECT/app/build.gradle" ]; then
  VERSION_CODE=$(grep -oP 'versionCode\s*=\s*\K[0-9]+' "$ANDROID_PROJECT/app/build.gradle" || echo "1")
else
  VERSION_CODE="1"
fi

echo ""
echo "Release Info"
echo "================================"
echo "Version:      $VERSION (Code: $VERSION_CODE)"
echo "APK:          $APK_DEST"
echo "Size:         $(du -h "$APK_DEST" | cut -f1)"
echo "================================"

# Stage changes
git add "$APK_DEST"
echo "APK staged for commit"

# Commit message
COMMIT_MSG="${1:-Release v${VERSION}}"

# Display status
echo ""
echo "Commit message: $COMMIT_MSG"
echo ""
echo "Next steps:"
echo "   git commit -m \"$COMMIT_MSG\""
echo "   git push origin main"
echo ""
echo "GitHub Actions will automatically:"
echo "   - Create release on GitHub"
echo "   - Upload APK as asset"
echo "   - Create tag v${VERSION}"
