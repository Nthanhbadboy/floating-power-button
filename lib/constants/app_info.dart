/// Single source of truth for the store identity.
///
/// These values MUST stay identical to AppGallery Connect, otherwise the
/// Privacy Policy is rejected again (Huawei review issue #3).
class AppInfo {
  const AppInfo._();

  /// Exact app name shown on AppGallery / in the Privacy Policy.
  static const String appName =
      'Power & Volume - Lock Screen & Sound Control';

  /// Short name used in the UI (matches the screenshots / store short name
  /// "Power&volume").
  static const String shortAppName = 'Power & Volume';

  /// Exact developer name registered on AppGallery Connect.
  static const String developerName = 'NGUYEN MINH THANH';

  static const String contactEmail = 'alphaplusthanh82@gmail.com';

  /// Online Privacy Policy — hosted on Vercel (live, verified 2026-10-21):
  /// https://power-volume-privacy.vercel.app/privacy-policy.html
  /// Keep the deployed page IN SYNC with the canonical 3-language content
  /// in `docs/privacy-policy.html` (EN + VI + Simplified Chinese, review
  /// issues #2/#3). The in-app "open online policy" button uses this URL.
  static const String privacyPolicyUrl =
      'https://power-volume-privacy.vercel.app/privacy-policy.html';

  static const String version = '2.0.1';

  // --- Donate (Support Developer card) --------------------------------------
  /// Payoneer payments are addressed to the developer's Payoneer email.
  static const String payoneerEmail = contactEmail;

  /// Shown in the VietQR donate dialog. Replace with the real bank info /
  /// QR payload before release if it changes.
  static const String vietQrInfo =
      'VietQR — NGUYEN MINH THANH\n(Bank QR code provided by the developer)';

  // --- Ads (Petal Ads -> AdMob fallback) ------------------------------------
  /// Huawei Petal Ads banner ad unit. This is Huawei's public TEST slot;
  /// replace with the designated production Ad Unit ID from Petal Ads
  /// Publisher Service before submitting to AppGallery.
  static const String petalBannerAdUnitId = 'testw6vs28auh3';

  /// Google AdMob banner ad unit. Google's public TEST banner unit;
  /// replace with the production unit (and the APPLICATION_ID meta-data in
  /// AndroidManifest.xml) before release.
  static const String adMobBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
}
