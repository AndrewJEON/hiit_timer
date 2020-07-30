package com.highutil.interval_timer

import android.app.*
import android.content.Intent
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.speech.tts.TextToSpeech
import androidx.core.app.NotificationCompat
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import io.flutter.app.FlutterApplication
import java.util.*

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
    private lateinit var ttses: List<String>
    private lateinit var timer: MyTimer<Int>
    private lateinit var tts: TextToSpeech
    private lateinit var toneGenerator: ToneGenerator
    private var index = 0
    private var repeatCount = 1
    private var isTtsInitialized = false

    private val _remainingTime = MutableLiveData<Int>()
    val remainingTime: LiveData<Int>
        get() = _remainingTime

    var isRunning = false
    var currentTts = ""


    override fun onCreate() {
        pendingIntent = Intent(this, MainActivity::class.java).let { notificationIntent ->
            PendingIntent.getActivity(this, 0, notificationIntent, 0)
        }
        notificationManager = getSystemService(FlutterApplication.NOTIFICATION_SERVICE) as NotificationManager
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())


        toneGenerator = ToneGenerator(AudioManager.STREAM_ALARM, 100)
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        val timesInMillisecond = intent.getIntArrayExtra("times")!!.toList()
        ttses = intent.getStringArrayExtra("ttses")!!.toList()
        repeatCount = intent.getIntExtra("repeatCount", 1)
        remainingTimes = timesInMillisecond
        index = 0
        timer = object : MyTimer<Int>(1000L, { x -> remainingTimes[index] - x - 1 }) {
            override fun onTick(data: Int) {
                tick(data)
            }
        }
        timer.start()
        isRunning = true

        tts = TextToSpeech(this) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts.language = Locale.US
                tts.speak(ttses[index], TextToSpeech.QUEUE_FLUSH, null, "")
                isTtsInitialized = true
            }
        }
        currentTts = ttses[0]
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
        isRunning = false
    }

    fun resume() {
        timer.resume()
        isRunning = true
    }

    fun stop() {
        timer.cancel()
        tts.shutdown()
        toneGenerator.release()
    }

    fun forward(sec: Int) {
        timer.computationCount += sec
        val result = remainingTimes[index] - timer.computationCount
        if (result < 1) {
            if (index < remainingTimes.size - 1) {
                notificationManager.notify(NOTIFICATION_ID, createNotification(remainingTimes[index + 1]))
                _remainingTime.value = remainingTimes[index + 1]
            } else {
                when {
                    repeatCount > 1 || repeatCount == -1 -> {
                        notificationManager.notify(NOTIFICATION_ID, createNotification(remainingTimes[0]))
                        _remainingTime.value = remainingTimes[0]
                    }
                    else -> {
                        notificationManager.notify(NOTIFICATION_ID, createNotification(finish = true))
                        _remainingTime.value = -1
                    }
                }
            }
        } else {
            notificationManager.notify(NOTIFICATION_ID, createNotification(result))
            _remainingTime.value = result
        }
    }

    fun rewind(sec: Int) {
        if (remainingTimes[index] - (timer.computationCount - sec) > remainingTimes[index]) {
            timer.computationCount = 0
        } else {
            timer.computationCount -= sec
        }
        val result = remainingTimes[index] - timer.computationCount
        notificationManager.notify(NOTIFICATION_ID, createNotification(result))
        _remainingTime.value = result
    }

    private fun tick(data: Int) {
        if (data > 0) {
            if (isTtsInitialized) {
                when (data) {
                    3 -> tts.speak("3", TextToSpeech.QUEUE_FLUSH, null, "")
                    2 -> tts.speak("2", TextToSpeech.QUEUE_FLUSH, null, "")
                    1 -> tts.speak("1", TextToSpeech.QUEUE_FLUSH, null, "")
                }
            }
            notificationManager.notify(NOTIFICATION_ID, createNotification(data))
            _remainingTime.postValue(data)
        } else {
            if (index < remainingTimes.size - 1) {
                val remainingTime = remainingTimes[++index]
                timer.cancel()
                timer = object : MyTimer<Int>(1000L, { x -> remainingTimes[index] - x - 1 }) {
                    override fun onTick(data: Int) {
                        tick(data)
                    }
                }
                timer.start()
                currentTts = ttses[index]
                if (ttses[index].isEmpty()) {
                    toneGenerator.startTone(ToneGenerator.TONE_CDMA_PIP, 150)
                } else {
                    if (isTtsInitialized) {
                        tts.speak(ttses[index], TextToSpeech.QUEUE_FLUSH, null, "")
                    }
                }

                notificationManager.notify(NOTIFICATION_ID, createNotification(remainingTime))
                _remainingTime.postValue(remainingTime)
            } else {
                when {
                    repeatCount > 1 -> {
                        repeatCount--
                        index = 0
                        val remainingTime = remainingTimes[index]
                        timer.cancel()
                        timer = object : MyTimer<Int>(1000L, { x -> remainingTimes[index] - x - 1 }) {
                            override fun onTick(data: Int) {
                                tick(data)
                            }
                        }
                        timer.start()
                        currentTts = ttses[index]
                        if (ttses[index].isEmpty()) {
                            toneGenerator.startTone(ToneGenerator.TONE_CDMA_PIP, 150)
                        } else {
                            if (isTtsInitialized) {
                                tts.speak(ttses[index], TextToSpeech.QUEUE_FLUSH, null, "")
                            }
                        }

                        notificationManager.notify(NOTIFICATION_ID, createNotification(remainingTime))
                        _remainingTime.postValue(remainingTime)
                    }
                    repeatCount == -1 -> {
                        index = 0
                        val remainingTime = remainingTimes[index]
                        timer.cancel()
                        timer = object : MyTimer<Int>(1000L, { x -> remainingTimes[index] - x - 1 }) {
                            override fun onTick(data: Int) {
                                tick(data)
                            }
                        }
                        timer.start()
                        currentTts = ttses[index]
                        if (ttses[index].isEmpty()) {
                            toneGenerator.startTone(ToneGenerator.TONE_CDMA_PIP, 150)
                        } else {
                            if (isTtsInitialized) {
                                tts.speak(ttses[index], TextToSpeech.QUEUE_FLUSH, null, "")
                            }
                        }

                        notificationManager.notify(NOTIFICATION_ID, createNotification(remainingTime))
                        _remainingTime.postValue(remainingTime)
                    }
                    else -> {
                        timer.cancel()
                        currentTts = ttses[index]
                        tts.speak("Done", TextToSpeech.QUEUE_FLUSH, null, "")
                        notificationManager.notify(NOTIFICATION_ID, createNotification(finish = true))
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
                    .setContentText(currentTts)
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setContentIntent(pendingIntent)
                    .build()
        } else {
            NotificationCompat.Builder(this, CHANNEL_ID)
                    .setContentTitle(formattedTime)
                    .setContentText(currentTts)
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setContentIntent(pendingIntent)
                    .build()
        }
    }

    inner class TimerBinder : Binder() {
        fun getService(): TimerService = this@TimerService
    }
}