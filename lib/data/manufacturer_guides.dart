import '../models/manufacturer_guide.dart';

/// Device-Specific Background Guide (section 2 of the AppGallery fix plan).
///
/// Tabs: Huawei / Honor | Xiaomi / Redmi / POCO | Samsung |
///       OPPO / Realme | Vivo / iQOO
/// The tab matching the real device is auto-selected and badged
/// "Your Device".
class ManufacturerGuides {
  const ManufacturerGuides._();

  static const List<ManufacturerGuide> all = [
    // ---------------------------------------------------------------- Huawei
    ManufacturerGuide(
      id: 'huawei',
      displayName: 'Huawei / Honor',
      brandKeywords: ['huawei', 'honor'],
      settingsButton: {
        'en': 'Open Huawei Battery Settings',
        'vi': 'Mở Cài đặt Pin Huawei',
        'zh': '打开华为电池设置',
        'es': 'Abrir ajustes de batería de Huawei',
      },
      steps: {
        'en': [
          'Tap the button below to open Huawei Battery Settings (EMUI / HarmonyOS).',
          'Select "App launch".',
          'Find "Power & Volume" -> Turn OFF "Manage automatically".',
          'Turn ON all 3 manual options: Auto-launch, Secondary launch, Run in background.',
          'In Recent Apps overview: swipe down on the app card until the Lock icon 🔒 appears.',
        ],
        'vi': [
          'Nhấn nút bên dưới để mở Cài đặt Pin Huawei (EMUI / HarmonyOS).',
          'Vào mục "App launch (Khởi chạy ứng dụng)".',
          'Tìm "Power & Volume" -> Tắt "Manage automatically (Quản lý tự động)".',
          'Bật đủ 3 tùy chọn thủ công: Auto-launch (Tự khởi chạy), Secondary launch (Khởi chạy thứ cấp), Run in background (Chạy trong nền).',
          'Mở Ứng dụng gần đây (Recent Apps) -> Vuốt nhẹ thẻ ứng dụng xuống đến khi xuất hiện biểu tượng ổ khóa 🔒.',
        ],
        'zh': [
          '点击下方按钮打开华为电池设置（EMUI / HarmonyOS）。',
          '进入"应用启动管理"。',
          '找到"Power & Volume"，关闭"自动管理"。',
          '手动开启全部 3 项：自动启动、关联启动、允许后台活动。',
          '打开最近任务界面，下滑应用卡片，直到出现锁定图标 🔒。',
        ],
        'es': [
          'Toca el botón de abajo para abrir los Ajustes de batería de Huawei (EMUI / HarmonyOS).',
          'Selecciona «Inicio de aplicaciones» (App launch).',
          'Busca «Power & Volume» y desactiva «Gestionar automáticamente».',
          'Activa las 3 opciones manuales: Inicio automático, Inicio secundario y Ejecutar en segundo plano.',
          'En Aplicaciones recientes: desliza la tarjeta de la aplicación hacia abajo hasta que aparezca el icono de candado 🔒.',
        ],
      },
    ),
    // ---------------------------------------------------------------- Xiaomi
    ManufacturerGuide(
      id: 'xiaomi',
      displayName: 'Xiaomi / Redmi / POCO',
      brandKeywords: ['xiaomi', 'redmi', 'poco'],
      settingsButton: {
        'en': 'Open Xiaomi App Settings',
        'vi': 'Mở Cài đặt ứng dụng Xiaomi',
        'zh': '打开小米应用设置',
        'es': 'Abrir ajustes de Xiaomi',
      },
      steps: {
        'en': [
          'Long-press the Power & Volume icon on the home screen -> App Info.',
          'Turn ON "Autostart".',
          'Open "Battery Saver" -> change to "No restrictions".',
          'Open Recent Apps -> long-press the app card -> tap the Lock icon 🔒.',
        ],
        'vi': [
          'Giữ biểu tượng Power & Volume trên màn hình chính -> Thông tin ứng dụng (App Info).',
          'Bật công tắc "Tự khởi chạy (Autostart)".',
          'Chọn "Tiết kiệm pin (Battery Saver)" -> đổi thành "Không hạn chế (No restrictions)".',
          'Mở Ứng dụng gần đây -> nhấn giữ thẻ app -> bấm biểu tượng ổ khóa 🔒 để khóa ứng dụng.',
        ],
        'zh': [
          '在桌面长按 Power & Volume 图标 → 应用信息。',
          '开启"自启动"。',
          '进入"省电策略" → 改为"无限制"。',
          '打开最近任务 → 长按应用卡片 → 点击锁定图标 🔒。',
        ],
        'es': [
          'Mantén pulsado el icono de Power & Volume en la pantalla de inicio → Información de la aplicación.',
          'Activa «Inicio automático» (Autostart).',
          'Abre «Ahorro de batería» → cámbialo a «Sin restricciones».',
          'Abre Aplicaciones recientes → mantén pulsada la tarjeta → toca el icono de candado 🔒.',
        ],
      },
    ),
    // --------------------------------------------------------------- Samsung
    ManufacturerGuide(
      id: 'samsung',
      displayName: 'Samsung',
      brandKeywords: ['samsung'],
      settingsButton: {
        'en': 'Open Samsung App Settings',
        'vi': 'Mở Cài đặt ứng dụng Samsung',
        'zh': '打开三星应用设置',
        'es': 'Abrir ajustes de Samsung',
      },
      steps: {
        'en': [
          'Settings -> Device Care -> Battery.',
          'Background usage limits -> add Power & Volume to "Never sleeping apps".',
          'App Info -> Battery -> select "Unrestricted".',
        ],
        'vi': [
          'Cài đặt -> Chăm sóc thiết bị (Device Care) -> Pin (Battery).',
          'Giới hạn sử dụng trong nền (Background usage limits) -> thêm Power & Volume vào "Ứng dụng không bao giờ nghỉ (Never sleeping apps)".',
          'Thông tin ứng dụng -> Pin -> chuyển sang "Không hạn chế (Unrestricted)".',
        ],
        'zh': [
          '设置 → 设备维护 → 电池。',
          '后台使用限制 → 将 Power & Volume 加入"从不休眠的应用"。',
          '应用信息 → 电池 → 选择"不受限制"。',
        ],
        'es': [
          'Ajustes → Cuidado del dispositivo → Batería.',
          'Límites de uso en segundo plano → añade Power & Volume a «Aplicaciones que nunca duermen».',
          'Información de la aplicación → Batería → selecciona «Sin restricción».',
        ],
      },
    ),
    // ------------------------------------------------------------------ OPPO
    ManufacturerGuide(
      id: 'oppo',
      displayName: 'OPPO / Realme',
      brandKeywords: ['oppo', 'realme', 'oneplus'],
      settingsButton: {
        'en': 'Open OPPO App Settings',
        'vi': 'Mở Cài đặt ứng dụng OPPO',
        'zh': '打开 OPPO 应用设置',
        'es': 'Abrir ajustes de OPPO',
      },
      steps: {
        'en': [
          'Settings -> App Management -> Power & Volume.',
          'Battery usage -> enable "Allow background activity" and "Allow auto-launch".',
          'Open Recents -> tap the ⋮ menu on the app card -> choose "Lock".',
        ],
        'vi': [
          'Cài đặt -> Quản lý ứng dụng -> Power & Volume.',
          'Quản lý pin (Battery usage) -> bật "Cho phép hoạt động trong nền (Allow background activity)" và "Cho phép tự khởi chạy (Allow auto-launch)".',
          'Mở giao diện đa nhiệm (Recents) -> bấm nút 3 chấm trên thẻ ứng dụng -> chọn "Khóa (Lock)".',
        ],
        'zh': [
          '设置 → 应用管理 → Power & Volume。',
          '耗电管理 → 开启"允许后台运行"和"允许自启动"。',
          '打开最近任务 → 点击卡片上的 ⋮ 菜单 → 选择"锁定"。',
        ],
        'es': [
          'Ajustes → Gestión de aplicaciones → Power & Volume.',
          'Uso de la batería → activa «Permitir actividad en segundo plano» y «Permitir inicio automático».',
          'Abre Recientes → toca el menú ⋮ en la tarjeta de la aplicación → elige «Bloquear».',
        ],
      },
    ),
    // ------------------------------------------------------------------ Vivo
    ManufacturerGuide(
      id: 'vivo',
      displayName: 'Vivo / iQOO',
      brandKeywords: ['vivo', 'iqoo'],
      settingsButton: {
        'en': 'Open Vivo App Settings',
        'vi': 'Mở Cài đặt ứng dụng Vivo',
        'zh': '打开 Vivo 应用设置',
        'es': 'Abrir ajustes de Vivo',
      },
      steps: {
        'en': [
          'Settings -> Battery -> "High background power consumption".',
          'Find Power & Volume -> set to "Allowed".',
          'In Autostart settings, allow Power & Volume to start automatically.',
        ],
        'vi': [
          'Cài đặt -> Pin -> "Quản lý mức tiêu thụ điện năng trong nền (High background power consumption)".',
          'Tìm Power & Volume -> chuyển sang "Cho phép (Allowed)".',
          'Trong cài đặt Tự khởi chạy (Autostart), bật quyền tự chạy cho ứng dụng.',
        ],
        'zh': [
          '设置 → 电池 → "后台高耗电管理"。',
          '找到 Power & Volume → 设为"允许"。',
          '在自启动设置中，允许 Power & Volume 自动启动。',
        ],
        'es': [
          'Ajustes → Batería → «Alto consumo de energía en segundo plano».',
          'Busca Power & Volume → ajústalo a «Permitido».',
          'En los ajustes de Inicio automático, permite que Power & Volume se inicie solo.',
        ],
      },
    ),
  ];

  static ManufacturerGuide? detect(String manufacturer, String brand) {
    for (final guide in all) {
      if (guide.matches(manufacturer, brand)) return guide;
    }
    return null;
  }

  static ManufacturerGuide byId(String id) =>
      all.firstWhere((g) => g.id == id, orElse: () => all.first);
}
