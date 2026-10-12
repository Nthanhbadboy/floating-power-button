package com.example.floating_power_button.overlay

import android.app.Service
import android.content.Intent
import android.content.res.Configuration
import android.graphics.PixelFormat
import android.os.IBinder
import android.util.Log
import android.view.Gravity
import android.view.WindowManager
import kotlin.math.roundToInt

/**
 * Owns the overlay window that carries the floating button.
 *
 * Design note (Milestone 1):
 *  This is a *started* service, not a foreground service. Drawing a
 *  TYPE_APPLICATION_OVERLAY window only requires the SYSTEM_ALERT_WINDOW grant;
 *  Android does not require a foreground service for it. Using a plain started
 *  service avoids the Android 14+ foreground service type declaration
 *  (`specialUse` + Play Console justification) and the mandatory ongoing
 *  notification for a feature that does not need user-visible background work.
 *  Trade-off: a started service is killed sooner under memory pressure, so
 *  START_STICKY is returned and the window is rebuilt with the stored position
 *  when Android restarts the service. Revisit with real-device evidence in
 *  Milestone 4 (service lifecycle).
 */
class OverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var button: FloatingButtonView? = null
    private var layoutParams: WindowManager.LayoutParams? = null

    private val store: OverlayStore by lazy { OverlayStore(this) }

    override fun onCreate() {
        super.onCreate()
        OverlayRuntime.serviceRunning = true
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!OverlayPermissions.canDrawOverlays(this)) {
            // Permission can be revoked while the service is alive; hide safely and
            // stop instead of pretending the button is available.
            Log.w(TAG, "SYSTEM_ALERT_WINDOW is not granted; stopping overlay service")
            stopSelf()
            return START_NOT_STICKY
        }
        if (!showOverlay()) {
            stopSelf()
            return START_NOT_STICKY
        }
        return START_STICKY
    }

    /** The overlay is not exposed through a binder. */
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        // Rotation / display-area changes can invalidate the stored position.
        clampToDisplay()
    }

    override fun onDestroy() {
        removeOverlay()
        OverlayRuntime.serviceRunning = false
        super.onDestroy()
    }

    private fun showOverlay(): Boolean {
        if (button != null) return true

        val windowContext = OverlayDisplay.windowContext(this)
        val wm = windowContext.getSystemService(WindowManager::class.java)
        val density = resources.displayMetrics.density
        val size = (BUTTON_SIZE_DP * density).roundToInt()
        val display = OverlayDisplay.size(windowContext)
        val margin = (EDGE_MARGIN_DP * density).roundToInt()

        val params =
            WindowManager.LayoutParams(
                size,
                size,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or Gravity.START
            }

        val start =
            if (store.hasPosition) {
                val stored = store.readPosition()
                OverlayPositionCalculator.clamp(
                    stored.x,
                    stored.y,
                    display.x,
                    display.y,
                    size,
                    size,
                )
            } else {
                OverlayPositionCalculator.defaultPosition(
                    display.x,
                    display.y,
                    size,
                    size,
                    margin,
                )
            }
        params.x = start.x
        params.y = start.y

        val view = FloatingButtonView(windowContext).apply {
            onTap = ::onButtonTapped
            onMove = { dx, dy -> moveButton(dx, dy) }
            onMoveFinished = { persistPosition() }
        }

        return try {
            wm.addView(view, params)
            windowManager = wm
            button = view
            layoutParams = params
            store.savePosition(params.x, params.y)
            true
        } catch (error: RuntimeException) {
            // SecurityException when SYSTEM_ALERT_WINDOW is missing, BadTokenException
            // when the window context is rejected by the platform. The view was not
            // attached, so there is nothing to clean up here.
            Log.e(TAG, "Unable to add overlay window", error)
            false
        }
    }

    private fun removeOverlay() {
        val view = button
        val wm = windowManager
        button = null
        windowManager = null
        layoutParams = null
        if (view != null && wm != null && view.isAttachedToWindow) {
            try {
                wm.removeView(view)
            } catch (error: RuntimeException) {
                Log.w(TAG, "Unable to remove overlay window", error)
            }
        }
    }

    private fun moveButton(dx: Int, dy: Int) {
        val wm = windowManager ?: return
        val view = button ?: return
        val params = layoutParams ?: return
        val display = OverlayDisplay.size(OverlayDisplay.windowContext(this))
        val clamped =
            OverlayPositionCalculator.clamp(
                params.x + dx,
                params.y + dy,
                display.x,
                display.y,
                view.width,
                view.height,
            )
        params.x = clamped.x
        params.y = clamped.y
        try {
            wm.updateViewLayout(view, params)
        } catch (error: RuntimeException) {
            Log.e(TAG, "Unable to move overlay window", error)
        }
    }

    private fun clampToDisplay() {
        val wm = windowManager ?: return
        val view = button ?: return
        val params = layoutParams ?: return
        val display = OverlayDisplay.size(OverlayDisplay.windowContext(this))
        val clamped =
            OverlayPositionCalculator.clamp(
                params.x,
                params.y,
                display.x,
                display.y,
                view.width,
                view.height,
            )
        if (clamped.x == params.x && clamped.y == params.y) return
        params.x = clamped.x
        params.y = clamped.y
        try {
            wm.updateViewLayout(view, params)
            store.savePosition(params.x, params.y)
        } catch (error: RuntimeException) {
            Log.e(TAG, "Unable to re-clamp overlay window", error)
        }
    }

    private fun persistPosition() {
        val params = layoutParams ?: return
        store.savePosition(params.x, params.y)
    }

    private fun onButtonTapped() {
        // Milestone 1 scope: gestures only. The action itself (Lock Screen /
        // Control Volume) is selected and bound in Milestone 2/3.
        Log.d(TAG, "Floating button tapped; action binding is added in Milestone 2")
    }

    private companion object {
        const val TAG = "OverlayService"
        const val BUTTON_SIZE_DP = 56
        const val EDGE_MARGIN_DP = 16
    }
}