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

class MainActivity : FlutterActivity() {

    companion object {
        private const val LOCK_TASK_CHANNEL = "proj.seb.sibiti/locktask"
        private const val AUDIO_CHANNEL = "proj.seb.sibiti/audio"
    }

    private val volumeObserver = object : ContentObserver(null) {
        override fun onChange(selfChange: Boolean) {
            setAudioToSpeaker()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        applyInitialSettings()
        registerVolumeObserver()
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterVolumeObserver()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) enableImmersiveMode() else startLockTaskMode()
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            setAudioToSpeaker()
            return true // Blokir tombol volume
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun onBackPressed() {
        // Mencegah aksi tombol back
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
                    setAudioToSpeaker()
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
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
    }

    private fun lockScreenshot(enable: Boolean) {
        val flag = WindowManager.LayoutParams.FLAG_SECURE
        if (enable) window.setFlags(flag, flag) else window.clearFlags(flag)
    }

    private fun keepScreenOn() {
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
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
            // Paksa audio ke speaker
            mode = AudioManager.MODE_IN_COMMUNICATION
            isSpeakerphoneOn = true

            // Matikan volume jika earphone terhubung
            if (isWiredHeadsetOn()) {
                setStreamVolume(AudioManager.STREAM_MUSIC, 0, 0)
            }

            // Matikan Bluetooth jika aktif
            if (isBluetoothA2dpOn || isBluetoothScoOn) {
                stopBluetoothSco()
                isBluetoothScoOn = false
                setStreamVolume(AudioManager.STREAM_MUSIC, 0, 0)
            }

            // Atur volume maksimum untuk speaker
            val maxVolume = getStreamMaxVolume(AudioManager.STREAM_MUSIC)
            setStreamVolume(AudioManager.STREAM_MUSIC, maxVolume, 0)
        }
    }

    // Helper untuk mendeteksi earphone kabel
    private fun isWiredHeadsetOn(): Boolean {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        return audioManager.isWiredHeadsetOn
    }

}
