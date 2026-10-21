package com.nguyenminhthanh.power_volume

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder

/**
 * Keep-Alive Foreground Service.
 *
 * Review issue #4 compliance:
 *  - NOT started from Application/Activity onCreate, NOT on boot.
 *  - The only entry point is MainActivity's `startForegroundService`
 *    method-channel call, which Dart only invokes after the user taps
 *    "Enable" in the explanation dialog (switch defaults to OFF).
 *  - Shows the persistent "Power & Volume Active" notification with
 *    LOCK / VOLUME actions (see screenshots).
 */
class KeepAliveForegroundService : Service() {

    override fun onCreate() {
        super.onCreate()
        createChannel()
        startForeground(NOTIFICATION_ID, buildNotification())
        isRunning = true
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Refresh the notification if the system restarts the service.
        startForeground(NOTIFICATION_ID, buildNotification())
        return START_STICKY
    }

    override fun onDestroy() {
        isRunning = false
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

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
            .setSmallIcon(android.R.drawable.ic_lock_power_off)
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

        @Volatile
        var isRunning: Boolean = false
            private set
    }
}
