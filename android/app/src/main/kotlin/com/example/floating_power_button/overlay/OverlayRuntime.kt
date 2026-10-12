package com.example.floating_power_button.overlay

/**
 * Process-wide overlay facts shared between [OverlayService] and the Flutter
 * bridge. The overlay service runs in the same process as the Flutter activity,
 * so a volatile flag is enough to report the real service state (an
 * ActivityManager lookup would be deprecated and unreliable here).
 */
internal object OverlayRuntime {
    @Volatile
    var serviceRunning: Boolean = false
}