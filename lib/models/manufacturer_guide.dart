class ManufacturerGuide {
  const ManufacturerGuide({
    required this.id,
    required this.displayName,
    required this.brandKeywords,
    required this.settingsButton,
    required this.steps,
  });

  /// huawei | xiaomi | samsung | oppo | vivo — also used by the native
  /// `openManufacturerSettings` method.
  final String id;
  final String displayName;

  /// Lower-case keywords matched against Build.MANUFACTURER / Build.BRAND.
  final List<String> brandKeywords;

  /// "Open … Settings" button label per language code.
  final Map<String, String> settingsButton;

  /// Step-by-step instructions per language code (en / vi / zh).
  final Map<String, List<String>> steps;

  String settingsButtonFor(String code) =>
      settingsButton[code] ?? settingsButton['en']!;

  List<String> stepsFor(String code) => steps[code] ?? steps['en']!;

  bool matches(String manufacturer, String brand) {
    final haystack = '$manufacturer $brand'.toLowerCase();
    return brandKeywords.any(haystack.contains);
  }
}
