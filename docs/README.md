# 📚 Tài liệu Power & Volume (GitHub Docs)

> **App:** Power & Volume - Lock Screen & Sound Control (`Power&volume`)
> **Developer:** NGUYEN MINH THANH · **Email:** alphaplusthanh82@gmail.com
> **Phiên bản:** 2.0.1

Đây là mục lục toàn bộ tài liệu của dự án trên GitHub. Trang Privacy Policy chính thức được host trên **Vercel** (xem bên dưới);
thư mục `/docs` này là nơi lưu nội dung chuẩn để đồng bộ lên Vercel.

## 1. AppGallery 2.0.1 — sửa 4 lỗi kiểm duyệt

| Tài liệu | Nội dung |
|---|---|
| [APPGALLERY_FIXES_2.0.1.md](APPGALLERY_FIXES_2.0.1.md) | Chi tiết cách sửa 4 lỗi + checklist trước khi nộp |
| [REVIEWER_NOTES_2.0.1.md](REVIEWER_NOTES_2.0.1.md) | Nội dung tiếng Anh để dán vào ô "Notes for review" trên AppGallery Connect |
| [CAI_DAT_BAN_TEST.md](CAI_DAT_BAN_TEST.md) | Tải APK test từ GitHub Actions về cài trực tiếp, không cần Flutter |
| [HUONG_DAN_NOP_APPGALLERY.md](HUONG_DAN_NOP_APPGALLERY.md) | Hướng dẫn từng bước bằng tiếng Việt: URL Vercel, điền Privacy Policy URL, chọn vùng phát hành, nộp bản 2.0.1 |

## 2. Privacy Policy (3 ngôn ngữ)

| Ngôn ngữ | Bản web (file chuẩn để deploy lên Vercel) | Bản Markdown trên GitHub |
|---|---|---|
| English | [privacy-policy.html#en](privacy-policy.html) | [privacy_policy_en.md](privacy_policy_en.md) |
| Tiếng Việt | [privacy-policy.html#vi](privacy-policy.html) | [privacy_policy_vi.md](privacy_policy_vi.md) |
| 简体中文 | [privacy-policy.html#zh](privacy-policy.html) | [privacy_policy_zh.md](privacy_policy_zh.md) |

URL công khai chính thức (Vercel):
**https://power-volume-privacy.vercel.app/privacy-policy.html**

> ⚠️ Trang Vercel phải được đồng bộ nội dung từ `privacy-policy.html` ở
> thư mục này (đủ EN/VI/简体中文 + Developer Name + App Name + Email)
> trước khi nộp AppGallery — xem cảnh báo ở
> [HUONG_DAN_NOP_APPGALLERY.md](HUONG_DAN_NOP_APPGALLERY.md) Mục 1.

## 3. Ảnh chụp ứng dụng (tham chiếu UI)

| Ảnh | Nội dung |
|---|---|
| [screenshots/03-home-protected-lock-volume.jpeg](screenshots/03-home-protected-lock-volume.jpeg) | Màn hình chính: Protected 24/7, LOCK SCREEN, VOLUME PANEL |
| [screenshots/02-permissions-keep-alive.jpeg](screenshots/02-permissions-keep-alive.jpeg) | Permissions & Keep-Alive Settings (Accessibility, Device Admin, Foreground Service, Battery) |
| [screenshots/01-huawei-setup-steps.jpeg](screenshots/01-huawei-setup-steps.jpeg) | Hướng dẫn từng bước cho Huawei/Honor + Support Developer |
| [screenshots/04-notification-lock-volume.jpeg](screenshots/04-notification-lock-volume.jpeg) | Thông báo cố định "Power & Volume Active" với nút LOCK / VOLUME |

## 4. Tài liệu khác

- [README chính của dự án](../README.md) — tổng quan, cấu trúc code, lệnh build
- [CHANGELOG](../CHANGELOG.md) — lịch sử thay đổi theo phiên bản
- Code nguồn: [`lib/`](../lib) (Flutter) · [`android/`](../android) (Kotlin native)
- Kiểm thử: [`test/widget_test.dart`](../test/widget_test.dart) — test pop-up
  Privacy lần đầu mở app & công tắc Foreground Service mặc định OFF
