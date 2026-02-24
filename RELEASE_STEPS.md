# Release Steps

Complete guide to release APK and deploy to GitHub.

## Project Paths

- Android Project: `D:\sports_data\LuongSon_Android_TV`
- Git Repo: `D:\sports_data\LuongSon-TV-Release\LuongSon-TV-Release`

## Step 1: Build APK

From Android Studio:

1. Open Android Studio
2. Go to Build -> Build Bundle(s) / APK(s) -> Build APK(s)
3. Wait for build to complete
4. Output: `D:\sports_data\LuongSon_Android_TV\app\build\outputs\apk\release\app-release.apk`

## Step 2: Copy APK to Git Repo

Open PowerShell in git repo directory and run:

```powershell
.\scripts\prepare-release.ps1 -Message "Release v1.0.0"
```

This script will:
- Check if APK exists in Android Project
- Extract version from build.gradle
- Copy APK to releases/ folder
- Rename to: `sports-tv-v{version}.apk`
- Stage APK for commit

Output example:
```
APK copied: releases/sports-tv-v1.0.0.apk
Version: 1.0.0 (Code: 1)
Size: 11.9 MB
APK staged for commit
```

## Step 3: Commit Changes

```bash
git commit -m "Release v1.0.0"
```

## Step 4: Push to GitHub

```bash
git push origin main
```

## Step 5: GitHub Actions Runs Automatically

When you push to main branch, GitHub Actions will:

1. Read version from build.gradle
2. Create release on GitHub
3. Upload APK as release asset
4. Add release notes from .release-config.json
5. Create tag v{version}-{build_number}

## Configuration Files

### .release-config.json

Edit to customize release:

```json
{
  "name": "Sports TV Release v1.0.0",
  "description": "Release description with installation instructions",
  "draft": false,
  "prerelease": false
}
```

Options:
- name: Release title
- description: Release notes (supports Markdown)
- draft: true to save as draft
- prerelease: true for beta/RC versions

### .gitignore

Prevents unnecessary files from being tracked:
- APK files (except in releases/ folder)
- Build directories
- IDE files

## File Structure

```
LuongSon-TV-Release/
├── .github/
│   └── workflows/
│       └── release.yml              (GitHub Actions workflow)
├── .release-config.json             (Release configuration)
├── .gitignore                       (Git ignore rules)
├── scripts/
│   ├── prepare-release.ps1          (Copy APK - Windows)
│   ├── prepare-release.sh           (Copy APK - Linux/Mac)
│   └── create-release.sh            (Manual release creation)
├── releases/                        (Folder for APK files)
├── DEPLOYMENT.md                    (Full documentation)
├── QUICK_RELEASE.md                 (Quick reference)
└── RELEASE_STEPS.md                 (This file)
```

## Workflow Summary

```
Build APK (Android Studio)
    |
    v
Run prepare-release.ps1
    |
    v
git commit
    |
    v
git push origin main
    |
    v
GitHub Actions runs:
  - Create release
  - Upload APK
  - Add notes
  - Create tag
    |
    v
Release available at:
https://github.com/minjaedevs/LuongSon-TV-Release/releases
```

## Version Management

Version is extracted from Android Project's build.gradle:

File: `D:\sports_data\LuongSon_Android_TV\app\build.gradle`

```gradle
android {
    ...
    defaultConfig {
        versionCode 1
        versionName "1.0.0"
    }
}
```

Update version here before building APK.

## Troubleshooting

### APK not found
- Ensure APK is built in Android Studio
- Check path: `D:\sports_data\LuongSon_Android_TV\app\build\outputs\apk\release\app-release.apk`

### Script fails
- Run PowerShell as Administrator if permission denied
- Verify paths are correct
- Check build.gradle exists in Android Project

### GitHub Actions doesn't create release
- Check .github/workflows/release.yml exists
- Verify GITHUB_TOKEN has access
- View Actions tab on GitHub for logs

### APK not uploaded to release
- Verify releases/ folder contains APK
- Check file naming: `sports-tv-v*.apk`
- View GitHub Actions log for errors

## Next Steps

1. Build APK in Android Studio
2. Run: `.\scripts\prepare-release.ps1 -Message "Release v1.0.0"`
3. Run: `git commit -m "Release v1.0.0"`
4. Run: `git push origin main`
5. View release: https://github.com/minjaedevs/LuongSon-TV-Release/releases

## Notes

- APK is copied from Android Project to git repo
- Only commits APK, doesn't track entire build directory
- GitHub Actions runs automatically on push to main
- Release notes come from .release-config.json
- Version automatically extracted from build.gradle
