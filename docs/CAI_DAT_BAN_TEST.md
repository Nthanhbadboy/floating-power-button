# Cài bản test từ GitHub Actions

Mỗi lần GitHub Actions chạy workflow **"Build test APK (installable)"**,
nó sẽ build sẵn file APK để tải về cài trực tiếp — không cần cài Flutter.

## Cách tải APK

1. Vào repo → tab **Actions**:
   https://github.com/Nthanhbadboy/floating-power-button/actions
2. Chọn lần chạy mới nhất của workflow **Build test APK (installable)**
   (dấu ✅ xanh là build thành công; bấm **Run workflow** nếu muốn chạy lại).
3. Kéo xuống mục **Artifacts** → tải `PowerVolume-v2.0.1-apk` (file .zip).
4. Giải nén được 2 file:
   - `PowerVolume-v2.0.1-DEBUG.apk` — bản test nhanh.
   - `PowerVolume-v2.0.1-RELEASE-TEST.apk` — bản release test (đang ký bằng
     debug key nên cài trực tiếp được; **chưa** dùng để nộp AppGallery).

## Cài trên máy Huawei/Android

1. Copy file `.apk` vào điện thoại (Zalo/USB/tải thẳng từ trình duyệt máy).
2. Mở file → nếu máy hỏi, chọn **Cho phép cài ứng dụng không rõ nguồn gốc**
   cho ứng dụng đang mở file (Files/Chrome).
3. Cài xong mở **Power & Volume**:
   - Lần đầu sẽ hiện **pop-up Privacy Policy** → bấm **Agree** (Đồng ý).
   - Bật **Accessibility Service** để dùng LOCK SCREEN.
   - Công tắc **Keep-Alive Foreground Service đang TẮT** — gạt lên sẽ hiện
     dialog giải thích, bấm **Enable** mới chạy (đây là yêu cầu của Huawei).
   - Làm tiếp theo thẻ **Device-Specific Background Guide** (máy Huawei:
     App launch → tắt Manage automatically → bật cả 3 mục → khóa 🔒 trong Recents).

> Lưu ý: APK tải từ Artifacts cần **đăng nhập GitHub** trên trình duyệt mới
> tải được (repo đang Private). Link Artifacts hết hạn sau **14 ngày** —
> chạy lại workflow là có bản mới.
