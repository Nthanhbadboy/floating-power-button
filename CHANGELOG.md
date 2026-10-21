# Changelog

## Signing correction for AppGallery re-upload
- Split release outputs so AppGallery receives only the clearly named,
  signed **APK** (`...-APPGALLERY-SIGNED.apk`); the AAB is a separate
  Google Play artifact and must not be uploaded to AppGallery.
- Release artifacts now include `CERTIFICATE.txt` so the Signer #1 SHA-256
  fingerprint can be compared with the previously accepted APK before
  uploading. A mismatch means the original signing key must replace the
  current GitHub Secrets (see `docs/SIGNING_TROUBLESHOOTING.md`).

## 2.0.1 package-name correction
- Changed Android `applicationId` and `namespace` from
  `com.nguyenminhthanh.power_volume` to the existing AppGallery package
  **`com.floatingbutton.app`**.
- Moved all native Kotlin classes to `com.floatingbutton.app` and updated
  manifest component names and notification action prefixes.
- Release CI now extracts the built APK package name and fails unless it is
  exactly `com.floatingbutton.app`.

## Unreleased — signed release pipeline
- **Release signing configured:** `build.gradle.kts` reads
  `android/key.properties` (git-ignored); new **Build RELEASE (publish)**
  workflow decodes the keystore from GitHub Secrets
  (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
  `ANDROID_KEY_ALIAS` = physicsdraw, `ANDROID_KEY_PASSWORD`), builds
  signed **AAB + APK**, verifies the certificate is not Android Debug,
  and uploads `PowerVolume-v2.0.1-RELEASE-signed` (30 days).

## Unreleased — regression fixes + ads integration
- **i18n restored & extended:** header language selector now drives the
  whole UI in EN / VI / ZH / **ES** (dialogs, device guides, buttons,
  Privacy Policy) — all strings resolve through `AppStrings`, no hardcoded
  stripping.
- **Support Developer (Optional) restored** as `SupportDeveloperCard` with
  working **Payoneer** (copy-email dialog) and **VietQR** donate actions,
  keeping the exact "100% free … coffee via Payoneer or VietQR!" copy.
- **Ad banner placement fixed:** banner moved OUT of the scrollable
  ListView into `Scaffold.bottomNavigationBar` (`AdBannerHost`, fixed
  56dp) — permanently pinned at the bottom; content scrolls above it.
  The old in-list placeholder has been removed.
- **Dual ads:** Huawei **Petal Ads** native banner first on HMS devices
  (ads-lite SDK, platform view + load-failure events), **Google AdMob**
  fallback (google_mobile_ads), house strip if neither fills. TEST ad
  unit IDs — swap in `AppInfo` + manifest before release
  (see docs/ADS_INTEGRATION.md).
- Compliance retained: first-launch privacy pop-up, exact Developer/App
  names in the policy, Foreground Service OFF until manually enabled.


## 2.0.1 (build 201) — AppGallery compliance release
- **Privacy:** first-launch, non-dismissible Privacy Policy consent pop-up
  (`is_privacy_accepted` in shared_preferences); app is unusable until Agree.
- **Privacy:** Privacy Policy now in English, Vietnamese and **Simplified
  Chinese** (in-app + https://power-volume-privacy.vercel.app/privacy-policy.html),
  with exact Developer Name `NGUYEN MINH THANH`, App Name
  `Power & Volume - Lock Screen & Sound Control` and contact email.
- **Foreground Service:** OFF by default on fresh installs; explanation
  dialog with explicit **Enable** required before the service (and its
  persistent LOCK / VOLUME notification) starts. No auto-start on launch/boot.
- **Guide:** Device-Specific Background Guide expanded to Huawei/Honor,
  Xiaomi/Redmi/POCO, Samsung, OPPO/Realme and Vivo/iQOO with auto-detection
  ("Your Device" badge) and per-OEM settings shortcuts.
- UI refreshed to match the 2.0 design (Protected 24/7 banner, LOCK SCREEN /
  VOLUME PANEL cards, Permissions & Keep-Alive Settings, Support Developer).

## 2.0.0
- Previous AppGallery submission (returned with the 4 review issues above).
