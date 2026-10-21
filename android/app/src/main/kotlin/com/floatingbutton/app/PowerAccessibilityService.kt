package com.floatingbutton.app

import android.accessibilityservice.AccessibilityService
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.view.accessibility.AccessibilityEvent

/**
 * Used ONLY to perform GLOBAL_ACTION_LOCK_SCREEN when the user taps
 * "LOCK SCREEN". It does not inspect window content
 * (canRetrieveWindowContent=false in accessibility_service_config.xml).
 */
class PowerAccessibilityService : AccessibilityService() {

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onDestroy() {
        if (instance === this) instance = null
        super.onDestroy()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) = Unit

    override fun onInterrupt() = Unit

    fun lockScreen(): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            performGlobalAction(GLOBAL_ACTION_LOCK_SCREEN)
        } else {
            false
        }

    companion object {
        @Volatile
        var instance: PowerAccessibilityService? = null
            private set

        fun isServiceConnected(): Boolean = instance != null

        /** Mirrors MainActivity's Device Admin check (used by QS tiles). */
        fun isDeviceAdminActive(context: Context): Boolean = try {
            val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE)
                as? DevicePolicyManager
            dpm?.isAdminActive(
                ComponentName(context, PowerDeviceAdminReceiver::class.java),
            ) == true
        } catch (e: Exception) {
            false
        }

        /**
         * Synchronous lock used by the Quick Settings tile and launcher
         * shortcuts: Device Admin `lockNow()` first (instant), then the
         * bound AccessibilityService global action.
         */
        fun lockScreen(context: Context): Boolean {
            if (isDeviceAdminActive(context)) {
                try {
                    val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE)
                        as? DevicePolicyManager
                    dpm?.lockNow()
                    return true
                } catch (e: Exception) {
                    // Fall through to the accessibility service.
                }
            }
            return instance?.lockScreen() == true
        }
    }
}
