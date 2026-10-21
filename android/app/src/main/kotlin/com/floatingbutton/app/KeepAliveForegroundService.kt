package com.floatingbutton.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

/**
 * Keep-Alive Foreground Service.
 *
 * Review issue #4 compliance:
 *  - NOT started from Application/Activity onCreate and NOT enabled
 *    automatically on boot. [BootCompletedReceiver] may only *resume*
 *    this service after a reboot/update when the user has previously
 *    tapped "Enable" in the explanation dialog (switch defaults to OFF).
 *  - The first entry point is MainActivity's `startForegroundService`
 *    method-channel call, which Dart only invokes after the user taps
 *    "Enable" in the explanation dialog (switch defaults to OFF).
 *  - Shows the persistent "Power & Volume Active" notification with
 *    LOCK / VOLUME actions (see screenshots).
 */
class KeepAliveForegroundService : Service() {

    override fun onCreate() {
        super.onCreate()
        createChannel()
        startAsForeground()
        isRunning = true
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Refresh the notification if the system restarts the service.
        createChannel()
        startAsForeground()
        isRunning = true
        return START_STICKY
    }

    override fun onDestroy() {
        isRunning = false
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun startAsForeground() {
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Power & Volume Active",
                NotificationManager.IMPORTANCE_LOW,
            ).apply { description = "Persistent Lock & Volume quick controls" }
            getSystemService(NotificationManager::class.java)
                ?.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val openApp = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        fun action(code: String, requestCode: Int) = PendingIntent.getBroadcast(
            this,
            requestCode,
            Intent(this, NotificationActionReceiver::class.java).setAction(code),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION") Notification.Builder(this)
        }
        return builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Power & Volume Active")
            .setContentText("Tap for quick controls • Lock & Volume available here")
            .setContentIntent(openApp)
            .setOngoing(true)
            .addAction(0, "LOCK", action(NotificationActionReceiver.ACTION_LOCK, 1))
            .addAction(0, "VOLUME", action(NotificationActionReceiver.ACTION_VOLUME, 2))
            .build()
    }

    companion object {
        private const val CHANNEL_ID = "power_volume_keep_alive"
        private const val NOTIFICATION_ID = 1001

        // Native mirror of the in-app Keep-Alive switch so that
        // BootCompletedReceiver can resume the service after reboot/update
        // ONLY when the user previously enabled it. The PC v2 app stored
        // this flag in "prefs_power_button" and is honoured as a fallback.
        private const val PREFS_NAME = "power_volume_keep_alive"
        private const val KEY_USER_ENABLED = "user_enabled"
        private const val LEGACY_PREFS_NAME = "prefs_power_button"
        private const val LEGACY_KEY_USER_ENABLED = "keep_alive_enabled"

        fun isUserEnabled(context: Context): Boolean {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            if (prefs.contains(KEY_USER_ENABLED)) {
                return prefs.getBoolean(KEY_USER_ENABLED, false)
            }
            val legacy = context.getSharedPreferences(LEGACY_PREFS_NAME, Context.MODE_PRIVATE)
            return legacy.contains(LEGACY_KEY_USER_ENABLED) &&
                legacy.getBoolean(LEGACY_KEY_USER_ENABLED, false)
        }

        fun setUserEnabled(context: Context, enabled: Boolean) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putBoolean(KEY_USER_ENABLED, enabled)
                .apply()
        }

        @Volatile
        var isRunning: Boolean = false
            private set
    }
}
