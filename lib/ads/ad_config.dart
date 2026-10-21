import '../constants/app_info.dart';

/// Which network a banner slot is (trying to) serve from.
enum AdProvider { petal, admob, house }

/// Central ad configuration. Production IDs belong in [AppInfo] so there is
/// exactly one place to swap TEST -> production units.
class AdConfig {
  const AdConfig._();

  /// Fixed banner height: standard 320x50 banner + safe padding.
  /// The banner is pinned in `Scaffold.bottomNavigationBar` and must never
  /// change height (layout shift would push the scrollable content around).
  static const double bannerHeight = 56;

  static const String petalBannerAdUnitId = AppInfo.petalBannerAdUnitId;
  static const String adMobBannerAdUnitId = AppInfo.adMobBannerAdUnitId;

  /// Platform-view type registered by MainActivity for the native Huawei
  /// Petal Ads BannerView.
  static const String petalBannerViewType = 'power_volume/petal_banner';

  /// Event channel the native Petal banner uses to report load success /
  /// failure back to Dart (so we can fall back to AdMob).
  static const String petalEventChannelName = 'power_volume/petal_ads_events';

  /// How long to wait for Petal Ads before falling back to AdMob.
  static const Duration petalLoadTimeout = Duration(seconds: 8);
}
