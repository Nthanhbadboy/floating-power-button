package com.example.floating_power_button.overlay

import android.content.Context
import android.graphics.Point
import android.hardware.display.DisplayManager
import android.os.Build
import android.view.Display
import android.view.WindowManager

/**
 * Helpers around the display the overlay window lives on.
 *
 * A TYPE_APPLICATION_OVERLAY window is a non-activity window, so it must be added
 * through a "window context": a context associated with a Display (the Android
 * `Context` reference documents this). A Service has no window token of its own,
 * so the context is derived from the default display.
 */
internal object OverlayDisplay {

    fun windowContext(context: Context): Context {
        val appContext = context.applicationContext
        val manager = appContext.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
        val display = manager.getDisplay(Display.DEFAULT_DISPLAY)
        return if (display != null) appContext.createDisplayContext(display) else appContext
    }

    /**
     * Size of the display area the overlay is positioned in.
     *
     * The overlay window is placed with Gravity.TOP|Gravity.START, so x/y are
     * offsets from the top-left of this area. Clamping in [OverlayPositionCalculator]
     * keeps the button reachable even if this area differs slightly from the one
     * the window is finally laid out in (multi-window, cutouts, OEM variations).
     */
    fun size(windowContext: Context): Point {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val bounds =
                windowContext.getSystemService(WindowManager::class.java).maximumWindowMetrics.bounds
            return Point(bounds.width(), bounds.height())
        }
        val metrics = windowContext.resources.displayMetrics
        return Point(metrics.widthPixels, metrics.heightPixels)
    }
}