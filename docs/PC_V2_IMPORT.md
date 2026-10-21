# PC v2 source import

Source of truth for the imported native code:

- Repository: `Nthanhbadboy/floating_power_button_v2`
- Branch: `PC`
- Commit: `32c0546` (`Initial commit: floating power button v2 source`)
- Local project: `D:\floating_power_button_v2`

## Imported into this project

- `BootCompletedReceiver` — restores Keep-Alive after `BOOT_COMPLETED` /
  `MY_PACKAGE_REPLACED`, **adapted** so it only resumes when the user has
  previously enabled Keep-Alive in the app. It never enables the service on
  a fresh install.
- `LockTileService` and `VolumeTileService` — Quick Settings tiles.
- `VolumeController` — shared helper that shows the system volume panel.
- Launcher long-press shortcuts (`res/xml/shortcuts.xml`) handled by
  `MainActivity` (`ACTION_QUICK_LOCK` / `ACTION_QUICK_VOLUME`).
- Tile/shortcut vector icons and native string resources
  (EN/VI/ZH/ES/JA/KO).
- `PowerAccessibilityService.lockScreen(context)` helper used by the
  tiles and shortcuts (Device Admin first, then Accessibility).

## Deliberately not imported

- The PC Dart UI (`lib/core`, `lib/screens/home_screen.dart`, monetisation
  widgets): this repo's 2.0.1 UI already contains the AppGallery fixes
  (privacy consent gate, Simplified Chinese policy, exact Developer/App
  identity, Keep-Alive OFF by default), the 5-OEM background guide,
  Support Developer card and the Petal Ads → AdMob banner.
- The PC `build.gradle.kts` release block (`signingConfig = debug`,
  minify/shrink): releases here are signed through GitHub Secrets
  (`android/key.properties`, created only on the CI runner) and must never
  fall back to a debug certificate for publishing.
- The PC Gradle/AGP/Kotlin upgrades: this repo stays on the verified
  Flutter 3.24.5 / Gradle 8.4 CI toolchain, including the Huawei Maven
  repository required by Petal Ads.
- `KeepAliveService` as a separate class: its behaviour is merged into
  `KeepAliveForegroundService`, which now also persists the user's opt-in
  so boot restore can be gated on it and starts with the explicit
  `specialUse` foreground-service type on Android 14+.

## Signing note

The PC build was verified to be signed with that machine's Android Debug
certificate (SHA-256
`6d982893a5cf58f3c82e8cf3eca793013a49007aff1670ee338484544a996d8c`).
See `docs/SIGNING_TROUBLESHOOTING.md` before attempting an AppGallery
update; do not commit any keystore or `key.properties`.
