/// Minimal hand-rolled localization for the compliance-critical strings
/// (privacy consent + foreground-service consent) plus the main UI.
/// Supported: English (en), Vietnamese (vi), Simplified Chinese (zh).
class AppStrings {
  AppStrings(this.code);

  final String code;

  static const List<String> supportedCodes = ['en', 'vi', 'zh'];

  static String languageName(String code) => switch (code) {
        'vi' => 'VI',
        'zh' => '中文',
        _ => 'EN',
      };

  String get _pick => code;

  String t(String key) =>
      (_table[key]?[_pick] ?? _table[key]?['en'] ?? key)!;

  static const Map<String, Map<String, String>> _table = {
    'appTitle': {
      'en': 'Power & Volume',
      'vi': 'Power & Volume',
      'zh': '电源与音量',
    },
    // --- Review issue #1: first-launch privacy pop-up ---
    'welcome': {
      'en': 'Welcome to Power & Volume',
      'vi': 'Chào mừng bạn đến với Power & Volume',
      'zh': '欢迎使用 Power & Volume',
    },
    'privacyConsentBody': {
      'en':
          'To continue using the app, please read and agree to our Privacy Policy and Terms of Service.',
      'vi':
          'Để tiếp tục sử dụng, vui lòng đọc và đồng ý với Chính sách bảo mật (Privacy Policy) và Điều khoản dịch vụ.',
      'zh': '如需继续使用本应用，请阅读并同意我们的《隐私政策》和《服务条款》。',
    },
    'privacyPolicy': {
      'en': 'Privacy Policy',
      'vi': 'Chính sách bảo mật',
      'zh': '隐私政策',
    },
    'termsOfService': {
      'en': 'Terms of Service',
      'vi': 'Điều khoản dịch vụ',
      'zh': '服务条款',
    },
    'agree': {'en': 'Agree', 'vi': 'Đồng ý', 'zh': '同意'},
    'decline': {'en': 'Decline', 'vi': 'Từ chối', 'zh': '不同意'},
    // --- Review issue #4: foreground service consent ---
    'fgDialogTitle': {
      'en': 'Enable Keep-Alive Foreground Service?',
      'vi': 'Bật dịch vụ chạy nền Keep-Alive?',
      'zh': '启用后台保活服务？',
    },
    'fgDialogBody': {
      'en':
          'Enabling the background service helps the app keep a persistent notification to control volume and lock the screen without being closed by the OS. Do you want to activate it?',
      'vi':
          'Bật dịch vụ chạy nền sẽ giúp ứng dụng tạo thanh thông báo cố định để điều khiển âm lượng và khóa màn hình không bị hệ điều hành đóng. Bạn có muốn kích hoạt không?',
      'zh':
          '启用后台服务后，本应用会显示一条常驻通知，用于控制音量和锁定屏幕，避免被操作系统关闭。是否要启用？',
    },
    'enable': {'en': 'Enable', 'vi': 'Cho phép', 'zh': '启用'},
    'cancel': {'en': 'Cancel', 'vi': 'Hủy', 'zh': '取消'},
    'keepAliveTitle': {
      'en': 'Keep-Alive Foreground Service',
      'vi': 'Dịch vụ chạy nền Keep-Alive',
      'zh': '后台保活服务',
    },
    'keepAliveSubtitle': {
      'en':
          'Protects accessibility service from being killed when swiped away',
      'vi': 'Bảo vệ dịch vụ trợ năng không bị đóng khi vuốt tắt ứng dụng',
      'zh': '防止无障碍服务在划掉应用时被关闭',
    },
    // --- Home ---
    'lockScreen': {'en': 'LOCK SCREEN', 'vi': 'KHÓA MÀN HÌNH', 'zh': '锁定屏幕'},
    'lockScreenSub': {
      'en': 'Instant screen lock (0ms)',
      'vi': 'Khóa màn hình ngay (0ms)',
      'zh': '立即锁屏（0毫秒）',
    },
    'volumePanel': {
      'en': 'VOLUME PANEL',
      'vi': 'THANH ÂM LƯỢNG',
      'zh': '音量面板',
    },
    'volumePanelSub': {
      'en': 'Show system volume slider',
      'vi': 'Hiện thanh trượt âm lượng hệ thống',
      'zh': '显示系统音量滑块',
    },
    'protectedTitle': {
      'en': 'Protected 24/7',
      'vi': 'Được bảo vệ 24/7',
      'zh': '全天候保护',
    },
    'notProtectedTitle': {
      'en': 'Not fully protected yet',
      'vi': 'Chưa được bảo vệ đầy đủ',
      'zh': '尚未完全受保护',
    },
    'protectedBody': {
      'en': 'Services remain active on {device}, immune to swipe-to-kill.',
      'vi':
          'Dịch vụ vẫn hoạt động trên {device}, không bị tắt khi vuốt đóng ứng dụng.',
      'zh': '服务在 {device} 上保持运行，划掉应用也不会被关闭。',
    },
    'notProtectedBody': {
      'en':
          'Enable the Accessibility Service (and optionally the Keep-Alive service) below so {device} does not kill the app.',
      'vi':
          'Hãy bật Dịch vụ Trợ năng (và tùy chọn dịch vụ Keep-Alive) bên dưới để {device} không đóng ứng dụng.',
      'zh': '请在下方启用无障碍服务（并可选择保活服务），以免 {device} 关闭本应用。',
    },
    'permissionsTitle': {
      'en': 'Permissions & Keep-Alive Settings',
      'vi': 'Quyền & Cài đặt chạy nền',
      'zh': '权限与保活设置',
    },
    'accessibility': {
      'en': 'Accessibility Service',
      'vi': 'Dịch vụ Trợ năng',
      'zh': '无障碍服务',
    },
    'accessibilityActive': {
      'en': 'Active (Global Action lock)',
      'vi': 'Đang hoạt động (Khóa bằng Global Action)',
      'zh': '已启用（全局操作锁屏）',
    },
    'accessibilityInactive': {
      'en': 'Inactive (Tap to enable)',
      'vi': 'Chưa bật (Chạm để bật)',
      'zh': '未启用（点击启用）',
    },
    'deviceAdmin': {
      'en': 'Device Administrator',
      'vi': 'Quản trị thiết bị',
      'zh': '设备管理员',
    },
    'deviceAdminActive': {
      'en': 'Active',
      'vi': 'Đang hoạt động',
      'zh': '已启用',
    },
    'deviceAdminInactive': {
      'en': 'Inactive (Recommended to prevent kill)',
      'vi': 'Chưa bật (Nên bật để tránh bị đóng)',
      'zh': '未启用（建议启用以防被关闭）',
    },
    'ignoreBattery': {
      'en': 'Ignore Battery Optimization',
      'vi': 'Bỏ qua Tối ưu pin',
      'zh': '忽略电池优化',
    },
    'ignoreBatteryOff': {
      'en': 'Unrestricted by system',
      'vi': 'Không bị hệ thống hạn chế',
      'zh': '不受系统限制',
    },
    'ignoreBatteryOn': {
      'en': 'Optimized by system (Tap to disable)',
      'vi': 'Đang bị tối ưu bởi hệ thống (Chạm để tắt)',
      'zh': '正被系统优化（点击关闭）',
    },
    'guideCardTitle': {
      'en': 'Device-Specific Background Guide',
      'vi': 'Hướng dẫn chạy nền theo dòng máy',
      'zh': '分机型后台运行指南',
    },
    'guideCardBody': {
      'en':
          'Configure App Launch, Unrestricted Battery, and Lock in Recents to prevent the OS from killing background services.',
      'vi':
          'Cấu hình Khởi chạy ứng dụng, Pin không hạn chế và Khóa trong Đa nhiệm để hệ điều hành không đóng dịch vụ chạy nền.',
      'zh': '请配置应用启动管理、电池无限制，并在最近任务中锁定应用，防止系统关闭后台服务。',
    },
    'viewInstructions': {
      'en': 'View Step-by-Step Instructions',
      'vi': 'Xem hướng dẫn từng bước',
      'zh': '查看分步说明',
    },
    'hideInstructions': {
      'en': 'Hide Instructions',
      'vi': 'Ẩn hướng dẫn',
      'zh': '收起说明',
    },
    'guideAutoDetect': {
      'en':
          'Auto-detected your device. You can also select another manufacturer below:',
      'vi':
          'Đã tự động nhận diện thiết bị của bạn. Bạn cũng có thể chọn hãng khác bên dưới:',
      'zh': '已自动检测到您的设备。您也可以在下方选择其他品牌：',
    },
    'yourDevice': {'en': 'Your Device', 'vi': 'Máy của bạn', 'zh': '您的设备'},
    'setupStepsFor': {
      'en': 'Setup steps for {brand}:',
      'vi': 'Các bước cài đặt cho {brand}:',
      'zh': '{brand} 设置步骤：',
    },
    'supportTitle': {
      'en': 'Support Developer (Optional)',
      'vi': 'Ủng hộ nhà phát triển (Tùy chọn)',
      'zh': '支持开发者（可选）',
    },
    'supportBody': {
      'en':
          'This utility is 100% free. If you find it helpful, feel free to buy the developer a coffee via Payoneer or VietQR!',
      'vi':
          'Ứng dụng hoàn toàn miễn phí 100%. Nếu thấy hữu ích, hãy mời nhà phát triển một ly cà phê qua Payoneer hoặc VietQR!',
      'zh': '本工具 100% 免费。如果对您有帮助，欢迎通过 Payoneer 或 VietQR 请开发者喝杯咖啡！',
    },
    'adsNote': {
      'en': 'Ads keep this utility 100% free for everyone',
      'vi': 'Quảng cáo giúp ứng dụng miễn phí 100% cho mọi người',
      'zh': '广告让本工具对所有人免费',
    },
    'lockNeedsAccessibility': {
      'en':
          'Lock needs the Accessibility Service (or Device Admin). Opening settings…',
      'vi':
          'Khóa màn hình cần Dịch vụ Trợ năng (hoặc Quản trị thiết bị). Đang mở cài đặt…',
      'zh': '锁屏需要无障碍服务（或设备管理员）。正在打开设置…',
    },
    'fgStarted': {
      'en': 'Keep-Alive Foreground Service started',
      'vi': 'Đã bật dịch vụ chạy nền Keep-Alive',
      'zh': '后台保活服务已启动',
    },
    'fgStopped': {
      'en': 'Keep-Alive Foreground Service stopped',
      'vi': 'Đã tắt dịch vụ chạy nền Keep-Alive',
      'zh': '后台保活服务已停止',
    },
    'fgStartFailed': {
      'en': 'Could not start the foreground service on this device',
      'vi': 'Không khởi chạy được dịch vụ chạy nền trên thiết bị này',
      'zh': '无法在此设备上启动前台服务',
    },
  };
}
