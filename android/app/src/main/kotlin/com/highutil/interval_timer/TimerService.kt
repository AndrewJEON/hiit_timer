package com.highutil.interval_timer

import android.app.*
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.CountDownTimer
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import io.flutter.app.FlutterApplication

class TimerService : Service() {
    companion object {
        const val CHANNEL_ID = "CHANNEL_ID"
        const val NOTIFICATION_ID = 1
        const val STATE_RUNNING = "STATE_RUNNING"
        const val STATE_PAUSE = "STATE_PAUSE"
    }

    private val binder = TimerBinder()
    private lateinit var pendingIntent: PendingIntent
    private lateinit var notificationManager: NotificationManager

    private lateinit var remainingTimes: List<Int>
    private lateinit var timer: MyTimer<Int>
    private var index = 0
    private var repeatCount = 1

    private val _remainingTime = MutableLiveData<Int>()
    val remainingTime: LiveData<Int>
        get() = _remainingTime

    var timerState = STATE_RUNNING


    override fun onCreate() {
        pendingIntent = Intent(this, MainActivity::class.java).let { notificationIntent ->
            PendingIntent.getActivity(this, 0, notificationIntent, 0)
        }
        notificationManager = getSystemService(FlutterApplication.NOTIFICATION_SERVICE) as NotificationManager
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        val timesInMillisecond = intent.getIntArrayExtra("times")!!.toList()
        repeatCount = intent.getIntExtra("repeatCount", 1)
        remainingTimes = timesInMillisecond
        index = 0
        timer = object : MyTimer<Int>(1000L, { x -> remainingTimes[index] - x - 1 }) {
            override fun onTick(data: Int) {
                tick(data)
            }
        }
        timer.start()
        timerState = STATE_RUNNING
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent): IBinder? {
        return binder
    }

    override fun onDestroy() {
        timer.cancel()
        notificationManager.cancel(NOTIFICATION_ID)
    }

    fun pause() {
        timer.pause()
        timerState = STATE_PAUSE
    }

    fun resume() {
        timer.resume()
        timerState = STATE_RUNNING
    }

    fun stop() {
        timer.cancel()
    }

    private fun tick(data: Int) {
        if (data > 0) {
            notificationManager.notify(NOTIFICATION_ID, createNotification(data))
            _remainingTime.postValue(data)
        } else {
            if (index < remainingTimes.size - 1) {
                val remainingTime = remainingTimes[++index]
                notificationManager.notify(NOTIFICATION_ID, createNotification(remainingTime))
                timer.cancel()
                timer = object : MyTimer<Int>(1000L, { x -> remainingTimes[index] - x - 1 }) {
                    override fun onTick(data: Int) {
                        tick(data)
                    }
                }
                timer.start()
                _remainingTime.postValue(remainingTime)
            } else {
                when {
                    repeatCount > 1 -> {
                        repeatCount--
                        index = 0
                        val remainingTime = remainingTimes[index]
                        notificationManager.notify(NOTIFICATION_ID, createNotification(remainingTime))
                        timer.cancel()
                        timer = object : MyTimer<Int>(1000L, { x -> remainingTimes[index] - x - 1 }) {
                            override fun onTick(data: Int) {
                                tick(data)
                            }
                        }
                        timer.start()
                        _remainingTime.postValue(remainingTime)
                    }
                    repeatCount == -1 -> {
                        index = 0
                        val remainingTime = remainingTimes[index]
                        notificationManager.notify(NOTIFICATION_ID, createNotification(remainingTime))
                        timer.cancel()
                        timer = object : MyTimer<Int>(1000L, { x -> remainingTimes[index] - x - 1 }) {
                            override fun onTick(data: Int) {
                                tick(data)
                            }
                        }
                        timer.start()
                        _remainingTime.postValue(remainingTime)
                    }
                    else -> {
                        notificationManager.notify(NOTIFICATION_ID, createNotification(finish = true))
                        timer.cancel()
                        _remainingTime.postValue(-1)
                    }
                }
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val mChannel = NotificationChannel(CHANNEL_ID, "Timer Channel", NotificationManager.IMPORTANCE_LOW)
            notificationManager.createNotificationChannel(mChannel)
        }
    }

    private fun createNotification(remainingTime: Int = 0, finish: Boolean = false): Notification {
        val seconds = remainingTime % 60
        val minutes = remainingTime / 60 % 60
        val hours = remainingTime / (60 * 60) % 24
        val formattedTime = if (hours == 0) {
            "${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}"
        } else {
            "${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}"
        }

        return if (finish) {
            NotificationCompat.Builder(this, CHANNEL_ID)
                    .setContentTitle("Done")
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setContentIntent(pendingIntent)
                    .build()
        } else {
            NotificationCompat.Builder(this, CHANNEL_ID)
                    .setContentTitle(formattedTime)
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setContentIntent(pendingIntent)
                    .build()
        }
    }

    inner class TimerBinder : Binder() {
        fun getService(): TimerService = this@TimerService
    }
}