package com.example.floating_power_button.overlay

import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Entry point used by the Flutter layer (see MainActivity's MethodChannel).
 *
 * Milestone 1 only needs: read state, start/stop the overlay, and open the
 * system screen where the overlay permission is granted.
 */
internal object OverlayController {

    const val ERROR_OVERLAY_PERMISSION_MISSING = "overlay_permission_missing"
    const val ERROR_START_FAILED = "overlay_start_failed"

    fun state(context: Context): Map<String, Any> {
        val store = OverlayStore(context)
        val permissionGranted = OverlayPermissions.canDrawOverlays(context)
        return mapOf(
            "overlayPermissionGranted" to permissionGranted,
            "enabled" to store.enabled,
            "serviceRunning" to OverlayRuntime.serviceRunning,
        )
    }

    /**
     * Enables or disables the floating button.
     *
     * Enabling stores the user's intent and starts the service only when the
     * overlay permission is currently granted; otherwise the call fails with
     * [ERROR_OVERLAY_PERMISSION_MISSING] so the UI can explain what is missing
     * instead of silently doing nothing.
     *
     * @return true when the requested state was applied.
     */
    fun setEnabled(context: Context, enabled: Boolean): Boolean {
        val store = OverlayStore(context)
        if (!enabled) {
            store.enabled = false
            stop(context)
            return true
        }
        if (!OverlayPermissions.canDrawOverlays(context)) {
            Log.w(TAG, "Cannot start overlay: SYSTEM_ALERT_WINDOW is not granted")
            return false
        }
        val started =
            try {
                context.startService(Intent(context, OverlayService::class.java))
                true
            } catch (error: RuntimeException) {
                // e.g. IllegalStateException on Android 8+ if called while the app is
                // in the background. Reported instead of being swallowed.
                Log.e(TAG, "Unable to start OverlayService", error)
                false
            }
        // Store what actually happened, so the Settings toggle never claims a
        // button that Android refused to show.
        store.enabled = started
        return started
    }

    fun stop(context: Context) {
        try {
            context.stopService(Intent(context, OverlayService::class.java))
        } catch (error: RuntimeException) {
            Log.w(TAG, "Unable to stop OverlayService", error)
        }
    }

    /** Opens the system "Display over other apps" screen; false if no activity handled it. */
    fun openOverlaySettings(context: Context): Boolean {
        val intent = OverlayPermissions.settingsIntent(context)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return try {
            context.startActivity(intent)
            true
        } catch (error: RuntimeException) {
            Log.w(TAG, "No activity for ACTION_MANAGE_OVERLAY_PERMISSION", error)
            false
        }
    }

    private const val TAG = "OverlayController"
}