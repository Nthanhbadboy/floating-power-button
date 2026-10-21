package com.floatingbutton.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioManager

/** Handles the LOCK / VOLUME buttons on the persistent notification. */
class NotificationActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        when (intent?.action) {
            ACTION_LOCK -> {
                val locked = PowerAccessibilityService.instance?.lockScreen() == true
                if (!locked) {
                    // Fall back to simply opening the app so the user can
                    // enable Accessibility / Device Admin.
                    context.startActivity(
                        Intent(context, MainActivity::class.java)
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                    )
                }
            }
            ACTION_VOLUME -> {
                val audio =
                    context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
                audio.adjustStreamVolume(
                    AudioManager.STREAM_MUSIC,
                    AudioManager.ADJUST_SAME,
                    AudioManager.FLAG_SHOW_UI,
                )
            }
        }
    }

    companion object {
        const val ACTION_LOCK = "com.floatingbutton.app.ACTION_LOCK"
        const val ACTION_VOLUME = "com.floatingbutton.app.ACTION_VOLUME"
    }
}
