# HANDOFF — Milestone 1 (Floating Power Button)

> Báo cáo này mô tả trạng thái **thực tế có bằng chứng** tại thời điểm bàn giao.
> Mọi kết quả dưới đây đều kèm đường dẫn bằng chứng. Không mục nào được tuyên bố
> PASS nếu chưa có ảnh/log kiểm chứng trực tiếp.

---

## 1. Phạm vi

Chỉ **Milestone 1 — Project Skeleton & Floating Button** theo `ROADMAP.md`.
Không triển khai M2–M8. Không có Lock Screen, Volume, Trial, Ads, Billing.

---

## 2. Môi trường kiểm chứng

| Hạng mục | Giá trị |
|---|---|
| Ramus CLI | `ramus-cli@0.1.13` (chạy qua `npx`), key hợp lệ |
| Session | `2a657fd1-51f8-4777-9ed0-4ea4d6f4abf9` |
| APK kiểm chứng | `build\app\outputs\flutter-apk\app-x86_64-release.apk` (16.9 MB) |
| Package | `com.example.floating_power_button` |
| minSdk / targetSdk | 28 / 36 |
| Ký release | `CN=Android Debug` (theo cấu hình `build.gradle.kts:36`) |
| Kích thước màn hình | 720 × 1616 px |
| **Loại thiết bị** | **Emulator (x86_64) do Ramus cung cấp — KHÔNG phải thiết bị vật lý** |
| Flutter | 3.47.0 stable / Dart 3.13.0 |
| Android SDK | 36.0.0 tại `D:\Android_SDK` |
| Java | OpenJDK 25.0.2 tại `D:\Android_Studio\jbr` |

> Theo `Ramus_CLI.txt` §6: kết quả emulator **không được** báo cáo thành kết quả
> thiết bị thật. Các PASS dưới đây là **emulator-verified**.

---

## 3. Kết quả kiểm thử Milestone 1

### 3.1 Kiểm thử tĩnh & unit test

| Test | Kết quả | Căn cứ |
|---|---|---|
| `flutter analyze` | **PASS** | `No issues found! (ran in 8.2s)` |
| `flutter test` | **PASS 16/16** | `All tests passed!` |
| `gradlew test --rerun-tasks` | **PASS 7/7** | XML: `OverlayPositionTest: tests=7 failures=0 errors=0 skipped=0` |
| Build debug APK | **PASS** | 3 ABI (armeabi-v7a, arm64-v8a, x86_64) |
| Build release APK | **PASS** | 12.9 / 15.5 / 16.9 MB, tree-shaking icon −99.9% |
| APK thuộc dự án này | **PASS** | `aapt dump badging` → package, label `Floating Power Button`, `sdkVersion:'28'` |
| Release không chứa Ramus | **PASS** | search nhị phân `ramus` → 0 match |
| Release không chứa test ad ID | **PASS** | search `ca-app-pub-3940256099942544` → 0 match |
| Release không chứa AccessibilityService | **PASS** | manifest chỉ khai báo `.overlay.OverlayService` |

### 3.2 Kiểm thử runtime trên emulator (Ramus)

| # | Hạng mục (app_detail 2.1 / 8.1) | Kết quả | Bằng chứng |
|---|---|---|---|
| 1 | Màn hình Home báo đúng "permission chưa cấp" | **PASS** | `01_app_home_permission_missing.jpg` |
| 2 | Mở đúng trang hệ thống "Display over other apps" | **PASS** | `02_system_overlay_list.jpg` — app hiện `Not allowed` |
| 3 | Vào trang cấp quyền riêng của app | **PASS** | `03_app_overlay_permission_before_grant.jpg` |
| 4 | Cấp quyền thành công (toggle ON) | **PASS** | `04_app_overlay_permission_after_grant.jpg` |
| 5 | **App re-check permission khi resume** (không tin quyền cũ) | **PASS** | `05_home_permission_granted_button_disabled.jpg` — chuỗi đổi từ *"Overlay permission is not granted"* → *"disabled. Enable it in Settings"*, nút "Open Android overlay settings" biến mất |
| 6 | Settings hiện "Overlay permission granted" | **PASS** | `06_settings_before_enable_permission_granted.jpg` |
| 7 | Bật switch → service start → **nút nổi xuất hiện** | **PASS** | `07_settings_after_enable.jpg` — nút đè lên Settings |
| 8 | **Nút đè lên app khác** (launcher) | **PASS** | `08_overlay_over_launcher_home.jpg` |
| 9 | **Kéo thả đổi vị trí** | **PASS** | `09_overlay_after_drag.jpg` — tâm ~(643,923) → ~(185,405) |
| 10 | Tắt switch → service stop | **PASS** | `10_settings_service_stopped.jpg` |
| 11 | **Vị trí được khôi phục sau restart service** | **PASS** | `11_overlay_position_restored_after_restart.jpg` — về đúng (185,405), KHÔNG nhảy về vị trí mặc định |
| 12 | Tắt → **nút biến mất** | **PASS** | `12_overlay_hidden_after_disable.jpg` |
| 13 | Bật lại → vị trí vẫn được giữ (restore lần 2) | **PASS** | `13_overlay_reenabled_position_restored.jpg` |
| 14 | **Tap ≠ drag**: tap không làm nút nhảy | **PASS** | `14_overlay_after_tap_position_unchanged.jpg` |
| 15 | Vị trí hợp lệ sau xoay màn hình | **NOT TESTED** | Ramus 0.1.13 không có lệnh xoay orientation. Logic clamp có unit test (`OverlayPositionTest.rotation from landscape to portrait...`) nhưng **chưa chạy thật** |
| 16 | Revoke overlay permission khi service đang chạy | **NOT TESTED** | Chưa thực hiện trong session này |
| 17 | Force-stop / reboot / task-swipe → service | **NOT TESTED** | Thuộc Milestone 4 |
| 18 | Logcat của app | **NOT CAPTURED** | `logcat_session_2a657fd1.txt` — scrollback chỉ trả log system (WiFi/brightness), không có dòng nào của `OverlayService`/`OverlayController` |

**Tổng:** 14 PASS · 0 FAIL · 0 BLOCKED · 4 NOT TESTED / NOT CAPTURED

---

## 4. Mô tả UI

### 4.1 Màn hình Home (`lib/src/ui/home_screen.dart`)
AppBar tiêu đề **"Floating Power Button"**, thân là `ListView` với:

- **Card "Floating button status"** — 1 đoạn text trạng thái, gồm 4 nhánh:
  - Chưa cấp quyền → *"Overlay permission is not granted. The floating button cannot be shown until you enable \"Display over other apps\" for this app."* + nút tonal **"Open Android overlay settings"**.
  - Chạy → *"The floating button is running and can be dragged over other applications."*
  - Đã bật nhưng service chết → *"The floating button is enabled but not running right now."*
  - Tắt → *"The floating button is disabled. Enable it in Settings."*
- Nút filled **"Open settings"** → `Navigator.push` sang Settings.

Nút "Open Android overlay settings" **chỉ render khi chưa cấp quyền** — đó là lý do
số phần tử trong UI tree giảm từ 4 xuống 3 sau khi cấp quyền (dùng làm căn cứ PASS #5).

### 4.2 Màn hình Settings (`lib/src/ui/settings_screen.dart`)
AppBar **"Settings"**, thân gồm:

- Title **"Floating button"** + đoạn giải thích vì sao cần quyền
  (*"The button is drawn on top of other apps, so Android requires the \"Display over other apps\" permission..."*).
- **`SwitchListTile`** key=`floating-button-switch`, title *"Show floating button"*,
  subtitle *"Drag the button anywhere; its position is remembered."*
  - `value: _controller.enabled`, `onDisabled` khi `_controller.busy`.
- **`_PermissionRow`** — 2 nhánh:
  - Granted → icon ✓ + *"Overlay permission granted"*.
  - Chưa granted → icon lỗi đỏ + *"Overlay permission is not granted"* + nút outlined
    key=`open-overlay-settings` *"Grant it in Android settings"*.
- Nếu có lỗi → text màu `colorScheme.error`, key=`overlay-message`.

### 4.3 Nút nổi (`FloatingButtonView.kt` — native, không phải Flutter widget)
- Hình tròn, **đường kính 56dp**, màu `#1F6FEB`, glyph nguồn điện trắng
  (vòng cung hở + thân) vẽ bằng `Paint`, không dùng asset nào.
- Vị trí mặc định: **mép phải, dọc giữa**, cách cạnh 16dp
  (`OverlayPositionCalculator.defaultPosition`).
- `contentDescription = R.string.overlay_button_description`.
- Gesture: di chuyển ≤ `scaledTouchSlop` → **tap**; vượt → **drag**, mỗi `ACTION_MOVE`
  báo delta về `OverlayService` cập nhật `LayoutParams`; `ACTION_UP` cuối drag →
  `onMoveFinished` persist toạ độ.
- M1 **chưa gắn hành động khi tap** — `onButtonTapped()` chỉ `Log.d`
  (*"action binding is added in Milestone 2"*).

### 4.4 Các màn hình hệ thống (không phải app)
Trang **"Display over other apps"** (danh sách app) và trang riêng
**"Allow display over other apps"** (toggle) — do Android cung cấp, app chỉ mở intent
`Settings.ACTION_MANAGE_OVERLAY_PERMISSION`.

---

## 5. Cấu trúc mã nguồn liên quan (M1)

```
lib/
  main.dart
  src/app.dart                      MaterialApp + inject OverlayService (cho test)
  src/ui/home_screen.dart           trạng thái + link Settings, refresh on resume
  src/ui/settings_screen.dart       switch enable/disable + hàng permission
  src/overlay/overlay_service.dart  OverlayStatus, OverlayStartException, MethodChannel bridge
  src/overlay/overlay_controller.dart  ChangeNotifier, bắt lỗi trung thực

android/.../overlay/
  MainActivity.kt                   MethodChannel "floating_power_button/overlay"
                                    → getState / setEnabled / openOverlaySettings
  OverlayController.kt              đọc state, start/stop, mở intent permission
  OverlayService.kt                 Service + WindowManager window, clamp khi config change
  FloatingButtonView.kt             view tròn + gesture tap/drag
  OverlayStore.kt                   SharedPreferences (enabled, position_x, position_y)
  OverlayPosition.kt                pure geometry: clamp + defaultPosition
  OverlayDisplay.kt                 display metrics qua window context
  OverlayPermissions.kt             Settings.canDrawOverlays + settingsIntent
  OverlayRuntime.kt                 @Volatile serviceRunning
```

**Thiết kế đáng chú ý:** `OverlayService` là **started service thường**, *không* phải
foreground service (không notification, không `foregroundServiceType`). Lý do nằm trong
comment `OverlayService.kt:16–27`: tránh khai báo `specialUse` + justification trên
Play Console. `START_STICKY` để Android dựng lại window khi kill. **Đây là rủi ro cần
xác minh lại bằng thiết bị thật ở Milestone 4.**

---

## 6. Vấn đề đã biết

1. **Chưa test xoay màn hình trên emulator** — clamp logic chỉ có unit test JVM.
2. **Chưa test revoke permission khi overlay đang chạy** — code có nhánh này
   (`OverlayService.onStartCommand` → `stopSelf()` khi mất quyền) nhưng chưa chạy thật.
3. **Logcat app không thu được** qua `ramus logcat` (buffer xoay vòng) → nếu cần log,
   phải lấy ngay sau hành động.
4. **Release ký bằng debug key** (`build.gradle.kts:34–37` còn TODO) — phải sửa trước
   khi release thật.
5. **`gradlew` yêu cầu `JAVA_HOME=D:\Android_Studio\jbr`** — chưa set trong môi trường,
   sẽ fail nếu chạy trực tiếp.
6. **Kết quả là emulator**, chưa xác minh trên thiết bị vật lý hay 2 phiên bản Android
   khác nhau (ROADMAP M1/M8 yêu cầu).

---

## 7. Việc cần làm tiếp (ngoài phạm vi M1, không tự ý làm)

- **M2** — Function Selection Model (`LOCK_ONLY` / `VOLUME_ONLY` / `BOTH`), bind hành
  động vào `onTap` của `FloatingButtonView`.
- **M3** — Hai hành động (AccessibilityService lock screen, AudioManager volume UI).
- **M4** — Permission revocation + service lifecycle trên thiết bị thật.
- Trước M8: thay signing config release, kiểm chứng lại trên thiết bị vật lý.

---

## 8. Bằng chứng

```
project_docs/evidence/m1/
  01_app_home_permission_missing.jpg
  02_system_overlay_list.jpg
  03_app_overlay_permission_before_grant.jpg
  04_app_overlay_permission_after_grant.jpg
  05_home_permission_granted_button_disabled.jpg
  06_settings_before_enable_permission_granted.jpg
  07_settings_after_enable.jpg
  08_overlay_over_launcher_home.jpg
  09_overlay_after_drag.jpg
  10_settings_service_stopped.jpg
  11_overlay_position_restored_after_restart.jpg
  12_overlay_hidden_after_disable.jpg
  13_overlay_reenabled_position_restored.jpg
  14_overlay_after_tap_position_unchanged.jpg
  logcat_session_2a657fd1.txt
```

Tên file mô tả **đúng nội dung ảnh** (bài học từ bộ evidence trước bị lẫn nội dung).
Ảnh là JPEG theo `mime: image/jpeg` mà Ramus trả về.
