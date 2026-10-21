import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../ads/ad_config.dart';
import '../../l10n/app_strings.dart';
import '../../services/native_bridge.dart';

/// Fixed bottom banner (50–56dp), pinned by `Scaffold.bottomNavigationBar`
/// so it can NEVER be pushed away by scrolling (previous regression: the
/// banner lived inside the ListView and sank to the page bottom).
///
/// Provider strategy (dual integration):
///   1. **Huawei Petal Ads** — on HMS devices, a native `BannerView`
///      (platform view `power_volume/petal_banner`) is shown first.
///   2. **Google AdMob fallback** — if HMS/Petal is unavailable, fails to
///      load, or times out, a google_mobile_ads `BannerAd` is loaded.
///   3. **House placeholder** — if both fail (e.g. no fill), a clearly
///      labelled free-utility strip keeps the layout stable.
///
/// Ads are only initialised from here — i.e. after the first-launch
/// privacy consent — never before it.
class AdBannerHost extends StatefulWidget {
  const AdBannerHost({super.key, required this.strings});

  final AppStrings strings;

  @override
  State<AdBannerHost> createState() => _AdBannerHostState();
}

class _AdBannerHostState extends State<AdBannerHost> {
  static const MethodChannel _petalEvents =
      MethodChannel(AdConfig.petalEventChannelName);

  AdProvider _provider = AdProvider.house;
  BannerAd? _adMobAd;
  bool _adMobLoaded = false;
  bool _adMobStarted = false;
  Timer? _petalTimer;

  @override
  void initState() {
    super.initState();
    _petalEvents.setMethodCallHandler(_onPetalEvent);
    _resolveProvider();
  }

  @override
  void dispose() {
    _petalTimer?.cancel();
    _petalEvents.setMethodCallHandler(null);
    _adMobAd?.dispose();
    super.dispose();
  }

  Future<void> _resolveProvider() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return; // widget tests / other platforms: house placeholder only
    }
    final hms = await NativeBridge.isHmsAvailable();
    final petalSdk = hms && await NativeBridge.isPetalAdsAvailable();
    if (!mounted) return;
    if (petalSdk) {
      setState(() => _provider = AdProvider.petal);
      _petalTimer = Timer(AdConfig.petalLoadTimeout, () {
        if (mounted && _provider == AdProvider.petal) _loadAdMobFallback();
      });
    } else {
      _loadAdMobFallback();
    }
  }

  Future<dynamic> _onPetalEvent(MethodCall call) async {
    if (!mounted) return null;
    switch (call.method) {
      case 'onPetalBannerLoaded':
        _petalTimer?.cancel();
        break;
      case 'onPetalBannerFailed':
        _loadAdMobFallback();
        break;
    }
    return null;
  }

  Future<void> _loadAdMobFallback() async {
    if (_adMobStarted) return;
    _adMobStarted = true;
    _petalTimer?.cancel();
    if (mounted) setState(() => _provider = AdProvider.admob);
    try {
      await MobileAds.instance.initialize();
      final ad = BannerAd(
        adUnitId: AdConfig.adMobBannerAdUnitId,
        size: AdSize.banner, // 320x50 standard banner
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) setState(() => _adMobLoaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('AdMob banner failed: $error');
            ad.dispose();
            if (mounted) {
              setState(() {
                _provider = AdProvider.house;
                _adMobLoaded = false;
              });
            }
          },
        ),
      );
      _adMobAd = ad;
      await ad.load();
    } catch (e) {
      debugPrint('AdMob init failed: $e');
      if (mounted) setState(() => _provider = AdProvider.house);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AdConfig.bannerHeight,
          child: Center(child: _content()),
        ),
      ),
    );
  }

  Widget _content() {
    switch (_provider) {
      case AdProvider.petal:
        // Native Huawei Petal Ads BannerView (see MainActivity /
        // PetalBannerViewFactory on the Android side). Sized 320x50.
        return const SizedBox(
          width: 320,
          height: 50,
          child: AndroidView(
            viewType: AdConfig.petalBannerViewType,
            layoutDirection: TextDirection.ltr,
            creationParams: {
              'adUnitId': AdConfig.petalBannerAdUnitId,
              'heightDp': 50,
            },
            creationParamsCodec: StandardMessageCodec(),
          ),
        );
      case AdProvider.admob:
        if (_adMobLoaded && _adMobAd != null) {
          return SizedBox(
            width: _adMobAd!.size.width.toDouble(),
            height: _adMobAd!.size.height.toDouble(),
            child: AdWidget(ad: _adMobAd!),
          );
        }
        return _houseStrip(loading: true);
      case AdProvider.house:
        return _houseStrip(loading: false);
    }
  }

  /// Fallback strip shown while an ad loads / when no network fills.
  /// Keeps the pinned 56dp area meaningful instead of blank.
  Widget _houseStrip({required bool loading}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade500),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text('Ad',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            loading ? widget.strings.t('adLoading') : widget.strings.t('adsNote'),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
