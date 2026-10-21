# Hướng dẫn nộp bản 2.0.1 lên Huawei AppGallery (từng bước, trên GitHub + AppGallery Connect)

> App: **Power & Volume - Lock Screen & Sound Control** · Developer: **NGUYEN MINH THANH** · Email: alphaplusthanh82@gmail.com

## Mục 1 — Privacy Policy đã lên Vercel ✅ (URL chính thức)

URL dùng cho AppGallery Connect và trong app (đã khai báo tại
`lib/constants/app_info.dart` → `privacyPolicyUrl`):

**https://power-volume-privacy.vercel.app/privacy-policy.html**

Việc cần làm:

1. Mở URL trên kiểm tra trang tải được (không lỗi 404, không đòi đăng nhập).
2. Dán URL này vào AppGallery Connect → **App information → Privacy Policy URL**
   (chi tiết ở Mục 2).
3. Không cần bật GitHub Pages nữa — trang đã host trên Vercel, repo app
   vẫn để Private bình thường. File `docs/privacy-policy.html` trong repo
   này là **nội dung chuẩn (canonical)** để đồng bộ lên Vercel.

> ⚠️ **QUAN TRỌNG — phải đồng bộ nội dung trang Vercel trước khi nộp:**
> Khi kiểm tra ngày 21/10/2026, trang Vercel hiện tại **chỉ có tiếng Anh**
> và **chưa ghi** `Developer Name: NGUYEN MINH THANH`,
> `App Name: Power & Volume - Lock Screen & Sound Control`,
> `Contact Email: alphaplusthanh82@gmail.com`, cũng **chưa có bản
> 简体中文**. Nếu nộp nguyên trạng, Huawei sẽ lại bắt lỗi #2 (thiếu tiếng
> Trung) và #3 (thiếu tên App/Developer).
>
> Cách sửa: vào project Vercel `power-volume-privacy`, thay nội dung file
> `privacy-policy.html` bằng đúng file
> [`docs/privacy-policy.html`](privacy-policy.html) trong repo này (đã có
> đủ EN / VI / 简体中文 + tên + email), rồi **Redeploy**. Mở lại URL kiểm
> tra thấy đủ 3 ngôn ngữ và 3 dòng Developer/App/Email mới đạt.

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
