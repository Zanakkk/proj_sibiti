package proj.seb.sibiti

import android.accessibilityservice.AccessibilityService
import android.view.KeyEvent
import android.view.accessibility.AccessibilityEvent
import android.content.Intent
import android.util.Log

class MyAccesibilityService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val packageName = event?.packageName?.toString()
        if (packageName != "proj.seb.sibiti") {
            Log.d("AccessibilityService", "Detected another app: $packageName. Returning to exam mode.")
            // Kembali ke aplikasi
            val intent = packageManager.getLaunchIntentForPackage("proj.seb.sibiti")
            intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
    }

    override fun onKeyEvent(event: KeyEvent): Boolean {
        // Blokir tombol Back dan Recent Apps
        return when (event.keyCode) {
            KeyEvent.KEYCODE_BACK, KeyEvent.KEYCODE_APP_SWITCH -> true
            else -> super.onKeyEvent(event)
        }
    }

    override fun onInterrupt() {
        // Tidak ada tindakan tambahan
    }
}
