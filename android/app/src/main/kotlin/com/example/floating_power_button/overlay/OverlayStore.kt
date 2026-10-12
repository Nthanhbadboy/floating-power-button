package com.example.floating_power_button.overlay

import android.content.Context

/**
 * Small persistence layer for the overlay (native side, SharedPreferences).
 *
 * Milestone 1 stores only what the overlay itself needs:
 *  - [enabled]: the user's intent (Settings toggle).
 *  - [x]/[y]: last known position, restored when the service starts again.
 */
internal class OverlayStore(context: Context) {

    private val prefs =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    var enabled: Boolean
        get() = prefs.getBoolean(KEY_ENABLED, false)
        set(value) {
            prefs.edit().putBoolean(KEY_ENABLED, value).apply()
        }

    /** True when a position was stored before (avoids restoring an arbitrary 0,0). */
    val hasPosition: Boolean
        get() = prefs.contains(KEY_X) && prefs.contains(KEY_Y)

    fun savePosition(x: Int, y: Int) {
        prefs.edit().putInt(KEY_X, x).putInt(KEY_Y, y).apply()
    }

    fun readPosition(): OverlayPosition = OverlayPosition(prefs.getInt(KEY_X, 0), prefs.getInt(KEY_Y, 0))

    private companion object {
        const val PREFS_NAME = "floating_button_overlay"
        const val KEY_ENABLED = "enabled"
        const val KEY_X = "position_x"
        const val KEY_Y = "position_y"
    }
}