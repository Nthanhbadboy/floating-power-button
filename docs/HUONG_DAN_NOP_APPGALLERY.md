# Hướng dẫn nộp bản 2.0.1 lên Huawei AppGallery (từng bước, trên GitHub + AppGallery Connect)

> App: **Power & Volume - Lock Screen & Sound Control** · Developer: **NGUYEN MINH THANH** · Email: alphaplusthanh82@gmail.com

## Mục 1 — Đưa Privacy Policy lên mạng bằng GitHub Pages

Trang chính sách đã có sẵn trong repo tại `docs/privacy-policy.html`
(3 ngôn ngữ: EN / VI / 简体中文). Cần công khai nó theo các bước:

1. **Merge Pull Request** của branch `arena/aa4d9a51-floating-power-button`
   vào `main` trên GitHub (GitHub Pages chỉ phát hành ổn định từ `main`).
2. Vào repo → **Settings → Pages**:
   - *Build and deployment → Source:* **Deploy from a Branch**
   - *Branch:* `main` · Folder: **`/docs`** → **Save**
3. Đợi 1–2 phút, mở thử:
   `https://nthanhbadboy.github.io/floating-power-button/privacy-policy.html`
   Phải thấy đủ 3 mục English / Tiếng Việt / 简体中文 và dòng
   *Developer Name: NGUYEN MINH THANH*.

> ⚠️ **Repo đang để Private.** Với tài khoản GitHub Free, Pages chỉ chạy
> cho repo **Public** (Private cần GitHub Pro). Chọn 1 trong 3 cách:
> - **Cách A (đơn giản nhất cho Privacy Policy):** tạo 1 repo public riêng
>   (ví dụ `power-volume-privacy`) chỉ chứa file `privacy-policy.html`,
>   bật Pages ở đó, dùng URL của repo đó. Code app vẫn để private.
> - **Cách B:** chuyển repo này sang Public (chỉ khi chị thoải mái công khai code).
> - **Cách C:** nâng GitHub Pro để giữ Private mà vẫn dùng được Pages.
>
> Nếu chọn Cách A, nhớ sửa lại hằng số `privacyPolicyUrl` trong
> `lib/constants/app_info.dart` cho khớp URL mới trước khi build.

## Mục 2 — Khai báo trên AppGallery Connect

1. **App information → Privacy Policy URL:** dán URL ở Mục 1.
   Kiểm tra lại tên hiển thị đúng: App `Power&volume` /
   `Power & Volume - Lock Screen & Sound Control`, Developer
   `NGUYEN MINH THANH` — phải khớp từng ký tự với văn bản Privacy Policy.
2. **Version information (2.0.1) → Country/Region for release:**
   - Giữ nguyên **Chinese mainland** vì đã có bản 简体中文, **hoặc**
   - bỏ tích Chinese mainland nếu không muốn phát hành thị trường này.
3. **Notes for review:** copy toàn bộ nội dung file
   [`REVIEWER_NOTES_2.0.1.md`](REVIEWER_NOTES_2.0.1.md) dán vào.

## Mục 3 — Build bản phát hành

```bash
flutter pub get
flutter test          # phải pass: pop-up privacy + switch mặc định OFF
flutter analyze
# Tạo android/key.properties + keystore thật (không commit keystore)
flutter build appbundle --release   # hoặc flutter build apk --release
```

## Mục 4 — Tự kiểm tra trên máy Huawei thật (cài mới hoàn toàn)

- [ ] Gỡ bản cũ, cài bản 2.0.1 → mở app thấy **ngay pop-up Privacy Policy**,
      chưa đồng ý thì không vào được màn hình chính, bấm Từ chối thì thoát app.
- [ ] Vào app → mục **Keep-Alive Foreground Service đang TẮT**; gạt bật thì
      hiện dialog giải thích, bấm **Cho phép (Enable)** mới xuất hiện thông báo
      cố định "Power & Volume Active" (LOCK / VOLUME).
- [ ] Bật **Accessibility Service** → thẻ đỏ **LOCK SCREEN** khóa máy ngay;
      thẻ xanh **VOLUME PANEL** hiện thanh âm lượng.
- [ ] Thẻ **Device-Specific Background Guide** tự chọn đúng **Huawei / Honor**
      + nhãn **Your Device**, nút mở được Huawei Battery Settings
      (App launch → tắt Manage automatically → bật cả 3 mục → 🔒 trong Recents).
- [ ] Footer → **Privacy Policy** mở được, chuyển tab **中文** đọc được tiếng Trung.
- [ ] Chụp lại các màn hình trên (tham chiếu sẵn trong
      [`docs/screenshots/`](screenshots/)) phòng khi đội kiểm duyệt hỏi thêm.

## Mục 5 — Nếu vẫn bị trả về

Gửi lại cho đội kiểm duyệt (qua AppGallery Connect → Version → Review comments)
đường link PR/bản build 2.0.1 kèm câu: *"All 4 issues are fixed in 2.0.1 —
first-launch privacy consent pop-up, Simplified Chinese privacy policy,
exact app/developer names in the policy, and foreground service OFF by
default with explicit consent. Details: docs/APPGALLERY_FIXES_2.0.1.md."*
