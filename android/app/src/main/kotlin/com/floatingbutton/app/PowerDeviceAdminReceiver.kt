package com.floatingbutton.app

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast

/** Optional fallback lock. Only the `force-lock` policy is declared. */
class PowerDeviceAdminReceiver : DeviceAdminReceiver() {
    override fun onEnabled(context: Context, intent: Intent) {
        Toast.makeText(context, "Power & Volume: Device Admin enabled", Toast.LENGTH_SHORT).show()
    }

    override fun onDisabled(context: Context, intent: Intent) {
        Toast.makeText(context, "Power & Volume: Device Admin disabled", Toast.LENGTH_SHORT).show()
    }
}
