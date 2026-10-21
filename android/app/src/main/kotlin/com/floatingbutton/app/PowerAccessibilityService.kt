package com.floatingbutton.app

import android.accessibilityservice.AccessibilityService
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
    }
}
