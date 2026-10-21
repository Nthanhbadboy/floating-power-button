# Huawei AppGallery — 4 review issues fixed in 2.0.1

Developer: **NGUYEN MINH THANH** · App: **Power & Volume - Lock Screen & Sound Control** (`Power&volume`) · Contact: alphaplusthanh82@gmail.com

## 🔴 Issue 1 — No Privacy Policy pop-up on first launch ✅ FIXED
- `lib/widgets/privacy_consent_gate.dart`: `PrivacyConsentGate` wraps the whole app.
  The home screen is **not even built** until consent is given — no service,
  permission prompt or ad can run before it.
- Non-dismissible (`PopScope(canPop: false)`, no barrier dismissal).
  **Decline** exits the app via `SystemNavigator.pop()`.
- State persisted with `shared_preferences` key `is_privacy_accepted`
  (`lib/services/preferences_service.dart`), loaded in `main()` before the
  first frame so there is no flash of the home UI.
- Pop-up text (EN/VI/中文):
  > "Welcome to Power & Volume. To continue using the app, please read and
  > agree to our [Privacy Policy] and [Terms of Service]." → **[Agree]**

## 🔴 Issue 2 — Simplified Chinese Privacy Policy ✅ FIXED (kept Chinese mainland)
- Full Simplified Chinese translation added:
  - online: `docs/privacy-policy.html#zh`
  - in-app: Privacy Policy screen → **中文** tab (`lib/data/privacy_policy_content.dart`)
- Because the translation now exists, **Chinese mainland can stay selected**
  in AppGallery Connect → Version information → Country/Region for release.
  *(Alternative if you ever drop that market: uncheck Chinese mainland there.)*

## 🔴 Issue 3 — App Name & Developer Name in Privacy Policy ✅ FIXED
Exact strings, single-sourced from `lib/constants/app_info.dart` and shown in
the in-app policy header card, the online policy, and this document:

> **Developer Name:** NGUYEN MINH THANH
> **App Name:** Power & Volume - Lock Screen & Sound Control
> **Contact Email:** alphaplusthanh82@gmail.com

⚠️ Before submitting: confirm these match AppGallery Connect character-for-
character (including the store short name `Power&volume`).

## 🔴 Issue 4 — Foreground Service must be explicitly consented ✅ FIXED
- `PreferencesService.keepAliveEnabled` defaults to **false** — the
  *Keep-Alive Foreground Service* switch is OFF on a fresh install.
- `MainActivity.onCreate()` and the service itself never auto-start:
  no `startForegroundService()` on launch, no BOOT receiver.
- Turning the switch ON always shows the explanation dialog first
  (`lib/widgets/foreground_service_dialog.dart`):
  > "Enabling the background service helps the app keep a persistent
  > notification to control volume and lock the screen without being closed
  > by the OS. Do you want to activate it?" → **[Enable] / [Cancel]**
- Only after **Enable** does Dart call `NativeBridge.startForegroundService()`.
  Both `keep_alive_foreground_enabled` and `foreground_service_consented`
  are persisted; a previously consented service may resume on later launches
  (consent was already explicit — it is never granted silently).

## Device-Specific Background Guide ✅ EXPANDED (all 5 OEMs)
`lib/data/manufacturer_guides.dart` + native intents in `MainActivity.kt`:

| Tab | Highlights |
|---|---|
| Huawei / Honor | Battery Settings → App launch → Manage automatically OFF → Auto-launch + Secondary launch + Run in background ON → swipe down in Recents until 🔒 |
| Xiaomi / Redmi / POCO | App Info → Autostart ON → Battery Saver = No restrictions → long-press card in Recents → 🔒 |
| Samsung | Device Care → Battery → Background usage limits → Never sleeping apps; App Info → Battery = Unrestricted |
| OPPO / Realme | App Management → Battery usage → Allow background activity + Allow auto-launch; Recents → ⋮ → Lock |
| Vivo / iQOO | Battery → High background power consumption = Allowed; Autostart ON |

Auto-detection (`Build.MANUFACTURER/BRAND`) pre-selects the tab and shows the
**Your Device** badge (matches the "Protected 24/7 — Device: Huawei
(EVR-AL00)" banner in the screenshots).

## ✅ Pre-submission checklist (build 2.0.1)
- [x] First-launch Privacy Policy pop-up (Agree required, persisted)
- [x] Privacy Policy updated with App Name `Power&volume` / `Power & Volume - Lock Screen & Sound Control` and Developer `NGUYEN MINH THANH`
- [x] Simplified Chinese Privacy Policy added — *or* uncheck Chinese mainland *(done: translation added, market kept)*
- [x] Foreground Service OFF by default; starts only after manual Enable
- [x] Device guide tabs for Huawei / Xiaomi / Samsung / OPPO / Vivo
- [x] Privacy Policy URL is live on Vercel:
      `https://power-volume-privacy.vercel.app/privacy-policy.html`
      → paste it into AppGallery Connect → App information → Privacy Policy URL
- [ ] **Sync the Vercel page content** with `docs/privacy-policy.html` in this
      repo and redeploy (see warning in `HUONG_DAN_NOP_APPGALLERY.md` Mục 1):
      as last checked (2026-10-21) the live page is English-only, names
      neither Developer `NGUYEN MINH THANH` / App
      `Power & Volume - Lock Screen & Sound Control` nor the contact email,
      and has no 简体中文 section — issues #2/#3 would fail again as-is.
- [ ] Add release signing (`android/key.properties` + keystore, not committed), then
      `flutter build appbundle --release` (AppGallery also accepts APK)
- [ ] Re-test on a real Huawei device from a **fresh install**: pop-up first,
      switch OFF, dialog on toggle, Huawei guide auto-selected
- [ ] Paste the reviewer notes from `docs/REVIEWER_NOTES_2.0.1.md` into the
      AppGallery "Notes for review" field
