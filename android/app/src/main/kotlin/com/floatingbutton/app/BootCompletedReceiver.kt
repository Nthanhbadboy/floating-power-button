package com.floatingbutton.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * Restores the Keep-Alive Foreground Service after reboot / app update.
 *
 * Imported from the PC v2 project, with the AppGallery issue #4 safeguard
 * tightened: this receiver NEVER enables the service by itself. It only
 * resumes the service when the user has previously tapped "Enable" in the
 * in-app explanation dialog (persisted by [KeepAliveForegroundService]).
 * On a fresh install the flag is absent/false and nothing is started.
 */
class BootCompletedReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        if (action != Intent.ACTION_BOOT_COMPLETED &&
            action != Intent.ACTION_MY_PACKAGE_REPLACED
        ) {
            return
        }

        if (!KeepAliveForegroundService.isUserEnabled(context)) {
            Log.i(TAG, "Keep-Alive not user-enabled; skipping restore after $action.")
            return
        }

        try {
            val serviceIntent = Intent(context, KeepAliveForegroundService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
            Log.i(TAG, "Keep-Alive service restored after $action (user had enabled it).")
        } catch (e: Exception) {
            // Some OEM / Android 12+ background-start restrictions may still
            // block the restart; the in-app switch remains the source of truth
            // and will restart it on next launch. Never crash the receiver.
            Log.w(TAG, "Could not restore Keep-Alive service after $action", e)
        }
    }

    private companion object {
        const val TAG = "BootCompletedReceiver"
    }
}
