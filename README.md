# Power & Volume — Lock Screen & Sound Control

Floating / notification controls to **lock the screen instantly (0ms)** and
**show the system volume panel** without wearing out physical buttons.

- **Developer:** NGUYEN MINH THANH
- **Contact:** alphaplusthanh82@gmail.com
- **Privacy Policy:** https://power-volume-privacy.vercel.app/privacy-policy.html
  (English · Tiếng Việt · 简体中文） — source in [`docs/privacy-policy.html`](docs/privacy-policy.html)

## Version 2.0.1 — Huawei AppGallery fixes

| # | Review issue | Fix |
|---|---|---|
| 1 | No Privacy Policy pop-up on first launch | Non-dismissible consent gate (`is_privacy_accepted`), Agree required — `lib/widgets/privacy_consent_gate.dart` |
| 2 | No Chinese Privacy Policy (Chinese mainland selected) | Full Simplified Chinese policy online + in-app 中文 tab — `lib/data/privacy_policy_content.dart`, `docs/privacy-policy.html#zh` |
| 3 | App/Developer name missing in Privacy Policy | Exact `Power & Volume - Lock Screen & Sound Control` / `NGUYEN MINH THANH` single-sourced from `lib/constants/app_info.dart` |
| 4 | Foreground Service started without consent | Switch **OFF by default**, explanation dialog + explicit **Enable** before `startForegroundService()`; no launch/boot auto-start |

📚 **All documentation lives in [`docs/`](docs/README.md)** — AppGallery fix
details, the 3-language Privacy Policy, the Vietnamese submission guide
([`docs/HUONG_DAN_NOP_APPGALLERY.md`](docs/HUONG_DAN_NOP_APPGALLERY.md)),
the test-APK install guide ([`docs/CAI_DAT_BAN_TEST.md`](docs/CAI_DAT_BAN_TEST.md))
and reference screenshots ([`docs/screenshots/`](docs/screenshots/)).

Plus the **Device-Specific Background Guide** for Huawei/Honor,
Xiaomi/Redmi/POCO, Samsung, OPPO/Realme and Vivo/iQOO (auto-detected,
"Your Device" badge). Full details & submission checklist:
[`docs/APPGALLERY_FIXES_2.0.1.md`](docs/APPGALLERY_FIXES_2.0.1.md) ·
Reviewer notes to paste into AppGallery Connect:
[`docs/REVIEWER_NOTES_2.0.1.md`](docs/REVIEWER_NOTES_2.0.1.md)

## Project layout

```
lib/
  main.dart                        loads prefs, gates on privacy consent
  constants/app_info.dart          app/developer identity (single source)
  services/preferences_service.dart  is_privacy_accepted, keep-alive consent
  services/native_bridge.dart      MethodChannel "power_volume/native"
  widgets/privacy_consent_gate.dart  first-launch pop-up (issue #1)
  widgets/foreground_service_dialog.dart  Enable/Cancel dialog (issue #4)
  screens/home_screen.dart         banner, LOCK/VOLUME, permissions, guide
  screens/privacy_policy_screen.dart  EN/VI/中文 policy + Terms
  data/manufacturer_guides.dart    5 OEM guides × EN/VI/中文
  data/privacy_policy_content.dart full policy text × 3 languages
android/…/                         MainActivity, PowerAccessibilityService
                                   (GLOBAL_ACTION_LOCK_SCREEN),
                                   KeepAliveForegroundService (user-enabled),
                                   PowerDeviceAdminReceiver (force-lock only)
docs/                              Privacy policy (Vercel source) + checklists
```

## Build & submit

> First time only: if `android/gradle/wrapper/gradle-wrapper.jar` is absent
> (it is generated, not committed), run `flutter create . --platforms=android`
> once and re-check `MainActivity.kt` / `AndroidManifest.xml` afterwards —
> or simply open the project in Android Studio, which generates the wrapper.

```bash
flutter pub get
flutter test            # consent-gate + default-OFF regression tests
flutter analyze

# Release: create android/key.properties + your keystore first (not committed)
flutter build appbundle --release   # or: flutter build apk --release
```

Before uploading to AppGallery Connect:
1. The Privacy Policy URL above is already live on Vercel — paste it into
   App information → Privacy Policy URL. IMPORTANT: redeploy the Vercel page
   with the content of `docs/privacy-policy.html` first (the live page was
   still English-only and missing the Developer/App names + Chinese text
   when checked on 2026-10-21 — see docs/HUONG_DAN_NOP_APPGALLERY.md).
2. Keep **Chinese mainland** selected only because the 简体中文 policy now
   exists — otherwise uncheck it under Version information →
   Country/Region for release.
3. Fresh-install test on a Huawei device: privacy pop-up first → Keep-Alive
   switch OFF → explanation dialog on toggle → Huawei guide auto-selected.
