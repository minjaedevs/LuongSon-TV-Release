#!/usr/bin/env powershell

# Script chuan bi release: copy APK va push (Windows)
# Su dung: .\scripts\prepare-release.ps1 -Message "Your message"

param(
    [string]$Message = ""
)

# Path toi Android project
$ANDROID_PROJECT = "D:\sports_data\LuongSon_Android_TV"
$APK_SOURCE = "$ANDROID_PROJECT\app\build\outputs\apk\release\app-release.apk"
$RELEASE_DIR = "releases"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"

# Tao thu muc releases neu chua co
if (-not (Test-Path $RELEASE_DIR)) {
    New-Item -ItemType Directory -Path $RELEASE_DIR | Out-Null
}

# Kiem tra APK ton tai
if (-not (Test-Path $APK_SOURCE)) {
    Write-Host "Error: APK not found: $APK_SOURCE" -ForegroundColor Red
    Write-Host "Please build APK from Android Studio first:" -ForegroundColor Yellow
    Write-Host "   Path: $ANDROID_PROJECT" -ForegroundColor Yellow
    exit 1
}

# Lay version tu build.gradle (tu Android project)
$buildGradlePath = "$ANDROID_PROJECT\app\build.gradle"
if (Test-Path $buildGradlePath) {
    $buildGradle = Get-Content $buildGradlePath -Raw
    $versionMatch = $buildGradle | Select-String -Pattern 'versionName\s*=\s*"([^"]+)"'
    if ($versionMatch) {
        $VERSION = $versionMatch.Matches[0].Groups[1].Value
    } else {
        $VERSION = "1.0.0"
    }

    # Lay version code
    $versionCodeMatch = $buildGradle | Select-String -Pattern 'versionCode\s*=\s*([0-9]+)'
    if ($versionCodeMatch) {
        $VERSION_CODE = $versionCodeMatch.Matches[0].Groups[1].Value
    } else {
        $VERSION_CODE = "1"
    }
} else {
    $VERSION = "1.0.0"
    $VERSION_CODE = "1"
}

# Cap nhat .release-config.json voi version moi
$releaseConfigPath = ".release-config.json"
if (Test-Path $releaseConfigPath) {
    try {
        $configJson = Get-Content $releaseConfigPath -Raw | ConvertFrom-Json
        $configJson.name = "LuongSon TV Release v$VERSION"
        $configJson | ConvertTo-Json | Set-Content $releaseConfigPath -Encoding UTF8
        Write-Host "Updated .release-config.json with version v$VERSION" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not update .release-config.json: $_" -ForegroundColor Yellow
    }
}

# Copy APK (fixed filename - khong thay doi)
$APK_DEST = "$RELEASE_DIR/sports-tv.apk"
Copy-Item -Path $APK_SOURCE -Destination $APK_DEST -Force
Write-Host "APK copied: $APK_DEST" -ForegroundColor Green

# Thong tin release
Write-Host ""
Write-Host "Release Info" -ForegroundColor Cyan
Write-Host "================================"
Write-Host "Version:      $VERSION (Code: $VERSION_CODE)"
Write-Host "APK:          $APK_DEST"
$fileSize = (Get-Item $APK_DEST).Length / 1MB
Write-Host "Size:         $([math]::Round($fileSize, 2)) MB"
Write-Host "================================"

# Stage changes
git add $APK_DEST
Write-Host "APK staged for commit" -ForegroundColor Green

# Commit message
if (-not $Message) {
    $Message = "Release v$VERSION (Code: $VERSION_CODE)"
}

Write-Host ""
Write-Host "Commit message: $Message" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "   git commit -m `"$Message`""
Write-Host "   git push origin main"
Write-Host ""
Write-Host "GitHub Actions will automatically:" -ForegroundColor Green
Write-Host "   - Create release on GitHub"
Write-Host "   - Upload APK as asset"
Write-Host "   - Create tag v$VERSION"
