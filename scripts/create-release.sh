#!/bin/bash

# Script tạo release khi push lên main
# Sử dụng: ./scripts/create-release.sh [version] [name] [description]

set -e

# Lấy version từ arguments hoặc package.json
if [ -n "$1" ]; then
  VERSION="$1"
else
  if [ -f "package.json" ]; then
    VERSION=$(grep '"version"' package.json | head -1 | sed -E 's/.*"version": "([^"]+)".*/\1/')
  else
    VERSION="1.0.0"
  fi
fi

# Release name
RELEASE_NAME="${2:-Release v$VERSION}"

# Release description
RELEASE_DESC="${3:-Automatic release from main branch}"

# Check if .release-config.json exists
if [ -f ".release-config.json" ]; then
  echo "📋 Sử dụng cấu hình từ .release-config.json"
  RELEASE_NAME=$(jq -r '.name // "'$RELEASE_NAME'"' .release-config.json)
  RELEASE_DESC=$(jq -r '.description // "'$RELEASE_DESC'"' .release-config.json)
fi

TAG="v${VERSION}"

echo "🚀 Tạo Release"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📌 Tag:         $TAG"
echo "📝 Name:        $RELEASE_NAME"
echo "📄 Description: $RELEASE_DESC"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━"

# Kiểm tra git
if ! git rev-parse --verify HEAD > /dev/null; then
  echo "❌ Không phải git repository"
  exit 1
fi

# Tạo tag
if git rev-parse "$TAG" > /dev/null 2>&1; then
  echo "⚠️  Tag $TAG đã tồn tại, bỏ qua tạo tag"
else
  git tag -a "$TAG" -m "$RELEASE_NAME"
  echo "✅ Tag created: $TAG"
fi

# Push tag lên GitHub
git push origin "$TAG"
echo "✅ Tag pushed to origin"

# Sử dụng GitHub CLI (gh) nếu có
if command -v gh &> /dev/null; then
  echo ""
  echo "📦 Tạo release trên GitHub..."
  gh release create "$TAG" \
    --title "$RELEASE_NAME" \
    --notes "$RELEASE_DESC" \
    --draft=false \
    --prerelease=false
  echo "✅ Release created successfully!"
else
  echo ""
  echo "⚠️  GitHub CLI không được cài đặt"
  echo "📦 Vui lòng tạo release thủ công trên GitHub:"
  echo "   https://github.com/minjaedevs/LuongSon-TV-Release/releases/new?tag=$TAG"
fi

echo ""
echo "✨ Hoàn tất!"
