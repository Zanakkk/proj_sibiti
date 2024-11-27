package proj.seb.sibiti

import android.content.Context
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.database.ContentObserver
import android.app.NotificationManager
import android.content.Intent
import android.widget.Toast


class MainActivity : FlutterActivity() {

    companion object {
        private const val LOCK_TASK_CHANNEL = "proj.seb.sibiti/locktask"
        private const val AUDIO_CHANNEL = "proj.seb.sibiti/audio"
    }

    private val volumeObserver = object : ContentObserver(null) {
        override fun onChange(selfChange: Boolean) {
            setAudioToSpeaker() // Ensure audio is always directed to the speaker
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Set the stream volume to control audio output
        setVolumeControlStream(AudioManager.STREAM_MUSIC)

        applyInitialSettings()
        registerVolumeObserver()

        // Cek apakah aplikasi sudah memiliki izin DND
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (!notificationManager.isNotificationPolicyAccessGranted) {
            // Jika izin tidak diberikan, arahkan pengguna ke pengaturan DND
            val intent = Intent(android.provider.Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
            startActivityForResult(intent, 123) // Meminta izin untuk mengelola DND
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterVolumeObserver()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            enableImmersiveMode() // Hide system UI elements
        } else {
            startLockTaskMode() // Lock the task when window loses focus
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 123) { // Memastikan request code yang benar
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (notificationManager.isNotificationPolicyAccessGranted) {
                // Izin diberikan, Anda dapat mengubah pengaturan DND
                disableDoNotDisturb()
            } else {
                // Tindakan jika izin tidak diberikan, misalnya beri tahu pengguna
                Toast.makeText(this, "Izin untuk mengelola Do Not Disturb tidak diberikan", Toast.LENGTH_LONG).show()
            }
        }
    }


    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        // Disable volume buttons
        if (keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            setAudioToSpeaker() // Ensure the audio stays on speaker
            return true // Prevent default volume actions
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun onBackPressed() {
        // Prevent the back button from being pressed
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCK_TASK_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLockTask" -> {
                    startLockTaskMode()
                    lockScreenshot(true)
                    result.success(null)
                }
                "stopLockTask" -> {
                    stopLockTaskMode()
                    lockScreenshot(false)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playThroughSpeaker" -> {
                    setAudioToSpeaker() // Ensure audio is played through the speaker
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun applyInitialSettings() {
        keepScreenOn()
        startLockTaskMode()
        lockScreenshot(true)
        enableImmersiveMode()
        setAudioToSpeaker()
        disableDoNotDisturb()
    }

    private fun registerVolumeObserver() {
        contentResolver.registerContentObserver(
            android.provider.Settings.System.CONTENT_URI,
            true,
            volumeObserver
        )
    }

    private fun unregisterVolumeObserver() {
        contentResolver.unregisterContentObserver(volumeObserver)
    }

    private fun enableImmersiveMode() {
        window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_FULLSCREEN or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                View.SYSTEM_UI_FLAG_LOW_PROFILE // Hide system UI elements like volume bar
    }

    private fun lockScreenshot(enable: Boolean) {
        val flag = WindowManager.LayoutParams.FLAG_SECURE
        if (enable) window.setFlags(flag, flag) else window.clearFlags(flag)
    }

    private fun keepScreenOn() {
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    private fun disableDoNotDisturb() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (notificationManager.isNotificationPolicyAccessGranted) {
            // Create a valid NotificationPolicy object
            val policy = NotificationManager.Policy(
                NotificationManager.Policy.PRIORITY_CATEGORY_MESSAGES,
                NotificationManager.Policy.PRIORITY_CATEGORY_CALLS,
                NotificationManager.Policy.PRIORITY_CATEGORY_REMINDERS,
                NotificationManager.Policy.PRIORITY_CATEGORY_EVENTS
            )
            notificationManager.setNotificationPolicy(policy) // Apply the policy
        } else {
            // Request permission to access Do Not Disturb settings
            val intent = Intent(android.provider.Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
            startActivity(intent)
        }
    }

    private fun startLockTaskMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                startLockTask()
            } catch (e: IllegalStateException) {
                e.printStackTrace()
            }
        }
    }

    private fun stopLockTaskMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                stopLockTask()
            } catch (e: IllegalStateException) {
                e.printStackTrace()
            }
        }
    }

    private fun setAudioToSpeaker() {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        with(audioManager) {
            // Force audio to speaker
            mode = AudioManager.MODE_IN_COMMUNICATION
            isSpeakerphoneOn = true

            // Mute the volume if wired headset is connected
            if (isWiredHeadsetOn()) {
                setStreamVolume(AudioManager.STREAM_MUSIC, 0, 0)
            }

            // Mute Bluetooth if it's active
            if (isBluetoothA2dpOn || isBluetoothScoOn) {
                stopBluetoothSco()
                isBluetoothScoOn = false
                setStreamVolume(AudioManager.STREAM_MUSIC, 0, 0)
            }

            // Set maximum volume for speaker
            val maxVolume = getStreamMaxVolume(AudioManager.STREAM_MUSIC)
            setStreamVolume(AudioManager.STREAM_MUSIC, maxVolume, 0)
        }
    }

    // Helper to detect wired headset connection
    private fun isWiredHeadsetOn(): Boolean {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        return audioManager.isWiredHeadsetOn
    }
}
