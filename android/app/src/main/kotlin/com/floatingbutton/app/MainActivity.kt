package com.floatingbutton.app

import android.Manifest
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // NOTE (review issue #4): deliberately NO startForegroundService()
        // here. The Keep-Alive service starts only from the method channel
        // below, after the user confirms the explanation dialog in Flutter.
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Huawei Petal Ads banner (platform view) — attempted first on HMS
        // devices; Dart falls back to AdMob if it fails (AdBannerHost).
        flutterEngine.platformViewsController.registry.registerViewFactory(
            PetalBannerViewFactory.VIEW_TYPE,
            PetalBannerViewFactory(flutterEngine.dartExecutor.binaryMessenger),
        )
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDeviceInfo" -> result.success(
                        mapOf(
                            "manufacturer" to Build.MANUFACTURER.orEmpty(),
                            "brand" to Build.BRAND.orEmpty(),
                            "model" to Build.MODEL.orEmpty(),
                        ),
                    )
                    "isAccessibilityEnabled" -> result.success(isAccessibilityEnabled())
                    "openAccessibilitySettings" -> {
                        open(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        result.success(null)
                    }
                    "isDeviceAdminActive" -> result.success(isDeviceAdminActive())
                    "requestDeviceAdmin" -> {
                        requestDeviceAdmin()
                        result.success(null)
                    }
                    "isIgnoringBatteryOptimizations" ->
                        result.success(isIgnoringBatteryOptimizations())
                    "requestIgnoreBatteryOptimizations" -> {
                        requestIgnoreBatteryOptimizations()
                        result.success(null)
                    }
                    "openAppDetailsSettings" -> {
                        openAppDetails()
                        result.success(null)
                    }
                    "openManufacturerSettings" -> {
                        openManufacturerSettings(call.argument<String>("guideId"))
                        result.success(null)
                    }
                    "lockScreen" -> result.success(lockScreen())
                    "showVolumePanel" -> {
                        showVolumePanel()
                        result.success(null)
                    }
                    "startForegroundService" -> result.success(startKeepAlive())
                    "stopForegroundService" -> {
                        stopService(Intent(this, KeepAliveForegroundService::class.java))
                        result.success(null)
                    }
                    "isForegroundServiceRunning" ->
                        result.success(KeepAliveForegroundService.isRunning)
                    "isHmsAvailable" -> result.success(isHmsAvailable())
                    "isPetalAdsAvailable" -> result.success(isPetalAdsAvailable())
                    else -> result.notImplemented()
                }
            }
    }

    // ------------------------------------------------------------------ lock
    private fun lockScreen(): Boolean {
        PowerAccessibilityService.instance?.let { if (it.lockScreen()) return true }
        if (isDeviceAdminActive()) {
            val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            dpm.lockNow()
            return true
        }
        return false
    }

    private fun showVolumePanel() {
        val audio = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audio.adjustStreamVolume(
            AudioManager.STREAM_MUSIC,
            AudioManager.ADJUST_SAME,
            AudioManager.FLAG_SHOW_UI,
        )
    }

    // ------------------------------------------------------- foreground svc
    private fun startKeepAlive(): Boolean = try {
        // Android 13+: ask for the notification permission in context (the
        // user just tapped "Enable" in the explanation dialog).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1002)
        }
        val intent = Intent(this, KeepAliveForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
        true
    } catch (e: Exception) {
        false
    }

    // ------------------------------------------------------------- permissions
    private fun isAccessibilityEnabled(): Boolean {
        if (PowerAccessibilityService.instance != null) return true
        val enabled = try {
            Settings.Secure.getInt(
                contentResolver,
                Settings.Secure.ACCESSIBILITY_ENABLED,
            ) == 1
        } catch (e: Settings.SettingNotFoundException) {
            false
        }
        if (!enabled) return false
        val services = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false
        val expected = ComponentName(this, PowerAccessibilityService::class.java)
        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(services)
        for (entry in splitter) {
            val name = ComponentName.unflattenFromString(entry) ?: continue
            if (name.packageName == expected.packageName &&
                name.className == expected.className
            ) return true
        }
        return false
    }

    private fun isDeviceAdminActive(): Boolean {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        return dpm.isAdminActive(ComponentName(this, PowerDeviceAdminReceiver::class.java))
    }

    private fun requestDeviceAdmin() {
        val component = ComponentName(this, PowerDeviceAdminReceiver::class.java)
        if (isDeviceAdminActive()) return
        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
            putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, component)
            putExtra(
                DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                "Optional: lets Power & Volume lock the screen and avoid being closed by the system. It never wipes data.",
            )
        }
        startActivity(intent)
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    private fun requestIgnoreBatteryOptimizations() {
        if (isIgnoringBatteryOptimizations()) {
            openAppDetails()
            return
        }
        try {
            @Suppress("BatteryLife")
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(intent)
        } catch (e: Exception) {
            open(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
        }
    }

    // ------------------------------------------- OEM battery / autostart pages
    /**
     * Opens the closest OEM screen for the Device-Specific Background Guide.
     * Every candidate is tried in order; App Info is the universal fallback.
     */
    private fun openManufacturerSettings(guideId: String?) {
        val candidates: List<Intent> = when (guideId) {
            "huawei" -> listOf(
                component(
                    "com.huawei.systemmanager",
                    "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity",
                ),
                component(
                    "com.huawei.systemmanager",
                    "com.huawei.systemmanager.optimize.process.ProtectActivity",
                ),
            )
            "xiaomi" -> listOf(
                component(
                    "com.miui.securitycenter",
                    "com.miui.permcenter.autostart.AutoStartManagementActivity",
                ),
            )
            "oppo" -> listOf(
                component(
                    "com.coloros.safecenter",
                    "com.coloros.safecenter.startupapp.StartupAppListActivity",
                ),
                component(
                    "com.oppo.safe",
                    "com.oppo.safe.permission.startup.StartupAppListActivity",
                ),
            )
            "vivo" -> listOf(
                component(
                    "com.vivo.permissionmanager",
                    "com.vivo.permissionmanager.activity.BgStartUpManagerActivity",
                ),
                component(
                    "com.iqoo.secure",
                    "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity",
                ),
            )
            else -> emptyList() // Samsung / stock Android: App Info is correct.
        }
        for (intent in candidates) {
            try {
                startActivity(intent)
                return
            } catch (e: Exception) {
                // Try the next OEM entry point.
            }
        }
        openAppDetails()
    }

    // ------------------------------------------------------------- ads / HMS
    private fun isHmsAvailable(): Boolean {
        val brand = (Build.MANUFACTURER + " " + Build.BRAND).lowercase()
        val isHuaweiBrand = brand.contains("huawei") || brand.contains("honor")
        if (!isHuaweiBrand) return false
        return try {
            packageManager.getPackageInfo("com.huawei.hwid", 0)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun isPetalAdsAvailable(): Boolean = try {
        Class.forName("com.huawei.hms.ads.HwAds")
        true
    } catch (e: Exception) {
        false
    }

    // ---------------------------------------------------------------- helpers
    private fun component(pkg: String, cls: String): Intent =
        Intent().setComponent(ComponentName(pkg, cls))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

    private fun open(action: String) {
        try {
            startActivity(Intent(action).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        } catch (e: Exception) {
            openAppDetails()
        }
    }

    private fun openAppDetails() {
        startActivity(
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
        )
    }

    companion object {
        private const val CHANNEL = "power_volume/native"
    }
}
