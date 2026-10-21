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
}
