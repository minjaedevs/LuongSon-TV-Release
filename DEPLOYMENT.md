# Deployment & Release Guide

Hướng dẫn tự động deploy APK lên releases khi push lên main branch.

**Project:** Sports TV (Android App)
**APK Path:** `app/build/outputs/apk/release/app-release.apk`
**Auto Upload:** Yes

## Quick Start (APK Release)

**Điều kiện:**
- Android Project: `D:\sports_data\LuongSon_Android_TV`
- Git Repo: `D:\sports_data\LuongSon-TV-Release\LuongSon-TV-Release`

```bash
# 1. Build APK từ Android Studio (LuongSon_Android_TV)
#    Build -> Build Bundle(s) / APK(s) -> Build APK(s)
#    Output: D:\sports_data\LuongSon_Android_TV\app\build\outputs\apk\release\app-release.apk

# 2. Chuẩn bị release (copy APK từ Android Project vào Git Repo)
# Windows PowerShell (chạy từ git repo):
.\scripts\prepare-release.ps1 -Message "Release v1.0.0"

# Linux/Mac:
./scripts/prepare-release.sh "Release v1.0.0"

# 3. Commit & Push
git commit -m "Release v1.0.0"
git push origin main

# 4. GitHub Actions automatic:
#    - Tạo release trên GitHub
#    - Upload APK làm asset
#    - Tạo tag và release notes
```

---

## Options

### GitHub Actions (Automatic - Recommended)

**Cách hoạt động:**
- Mỗi khi bạn push lên `main` branch, GitHub Actions sẽ tự động chạy
- Tạo release với version từ `package.json` hoặc cấu hình từ `.release-config.json`
- Release sẽ có tên, mô tả, và các tuỳ chọn được cấu hình

**File workflow:** `.github/workflows/release.yml`

**Features:**
- Auto upload APK (`app/build/outputs/apk/release/app-release.apk`)
- Extract version from `build.gradle`
- Create release with tag `v{version}-{build_number}`
- Upload APK as release asset

**Cấu hình:** Chỉnh sửa `.release-config.json`

```json
{
  "name": "Release v1.0.0",
  "description": "Mô tả release của bạn",
  "draft": false,
  "prerelease": false,
  "changelog": true
}
```

**Các biến:**
- `name`: Tên release
- `description`: Mô tả chi tiết (hỗ trợ Markdown)
- `draft`: `true` để lưu dưới dạng bản nháp
- `prerelease`: `true` nếu là bản pre-release

---

### Bash Script (Manual creation)

**Cách sử dụng:**

```bash
# Tạo release với version mặc định từ package.json
./scripts/create-release.sh

# Tạo release với version tùy chỉnh
./scripts/create-release.sh 2.0.0

# Tạo release với tên và mô tả tùy chỉnh
./scripts/create-release.sh 2.0.0 "Custom Name" "Custom Description"
```

**Requirements:**
- Git đã cài đặt
- Optional: `jq` (để parse JSON)
- Optional: GitHub CLI (`gh`) - để tạo release tự động

**Cài đặt GitHub CLI (Windows):**
```bash
# Dùng winget
winget install GitHub.cli

# Hoặc dùng Chocolatey
choco install gh
```

**Xác thực GitHub CLI:**
```bash
gh auth login
```

---

### PowerShell Script (Windows)

Tạo file `scripts/create-release.ps1`:

```powershell
param(
    [string]$Version = "1.0.0",
    [string]$Name = "Release v$Version",
    [string]$Description = "Automatic release"
)

$tag = "v$Version"

Write-Host "🚀 Creating Release..." -ForegroundColor Green
Write-Host "Tag: $tag"
Write-Host "Name: $Name"

git tag -a $tag -m $Name
git push origin $tag

gh release create $tag --title $Name --notes $Description

Write-Host "✅ Release created!" -ForegroundColor Green
```

**Sử dụng:**
```powershell
.\scripts\create-release.ps1 -Version "1.0.0" -Name "My Release" -Description "Release notes"
```

---

## Configuration details

### package.json (nếu có)

```json
{
  "name": "LuongSon-TV-Release",
  "version": "1.0.0",
  "description": "Your project description"
}
```

Workflow sẽ tự động lấy version từ `package.json`.

### .release-config.json

```json
{
  "name": "Release v1.0.0",
  "description": "## 🎉 Features\n- New feature 1\n- New feature 2\n\n## 🐛 Fixes\n- Bug fix 1",
  "draft": false,
  "prerelease": false,
  "changelog": true,
  "assets": ["dist/**/*"],
  "tagPrefix": "v"
}
```

---

## Workflows

### Workflow A: APK Release (Automatic - Recommended)
```
1. Build APK: ./gradlew build
2. Run: ./scripts/prepare-release.sh "Release v1.0.0"
3. git commit -m "Release v1.0.0"
4. git push origin main
5. GitHub Actions automatic:
   - Create release on GitHub
   - Extract version from build.gradle
   - Upload APK as asset
   - Create tag v{version}-{build_number}
```

**GitHub Actions Flow:**
```yaml
On: push to main
├── Get version from build.gradle
├── Get config from .release-config.json
├── Create release on GitHub
└── Upload APK as asset
```

### Release Assets
After push, GitHub Release will have:
```
Release v1.0.0
- sports-tv-v1.0.0.apk (11.9 MB) [Auto uploaded]
- Release notes (from .release-config.json)
```

### Workflow B: Manual creation (Advanced)
```
1. Build APK: ./gradlew build
2. Run: ./scripts/create-release.sh 1.0.0 "My Release" "Notes"
3. Release created successfully
```

---

## Commit & Push regularly

Để GitHub Actions hoạt động, bạn cần:

1. **Workflow file exists:** `.github/workflows/release.yml`
2. **Push lên main branch:**
   ```bash
   git push origin main
   ```
3. **Kiểm tra Actions trên GitHub:**
   - Vào: https://github.com/minjaedevs/LuongSon-TV-Release/actions
   - Xem log để debug nếu có lỗi

---

## Troubleshooting

### Error: "Tag already exists"
```bash
# Xoá tag cục bộ
git tag -d v1.0.0

# Xoá tag trên remote
git push origin :refs/tags/v1.0.0
```

### GitHub Actions không chạy
- Kiểm tra workflows tab trên GitHub
- Đảm bảo file `.github/workflows/release.yml` tồn tại
- Kiểm tra branch trigger (`on.push.branches`)

### gh command not found
- Cài đặt GitHub CLI: https://cli.github.com
- Xác thực: `gh auth login`

---

## Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [GitHub CLI Docs](https://cli.github.com/)
- [Semantic Versioning](https://semver.org/)
- [Release Best Practices](https://docs.github.com/en/repositories/releasing-projects-on-github/best-practices-for-creating-a-release)

---

## Tips

- **Semantic Versioning:** `MAJOR.MINOR.PATCH` (e.g., `1.2.3`)
- **Changelog format:** Dùng Markdown để format
- **Pre-releases:** Set `prerelease: true` cho RC/Beta versions
- **Draft releases:** Set `draft: true` để không công khai ngay

