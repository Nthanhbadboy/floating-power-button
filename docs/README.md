# 📚 Tài liệu Power & Volume (GitHub Docs)

> **App:** Power & Volume - Lock Screen & Sound Control (`Power&volume`)
> **Developer:** NGUYEN MINH THANH · **Email:** alphaplusthanh82@gmail.com
> **Phiên bản:** 2.0.1

Đây là mục lục toàn bộ tài liệu của dự án trên GitHub. Khi repo được
merge vào `main`, thư mục `/docs` này cũng là nguồn để bật **GitHub Pages**
cho trang Privacy Policy công khai.

## 1. AppGallery 2.0.1 — sửa 4 lỗi kiểm duyệt

| Tài liệu | Nội dung |
|---|---|
| [APPGALLERY_FIXES_2.0.1.md](APPGALLERY_FIXES_2.0.1.md) | Chi tiết cách sửa 4 lỗi + checklist trước khi nộp |
| [REVIEWER_NOTES_2.0.1.md](REVIEWER_NOTES_2.0.1.md) | Nội dung tiếng Anh để dán vào ô "Notes for review" trên AppGallery Connect |
| [HUONG_DAN_NOP_APPGALLERY.md](HUONG_DAN_NOP_APPGALLERY.md) | Hướng dẫn từng bước bằng tiếng Việt: bật GitHub Pages, điền Privacy Policy URL, chọn vùng phát hành, nộp bản 2.0.1 |

## 2. Privacy Policy (3 ngôn ngữ)

| Ngôn ngữ | Bản web (GitHub Pages) | Bản Markdown trên GitHub |
|---|---|---|
| English | [privacy-policy.html#en](privacy-policy.html) | [privacy_policy_en.md](privacy_policy_en.md) |
| Tiếng Việt | [privacy-policy.html#vi](privacy-policy.html) | [privacy_policy_vi.md](privacy_policy_vi.md) |
| 简体中文 | [privacy-policy.html#zh](privacy-policy.html) | [privacy_policy_zh.md](privacy_policy_zh.md) |

URL công khai (sau khi bật Pages trên nhánh `main`):
`https://nthanhbadboy.github.io/floating-power-button/privacy-policy.html`

> ⚠️ Repo hiện đang **private**. Với GitHub Free, GitHub Pages chỉ hoạt
> động cho repo public (private cần GitHub Pro). Xem các phương án tại
> [HUONG_DAN_NOP_APPGALLERY.md](HUONG_DAN_NOP_APPGALLERY.md) — mục 1.

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
