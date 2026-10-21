# Changelog

## 2.0.1 (build 201) — AppGallery compliance release
- **Privacy:** first-launch, non-dismissible Privacy Policy consent pop-up
  (`is_privacy_accepted` in shared_preferences); app is unusable until Agree.
- **Privacy:** Privacy Policy now in English, Vietnamese and **Simplified
  Chinese** (in-app + https://nthanhbadboy.github.io/floating-power-button/privacy-policy.html),
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
