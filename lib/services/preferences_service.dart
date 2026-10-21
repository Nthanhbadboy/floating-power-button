import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for every persisted flag that is
/// relevant to the Huawei AppGallery review.
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static Future<PreferencesService> load() async =>
      PreferencesService(await SharedPreferences.getInstance());

  // --- Review issue #1: first-launch Privacy Policy consent -----------------
  static const String _kPrivacyAccepted = 'is_privacy_accepted';

  /// `false` (default) until the user taps "Agree" in the first-launch
  /// Privacy Policy pop-up. The home UI is never shown before that.
  bool get isPrivacyAccepted => _prefs.getBool(_kPrivacyAccepted) ?? false;

  Future<void> setPrivacyAccepted(bool value) =>
      _prefs.setBool(_kPrivacyAccepted, value);

  // --- Review issue #4: Foreground Service explicit consent -----------------
  static const String _kKeepAliveEnabled = 'keep_alive_foreground_enabled';
  static const String _kForegroundConsent = 'foreground_service_consented';

  /// Keep-Alive Foreground Service is OFF by default on a fresh install.
  /// It may only become `true` after the explanation dialog is confirmed.
  bool get keepAliveEnabled => _prefs.getBool(_kKeepAliveEnabled) ?? false;

  /// Whether the user has explicitly tapped "Enable" in the foreground
  /// service explanation dialog at least once.
  bool get hasForegroundServiceConsent =>
      _prefs.getBool(_kForegroundConsent) ?? false;

  Future<void> setKeepAliveEnabled(bool value) async {
    await _prefs.setBool(_kKeepAliveEnabled, value);
    if (value) await _prefs.setBool(_kForegroundConsent, true);
  }

  // --- Language (en / vi / zh) ----------------------------------------------
  static const String _kLanguage = 'app_language_code';

  String get languageCode => _prefs.getString(_kLanguage) ?? 'en';

  Future<void> setLanguageCode(String code) =>
      _prefs.setString(_kLanguage, code);
}
