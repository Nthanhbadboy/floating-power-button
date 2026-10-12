package com.example.floating_power_button

import com.example.floating_power_button.overlay.OverlayController
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts the Flutter UI and exposes the overlay bridge over a MethodChannel.
 *
 * Channel: `floating_power_button/overlay`
 *  - `getState()` -> {overlayPermissionGranted, enabled, serviceRunning}
 *  - `setEnabled(enabled: bool)` -> {ok: bool, error: String?}
 *  - `openOverlaySettings()` -> bool (a system screen was opened)
 */
class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getState" -> result.success(OverlayController.state(this))

                    "setEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled")
                        if (enabled == null) {
                            result.error(
                                ERROR_INVALID_ARGUMENT,
                                "Missing 'enabled' argument",
                                null,
                            )
                        } else {
                            handleSetEnabled(enabled, result)
                        }
                    }

                    "openOverlaySettings" ->
                        result.success(OverlayController.openOverlaySettings(this))

                    else -> result.notImplemented()
                }
            }
    }

    private fun handleSetEnabled(enabled: Boolean, result: MethodChannel.Result) {
        val applied = OverlayController.setEnabled(this, enabled)
        val state = OverlayController.state(this)
        result.success(
            buildMap<String, Any> {
                put("ok", applied)
                if (!applied) {
                    val permissionGranted =
                        state["overlayPermissionGranted"] == true
                    put(
                        "error",
                        if (permissionGranted) {
                            OverlayController.ERROR_START_FAILED
                        } else {
                            OverlayController.ERROR_OVERLAY_PERMISSION_MISSING
                        },
                    )
                }
            },
        )
    }

    private companion object {
        const val CHANNEL = "floating_power_button/overlay"
        const val ERROR_INVALID_ARGUMENT = "invalid_argument"
    }
}