# Khắc phục lỗi AppGallery: AAB không tải được / APK sai signature

## Kết luận đã xác nhận

- File đã thử là APK trong artifact **Build RELEASE (publish)** — không phải APK test/debug.
- `com.floatingbutton.app` **đã từng có APK được AppGallery chấp nhận**.
- Vì vậy, nếu APK mới báo sai/không khớp signature, nguyên nhân gần như chắc chắn là
  keystore đang lưu trong GitHub Secrets **không phải keystore đã ký APK cũ**.
  Package name đúng (`com.floatingbutton.app`) vẫn sẽ bị từ chối nếu chứng thư ký khác.
- AppGallery dùng **APK** cho bản tải lên này. File **AAB chỉ dành cho Google Play**,
  không nộp lên AppGallery.

Không có thay đổi code nào tạo lại được chứng thư của keystore cũ. Bản cập nhật bắt buộc
phải được ký bằng **đúng keystore gốc** của APK đã được chấp nhận.

## Cách nhận biết đúng keystore

### 1. Lấy fingerprint của APK cũ đã được chấp nhận

Nếu còn file APK cũ (hoặc tải lại từ máy/kho lưu trữ của bạn), chạy trên máy có Android SDK:

```bash
apksigner verify --print-certs APK_CU_DA_DUOC_CHAP_NHAN.apk
```

Ghi lại dòng:

```text
Signer #1 certificate SHA-256 digest: XX:XX:...
```

### 2. So sánh với APK mới

Mở `CERTIFICATE.txt` trong artifact release mới. Dòng **Signer #1 certificate SHA-256 digest**
phải giống hệt APK cũ, từng ký tự. Nếu khác: đang sai keystore, đừng tải lên.

Cũng có thể kiểm tra trực tiếp keystore ứng viên bằng `keytool` (alias phải đúng):

```bash
keytool -list -v -keystore KEYSTORE_GOC.jks -alias TEN_ALIAS
```

`SHA256:` của certificate trong keystore phải khớp fingerprint APK cũ.

## Thay GitHub Secrets bằng keystore gốc

Vào repo GitHub → **Settings → Secrets and variables → Actions**, sửa đúng 4 secret sau.
**Không gửi file keystore, mật khẩu, hoặc giá trị secret vào chat/PR/commit.**

| Secret | Giá trị mới |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Toàn bộ file `.jks` **gốc**, mã hóa Base64 một dòng |
| `ANDROID_KEYSTORE_PASSWORD` | Store password của keystore gốc |
| `ANDROID_KEY_ALIAS` | Alias của key trong keystore gốc (có thể không còn là `physicsdraw`) |
| `ANDROID_KEY_PASSWORD` | Key password của alias đó (có thể giống store password) |

Mã hóa Base64 file keystore:

- macOS/Linux:
  ```bash
  base64 -w0 KEYSTORE_GOC.jks > keystore-base64.txt
  ```
- Windows PowerShell:
  ```powershell
  [Convert]::ToBase64String([IO.File]::ReadAllBytes("KEYSTORE_GOC.jks")) | Set-Content keystore-base64.txt
  ```

Sau khi sửa xong 4 secret, báo lại **“đã thay key gốc”** (không gửi giá trị). Workflow
**Build RELEASE (publish)** sẽ được chạy lại và fingerprint trong `CERTIFICATE.txt`
phải được đối chiếu trước khi tải APK lên AppGallery.

## Nếu đã mất keystore gốc

Không thể ký bản cập nhật khớp với APK cũ. Khi đó không nên tiếp tục thử các key khác.
Các hướng xử lý phải làm với chính chủ tài khoản/developer support của Huawei
(AppGallery Connect → Help/Feedback hoặc developer support), hỏi thủ tục khôi phục/
thay đổi signing key cho đúng app `com.floatingbutton.app`. Sao lưu keystore gốc và
hai mật khẩu ở nơi an toàn ngay khi tìm lại được.

## Trường hợp thực tế của app này: bản 19/10 không tạo/lưu key thật

APK nào cũng có một chứng thư ký — bản 19/10 có thể đã được ký bằng key tạm,
debug key, hoặc key do công cụ build tự tạo nhưng không được bàn giao/lưu lại.
Từ fingerprint công khai **không thể** tạo lại private key đó.

Không cần tiếp tục tìm "key gốc" nếu key đó chưa từng được tạo và lưu giữ.
Có hai tình huống trong AppGallery Connect:

1. **Bản 19/10 chỉ là bản nháp/chưa từng Full release:**
   Xoá package/version nháp cũ trong AppGallery Connect (nếu giao diện cho phép),
   tạo version mới và tải APK release hiện tại lên. Keystore đang cấu hình trong
   GitHub Secrets từ nay là **key chính thức** — phải sao lưu file `.jks`,
   store password, key alias và key password; mọi bản sau bắt buộc dùng key này.

2. **Hệ thống hiện hộp thoại "signature inconsistency" khi chọn package:**
   Với app thường (không phải game), Huawei cho chọn phương án
   **"need to change the app signature"** (tuỳ chọn thứ hai), nhập lý do,
   tick **Disclaimer** rồi **Submit**. Lý do có thể ghi:

   > The package uploaded on 19 October was signed with a temporary key and
   > no production keystore was retained. Please approve changing to the
   > retained production signing key used from version 2.0.1 onward.

   Chỉ chọn phương án đổi signature khi chấp nhận hệ quả trong Disclaimer
   (đặc biệt nếu bản cũ đã có người dùng cài đặt thật). Nếu app chưa phát
   hành công khai, đây là hướng xử lý phù hợp nhất.

Trong cả hai trường hợp, chỉ tải file
`PowerVolume-v2.0.1-com.floatingbutton.app-APPGALLERY-SIGNED.apk`
lên AppGallery; **không tải AAB**.
## Trường hợp bản PC 2.0.0 ký bằng Android debug key

Thông tin kiểm tra cho thấy APK Power & Volume 2.0.0 đã tải lên ngày 19/10
được ghi nhận là **debug signing**, chưa có release keystore riêng. Nếu bản đó
được build trên PC với debug key mặc định, file key nằm tại:

```text
C:\Users\DELL\.android\debug.keystore
```

Lưu ý:

- Mỗi PC có một `debug.keystore` khác nhau. Key debug do GitHub Actions/Android
  SDK tự tạo trên máy khác sẽ cho SHA-256 khác và vẫn bị AppGallery báo sai.
- Chỉ biết SHA-256, alias hay mật khẩu thì **không ký lại được**; bắt buộc phải
  có đúng file `debug.keystore` trên PC Dell đã build bản 19/10.
- Không gửi file keystore hoặc mật khẩu qua chat, commit Git, hoặc Pull Request.
  Hãy cập nhật trực tiếp trong GitHub → **Settings → Secrets and variables →
  Actions**:

  | Secret | Cần thay bằng |
  |---|---|
  | `ANDROID_KEYSTORE_BASE64` | Nội dung Base64 một dòng của đúng file `debug.keystore` trên PC |
  | `ANDROID_KEYSTORE_PASSWORD` | Store password của debug keystore đó |
  | `ANDROID_KEY_ALIAS` | Alias của debug key đó |
  | `ANDROID_KEY_PASSWORD` | Key password của debug key đó |

- Trên Windows PowerShell, có thể tạo file text chứa Base64 (file này cũng là
  bí mật, không chia sẻ/commit):

  ```powershell
  [Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\.android\debug.keystore")) |
    Set-Content "$env:USERPROFILE\Desktop\debug-keystore-base64.txt"
  ```

- Mở file text, copy toàn bộ nội dung và dán vào secret
  `ANDROID_KEYSTORE_BASE64`. Sau khi thay đủ 4 secret, báo lại
  **“đã thay debug key PC”** để build lại. Bản build mới phải có
  **Signer #1 certificate SHA-256 digest** trong `CERTIFICATE.txt` giống hệt
  chứng thư debug key trên PC/APK 2.0.0.

Cảnh báo lâu dài: debug key chỉ nên dùng để khớp với bản legacy 2.0.0 khi
AppGallery yêu cầu giữ nguyên signature. Hãy sao lưu file này như release key
nếu nó trở thành chữ ký chính thức của app. Nếu AppGallery không chấp nhận
debug signing cho bản phát hành chính thức, hãy dùng release keystore thật và
đi theo quy trình xin đổi signature ở phần trước, thay vì tiếp tục dùng debug key.

### Fingerprint của debug key trên PC (bản hiện tại/2.0.0)

Chứng thư debug đã được xác nhận có thông tin:

```text
DN:       C=US, O=Android, CN=Android Debug
SHA-256:  6d982893a5cf58f3c82e8cf3eca793013a49007aff1670ee338484544a996d8c
SHA-1:    ba5ea3793838675b8d7f46a7da26a57a91355b88
Scheme:   APK Signature Scheme v2
```

SHA-256/SHA-1 ở trên là fingerprint công khai của chứng thư, có thể dùng để
đối chiếu an toàn; chúng **không** thay thế được private key/keystore.

- Nếu mục tiêu là cập nhật liền mạch đúng bản đã ký bằng debug key này,
  `CERTIFICATE.txt` của APK mới phải cho SHA-256 **giống hệt**
  `6d982893a5cf58f3c82e8cf3eca793013a49007aff1670ee338484544a996d8c`.
- Nếu SHA khác, APK mới đang dùng một debug key khác (ví dụ debug key tự tạo
  trên GitHub runner/PC khác) hoặc release key khác; đừng tải lên nếu đang
  cần khớp signature cũ.
- Nếu mục tiêu là phát hành production lâu dài, không nên tiếp tục dùng
  debug key. Hãy dùng release keystore thật và xử lý đổi signature với
  AppGallery theo quy trình ở trên (xoá bản nháp cũ nếu chưa Full release,
  hoặc chọn phương án đổi signature khi hệ thống hiển thị).
