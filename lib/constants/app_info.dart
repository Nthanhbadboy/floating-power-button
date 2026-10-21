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

  /// Online Privacy Policy (GitHub Pages, served from /docs).
  /// Enable: GitHub repo Settings -> Pages -> Deploy from branch -> /docs.
  /// The page ships EN + VI + Simplified Chinese (review issue #2).
  static const String privacyPolicyUrl =
      'https://nthanhbadboy.github.io/floating-power-button/privacy-policy.html';

  static const String version = '2.0.1';
}
