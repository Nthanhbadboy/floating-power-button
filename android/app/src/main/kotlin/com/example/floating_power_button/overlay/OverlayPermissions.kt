package com.example.floating_power_button.overlay

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings

/**
 * Access to the "Display over other apps" (SYSTEM_ALERT_WINDOW) special permission.
 *
 * SYSTEM_ALERT_WINDOW is declared in the manifest and is granted by the user in
 * Android Settings; it is not a runtime dialog permission. The grant must always
 * be re-checked because the user (or an OEM) can revoke it at any time.
 */
internal object OverlayPermissions {

    /** True when this app is currently allowed to draw a TYPE_APPLICATION_OVERLAY window. */
    fun canDrawOverlays(context: Context): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else {
            true
        }

    /**
     * Intent that opens the system screen where the user enables the permission.
     *
     * From Android 11 the system ignores the `package:` URI and always opens the
     * top-level "Display over other apps" list, so the URI is only a best-effort
     * deep link on older versions.
     */
    fun settingsIntent(context: Context): Intent =
        Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:" + context.packageName),
        )
}