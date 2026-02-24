# Quick Release Guide

Quick process to release APK

---

## Prerequisites

- **Android Project**: `D:\sports_data\LuongSon_Android_TV`
- **Git Repo**: `D:\sports_data\LuongSon-TV-Release\LuongSon-TV-Release`

---

## 3 Release Steps

### **Step 1: Build APK** (Android Studio)
```
1. Open Android Studio
2. File → Project Structure → Modules → app → Flavors
   → Check versionName & versionCode

3. Build → Build Bundle(s) / APK(s) → Build APK(s)

4. Wait for build to complete
   Output: D:\sports_data\LuongSon_Android_TV\app\build\outputs\apk\release\app-release.apk
```

### **Step 2: Copy APK to Git Repo** (PowerShell)
```powershell
# Open PowerShell at: D:\sports_data\LuongSon-TV-Release\LuongSon-TV-Release

.\scripts\prepare-release.ps1 -Message "Release v1.0.0"

# Output:
# APK copied: releases/sports-tv-v1.0.0.apk
# APK staged for commit
```

### **Step 3: Commit & Push** (Git)
```bash
git commit -m "Release v1.0.0"
git push origin main
```

---

## Results

GitHub Actions automatically:
- Creates release on GitHub (tag: `v1.0.0`)
- Uploads APK as asset
- Creates release notes from `.release-config.json`
- Marks as latest release (`make_latest: true`)

**View release:** https://github.com/minjaedevs/LuongSon-TV-Release/releases

---

## Download Flow (for Android TV)

User downloads via short URL with automatic redirects:

```
Bit.ly (lstv-9)
  ↓ redirect
https://minjaedevs.github.io/LuongSon-TV-Release/download.html
  ↓ redirect (docs/download.html)
https://github.com/minjaedevs/LuongSon-TV-Release/releases/latest/download/sports-tv-v1.0.0.apk
  ↓ GitHub auto-redirect to latest
APK tải xuống thành công
```

**Key Benefits:**
- Short URL: `https://bit.ly/lstv-9` (dễ nhập trên Android TV)
- Always points to latest: `/latest/` endpoint
- Link không bao giờ thay đổi
- Professional landing page: GitHub Pages (docs/)

---

## Customization

Edit `.release-config.json`:
```json
{
  "name": "Sports TV Release v1.0.0",
  "description": "Features\n- Live sports\n- HD video",
  "draft": false,
  "prerelease": false
}
```

---

## Troubleshooting

### "APK not found"
```
- Build APK from Android Studio first
- Check: D:\sports_data\LuongSon_Android_TV\app\build\outputs\apk\release\app-release.apk
```

### GitHub Actions doesn't upload APK
```
- Verify file `releases/sports-tv-*.apk` exists
- View Actions log: https://github.com/minjaedevs/LuongSon-TV-Release/actions
```

### Version is incorrect
```
- Check versionName in app/build.gradle (Android Project)
- Script automatically extracts from build.gradle
```

---

## Files

| File | Purpose |
|------|---------|
| `.github/workflows/release.yml` | Auto release workflow |
| `.release-config.json` | Release configuration |
| `scripts/prepare-release.ps1` | Copy APK (Windows) |
| `scripts/prepare-release.sh` | Copy APK (Linux/Mac) |
| `releases/` | Folder to store APK |

---

## Notes

- Script automatically **copies APK** from Android Project to Git Repo
- Script automatically **extracts version** from `build.gradle`
- APK is **committed** to Git (in `releases/` folder)
- GitHub Actions **uploads** APK as release asset
- Release notes from `.release-config.json`

---

**Ready?**

```powershell
# At git repo directory:
.\scripts\prepare-release.ps1 -Message "Your Release Message"
```
