package com.tabata_timer.hiit_timer

import android.app.ActivityManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Bundle
import android.os.IBinder
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.collections.HashMap


class MainActivity : FlutterActivity() {
    companion object {
        const val CHANNEL = "com.highutil.interval_timer/timer"
    }

    private lateinit var service: TimerService
    private var isBound = false

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            val binder = service as TimerService.TimerBinder
            this@MainActivity.service = binder.getService()
            this@MainActivity.service.remainingTime.observe(this@MainActivity, Observer {
                val data = mapOf("remainingTime" to it, "isRunning" to this@MainActivity.service.isRunning, "tts" to this@MainActivity.service.currentTts)
                MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).invokeMethod("tick", data)
            })
            isBound = true
        }

        override fun onServiceDisconnected(arg0: ComponentName) {

        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (isServiceRunning(TimerService::class.java)) {
            Intent(this, TimerService::class.java).also { intent ->
                bindService(intent, connection, Context.BIND_AUTO_CREATE)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (isBound) {
            unbindService(connection)
            isBound = false
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    Intent(this, TimerService::class.java).also { intent ->
                        val timesInMillisecond = call.argument<List<Int>>("times")?.toIntArray()
                        intent.putExtra("times", timesInMillisecond)
                        intent.putExtra("ttses", call.argument<List<String>>("ttses")?.toTypedArray())
                        intent.putExtra("repeatCount", call.argument<Int>("repeatCount"))
                        val settings = call.argument<HashMap<String, Any>>("settings")!!
                        intent.putExtra("warning3Remaining", settings["warning3Remaining"] as Boolean)
                        intent.putExtra("vibration", settings["vibration"] as Boolean)
                        ContextCompat.startForegroundService(this, intent)
                        bindService(intent, connection, Context.BIND_AUTO_CREATE)
                    }
                    result.success(true)
                }
                "pause" -> {
                    if (isBound)
                        service.pause()
                    result.success(true)
                }
                "resume" -> {
                    if (isBound)
                        service.resume()
                    result.success(true)
                }
                "stop" -> {
                    if (isBound) {
                        service.stop()
                        unbindService(connection)
                        Intent(this, TimerService::class.java).also { intent ->
                            stopService(intent)
                        }
                        isBound = false
                    }
                    result.success(true)
                }
                "forward" -> {
                    if (isBound) {
                        val duration = call.argument<Int>("forwardDuration")!!
                        service.forward(duration)
                    }
                }
                "rewind" -> {
                    if (isBound) {
                        val duration = call.argument<Int>("rewindDuration")!!
                        service.rewind(duration)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    @Suppress("DEPRECATION")
    fun <T> Context.isServiceRunning(service: Class<T>): Boolean {
        return (getSystemService(FlutterActivity.ACTIVITY_SERVICE) as ActivityManager)
                .getRunningServices(Integer.MAX_VALUE)
                .any { it -> it.service.className == service.name }
    }
}


