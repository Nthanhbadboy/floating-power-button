import '../constants/app_info.dart';

/// In-app Privacy Policy text (EN / VI / Simplified Chinese).
///
/// The same content is published online in `docs/privacy-policy.html`.
/// Header fields are interpolated from [AppInfo] so the App Name and
/// Developer Name can never drift from AppGallery Connect (review issue #3),
/// and the Simplified Chinese version satisfies review issue #2.
class PrivacyPolicyContent {
  const PrivacyPolicyContent._();

  static String textFor(String languageCode) {
    switch (languageCode) {
      case 'vi':
        return _vi;
      case 'zh':
        return _zh;
      case 'es':
        return _es;
      default:
        return _en;
    }
  }

  static const String _headerEn = '''
Developer Name: ${AppInfo.developerName}
App Name: ${AppInfo.appName}
Contact Email: ${AppInfo.contactEmail}
Last updated: October 21, 2026''';

  static const String _headerEs = '''
Nombre del desarrollador: ${AppInfo.developerName}
Nombre de la aplicación: ${AppInfo.appName}
Correo de contacto: ${AppInfo.contactEmail}
Última actualización: 21 de octubre de 2026''';

  static const String _headerVi = '''
Tên nhà phát triển: ${AppInfo.developerName}
Tên ứng dụng: ${AppInfo.appName}
Email liên hệ: ${AppInfo.contactEmail}
Cập nhật lần cuối: 21/10/2026''';

  static const String _headerZh = '''
开发者名称：${AppInfo.developerName}
应用名称：${AppInfo.appName}
联系邮箱：${AppInfo.contactEmail}
最后更新：2026年10月21日''';

  static const String _en = '''
$_headerEn

1. Introduction
${AppInfo.shortAppName} ("the App"), developed by ${AppInfo.developerName}, helps you lock your screen instantly and open the system volume panel without pressing physical buttons.

2. Data we collect
The App does NOT collect, store, or transmit any personal data. It has no user accounts, no analytics SDKs, and does not track you. All settings (language, keep-alive preference, privacy consent) are stored only on your device.

3. Permissions and why they are used
• Accessibility Service: used only to perform the screen-lock action (GLOBAL_ACTION_LOCK_SCREEN) and to show the volume panel when you tap the App's buttons. The App never reads screen content, typed text, or accessibility events for any other purpose.
• Device Administrator (optional): if you enable it, it is used only as a fallback to lock the screen and to prevent the system from killing the App. The App never wipes data or changes your password.
• Foreground Service (optional, OFF by default): only starts after you read the explanation dialog and tap "Enable". If you leave it enabled, it may resume after a device reboot or app update; you can turn it off at any time in the app. It shows a persistent notification with Lock / Volume shortcuts so the system does not kill the accessibility service.
• Ignore Battery Optimization (optional): helps the App keep working on devices with aggressive battery management (Huawei/EMUI, Xiaomi/MIUI, Samsung, OPPO, Vivo).
• Notifications: used only for the persistent keep-alive notification described above.

4. Advertising
The App may show banner ads (Google AdMob / Huawei Petal Ads). Ad providers may process device advertising identifiers according to their own privacy policies. The App itself does not share personal data with them.

5. Data sharing
We do not sell, trade, or share your personal data with third parties, because we do not collect any.

6. Children
The App is a general utility and does not knowingly collect data from anyone, including children.

7. Changes
We may update this policy; the latest version is always available at ${AppInfo.privacyPolicyUrl}.

8. Contact
${AppInfo.developerName} — ${AppInfo.contactEmail}
''';

  static const String _vi = '''
$_headerVi

1. Giới thiệu
${AppInfo.shortAppName} ("Ứng dụng"), do ${AppInfo.developerName} phát triển, giúp bạn khóa màn hình ngay lập tức và mở thanh trượt âm lượng hệ thống mà không cần bấm phím cứng.

2. Dữ liệu chúng tôi thu thập
Ứng dụng KHÔNG thu thập, lưu trữ hay truyền bất kỳ dữ liệu cá nhân nào. Ứng dụng không có tài khoản người dùng, không tích hợp SDK phân tích và không theo dõi bạn. Mọi cài đặt (ngôn ngữ, tùy chọn chạy nền, đồng ý chính sách) chỉ lưu trên thiết bị của bạn.

3. Quyền truy cập và mục đích sử dụng
• Dịch vụ Trợ năng (Accessibility): chỉ dùng để khóa màn hình (GLOBAL_ACTION_LOCK_SCREEN) và hiển thị thanh âm lượng khi bạn chạm vào nút của Ứng dụng. Ứng dụng không bao giờ đọc nội dung màn hình, văn bản đã nhập hay sự kiện trợ năng cho mục đích khác.
• Quản trị thiết bị / Device Administrator (tùy chọn): nếu bạn bật, chỉ dùng làm phương án dự phòng để khóa màn hình và tránh bị hệ thống đóng ứng dụng. Ứng dụng không bao giờ xóa dữ liệu hay đổi mật khẩu của bạn.
• Dịch vụ chạy nền / Foreground Service (tùy chọn, mặc định TẮT): chỉ khởi chạy sau khi bạn đọc hộp thoại giải thích và bấm "Cho phép (Enable)". Nếu bạn để công tắc bật, dịch vụ có thể tự khôi phục sau khi máy khởi động lại hoặc ứng dụng được cập nhật; bạn có thể tắt bất cứ lúc nào trong ứng dụng. Nếu bạn để công tắc bật, dịch vụ có thể tự khôi phục sau khi máy khởi động lại hoặc ứng dụng được cập nhật; bạn có thể tắt bất cứ lúc nào trong ứng dụng. Dịch vụ hiển thị thông báo cố định với nút Khóa / Âm lượng để hệ thống không đóng dịch vụ trợ năng.
• Bỏ qua Tối ưu pin (tùy chọn): giúp Ứng dụng hoạt động ổn định trên các máy quản lý pin gắt gao (Huawei/EMUI, Xiaomi/MIUI, Samsung, OPPO, Vivo).
• Thông báo: chỉ dùng cho thông báo chạy nền cố định nêu trên.

4. Quảng cáo
Ứng dụng có thể hiển thị quảng cáo banner (Google AdMob / Huawei Petal Ads). Nhà cung cấp quảng cáo có thể xử lý mã định danh quảng cáo của thiết bị theo chính sách riêng của họ. Bản thân Ứng dụng không chia sẻ dữ liệu cá nhân với họ.

5. Chia sẻ dữ liệu
Chúng tôi không bán, trao đổi hay chia sẻ dữ liệu cá nhân của bạn với bên thứ ba, vì chúng tôi không thu thập dữ liệu nào.

6. Trẻ em
Ứng dụng là tiện ích phổ thông và không cố ý thu thập dữ liệu từ bất kỳ ai, kể cả trẻ em.

7. Thay đổi chính sách
Chúng tôi có thể cập nhật chính sách này; phiên bản mới nhất luôn có tại ${AppInfo.privacyPolicyUrl}.

8. Liên hệ
${AppInfo.developerName} — ${AppInfo.contactEmail}
''';

  // Simplified Chinese — REQUIRED because "Chinese mainland" is selected in
  // AppGallery Connect -> Version information -> Country/Region for release.
  // (Alternative: uncheck Chinese mainland there; keep this translation and
  // the market can stay selected.)
  static const String _zh = '''
$_headerZh

1. 简介
${AppInfo.shortAppName}（以下简称"本应用"）由 ${AppInfo.developerName} 开发，帮助您无需按实体按键即可立即锁定屏幕并打开系统音量面板。

2. 我们收集的数据
本应用不收集、不存储、也不传输任何个人数据。本应用没有用户账户，不集成任何数据分析 SDK，也不会跟踪您。所有设置（语言、后台保活偏好、隐私同意状态）仅保存在您的设备上。

3. 权限及用途
• 无障碍服务：仅用于执行锁屏操作（GLOBAL_ACTION_LOCK_SCREEN），以及在您点击本应用按钮时显示音量面板。本应用绝不会读取屏幕内容、输入文本或将无障碍事件用于其他任何目的。
• 设备管理员（可选）：如您启用，仅作为锁屏的备用方式，并防止系统关闭本应用。本应用绝不会清除数据或更改您的密码。
• 前台服务（可选，默认关闭）：仅在您阅读说明对话框并点击"启用（Enable）"后才会启动。如果您保持开启状态，该服务可能会在设备重启或应用更新后恢复运行；您可以随时在应用中将其关闭。该服务会显示一条带有"锁定 / 音量"快捷按钮的常驻通知，以防止系统关闭无障碍服务。
• 忽略电池优化（可选）：帮助本应用在电池管理较严格的设备（华为/EMUI、小米/MIUI、三星、OPPO、Vivo）上稳定运行。
• 通知：仅用于上述常驻保活通知。

4. 广告
本应用可能展示横幅广告（Google AdMob / 华为 Petal Ads）。广告提供商可能根据其自身的隐私政策处理设备广告标识符。本应用本身不会向其分享个人数据。

5. 数据共享
我们不出售、交易或与第三方共享您的个人数据，因为我们根本不收集任何数据。

6. 儿童
本应用为通用工具类应用，不会有意收集包括儿童在内的任何人的数据。

7. 政策变更
我们可能更新本政策，最新版本始终发布于 ${AppInfo.privacyPolicyUrl}。

8. 联系我们
${AppInfo.developerName} — ${AppInfo.contactEmail}
''';

  static const String _es = '''
$_headerEs

1. Introducción
${AppInfo.shortAppName} ("la Aplicación"), desarrollada por ${AppInfo.developerName}, te ayuda a bloquear la pantalla al instante y abrir el panel de volumen del sistema sin pulsar botones físicos.

2. Datos que recopilamos
La Aplicación NO recopila, almacena ni transmite ningún dato personal. No tiene cuentas de usuario, ni SDK de análisis, y no te rastrea. Todos los ajustes (idioma, preferencia de actividad en segundo plano, consentimiento de privacidad) se guardan solo en tu dispositivo.

3. Permisos y para qué se usan
• Servicio de Accesibilidad: solo para bloquear la pantalla (GLOBAL_ACTION_LOCK_SCREEN) y mostrar el panel de volumen cuando tocas los botones de la Aplicación. La Aplicación nunca lee el contenido de la pantalla, el texto escrito ni los eventos de accesibilidad con ningún otro fin.
• Administrador del dispositivo (opcional): solo como alternativa para bloquear la pantalla y evitar que el sistema cierre la Aplicación. La Aplicación nunca borra datos ni cambia tu contraseña.
• Servicio en primer plano (opcional, DESACTIVADO por defecto): solo se inicia después de que leas el diálogo de explicación y toques "Activar". Si lo dejas activado, puede reanudarse después de reiniciar el dispositivo o actualizar la aplicación; puedes desactivarlo en cualquier momento en la aplicación. Muestra una notificación permanente con accesos de Bloqueo / Volumen para que el sistema no cierre el servicio de accesibilidad.
• Ignorar la optimización de batería (opcional): ayuda a que la Aplicación siga funcionando en dispositivos con gestión agresiva de la batería (Huawei/EMUI, Xiaomi/MIUI, Samsung, OPPO, Vivo).
• Notificaciones: solo para la notificación permanente descrita arriba.

4. Publicidad
La Aplicación puede mostrar anuncios tipo banner (Google AdMob / Huawei Petal Ads). Los proveedores de anuncios pueden procesar los identificadores publicitarios del dispositivo según sus propias políticas de privacidad. La Aplicación en sí no comparte datos personales con ellos.

5. Compartir datos
No vendemos, intercambiamos ni compartimos tus datos personales con terceros, porque no recopilamos ninguno.

6. Menores
La Aplicación es una utilidad general y no recopila conscientemente datos de nadie, incluidos los menores.

7. Cambios
Podemos actualizar esta política; la versión más reciente está siempre en ${AppInfo.privacyPolicyUrl}.

8. Contacto
${AppInfo.developerName} — ${AppInfo.contactEmail}
''';
}
