# Quảng cáo: Huawei Petal Ads + Google AdMob (dual banner)

## Kiến trúc

```
Scaffold
 ├─ body: SafeArea → Column → header + Expanded(ListView)   ← cuộn
 │    … Permissions … Device Guide … Support Developer (Payoneer/VietQR)
 └─ bottomNavigationBar: AdBannerHost (cao cố định 56dp)     ← GHIM ĐÁY
```

Banner **không** nằm trong `ListView` nữa (lỗi cũ: bị nội dung đẩy xuống
cuối trang). Nó được ghim ở `Scaffold.bottomNavigationBar` — luôn ở đáy
màn hình, nội dung cuộn phía trên, không che và không bị che.

## Luồng chọn nhà quảng cáo (`lib/widgets/ads/ad_banner_host.dart`)

1. **Huawei Petal Ads (ưu tiên trên máy Huawei/HMS):**
   `NativeBridge.isHmsAvailable()` (hãng Huawei/Honor + có HMS Core) và
   `isPetalAdsAvailable()` (có SDK `HwAds`) → hiện native `BannerView`
   qua platform view `power_volume/petal_banner`
   (Kotlin: `PetalBannerView` / `PetalBannerViewFactory`, SDK
   `com.huawei.hms:ads-lite`). Native báo `onPetalBannerLoaded/Failed`
   qua channel `power_volume/petal_ads_events`.
2. **Google AdMob (dự phòng):** Petal không có / load lỗi / quá 8 giây
   (`AdConfig.petalLoadTimeout`) → `google_mobile_ads` BannerAd 320×50.
3. **House strip:** cả hai đều lỗi/không có quảng cáo → dải "Ad — Ads keep
   this utility 100% free for everyone" giữ nguyên chiều cao 56dp.

Quảng cáo chỉ khởi tạo sau khi người dùng đã đồng ý Privacy Policy
(`AdBannerHost` chỉ tồn tại ở Home, phía sau `PrivacyConsentGate`).

## Thay ID test → ID thật trước khi phát hành

| Hạng mục | File | Hiện tại (TEST) |
|---|---|---|
| Petal Ads Banner Unit ID | `lib/constants/app_info.dart` → `petalBannerAdUnitId` | `testw6vs28auh3` (test công khai của Huawei) |
| AdMob Banner Unit ID | `lib/constants/app_info.dart` → `adMobBannerAdUnitId` | `ca-app-pub-3940256099942544/6300978111` (test của Google) |
| AdMob App ID | `android/app/src/main/AndroidManifest.xml` → `com.google.android.gms.ads.APPLICATION_ID` | `ca-app-pub-3940256099942544~3347511713` |

## i18n liên quan

Mọi chuỗi của banner/thẻ Donate đều qua `AppStrings`
(`adsNote`, `adLoading`, `supportTitle`, `supportBody`, `donateViaPayoneer`,
`donateViaVietQr`, …) — hỗ trợ **EN / VI / ZH / ES** qua nút chọn ngôn ngữ
ở header; chọn ngôn ngữ nào thì dialog, guide và nút đều đổi theo.
