package com.tabata_timer.hiit_timer

import java.util.*


abstract class MyTimer<T>(
        private val period: Long,
        private val computation: (Int) -> T
) {
    enum class TimerState {
        READY, RUNNING, PAUSE
    }

    private lateinit var timer: Timer
    private var timerState = TimerState.READY
    private val watch = Stopwatch()

    var computationCount = 0

    abstract fun onTick(data: T)

    fun tick() {
        watch.reset()
        val data = computation(computationCount++)
        onTick(data)
    }

    fun start() {
        val task = object : TimerTask() {
            override fun run() {
                tick()
            }
        }
        timer = Timer().apply { scheduleAtFixedRate(task, period, period) }
        timerState = TimerState.RUNNING
    }

    fun pause() {
        if (timerState == TimerState.RUNNING) {
            watch.pause()
            timer.cancel()
            timerState = TimerState.PAUSE
        }
    }

    fun resume() {
        if (timerState == TimerState.PAUSE) {
            val task = object : TimerTask() {
                override fun run() {
                    timer.cancel()
                    start()
                    tick()
                }
            }
            timer = Timer().apply { schedule(task, period - watch.elapsed) }
            watch.resume()
            timerState = TimerState.RUNNING
        }
    }

    fun cancel() {
        timer.cancel()
    }
}

class Stopwatch {
    enum class StopwatchState {
        RUNNING, PAUSE
    }

    private var startTime = 0L
    private var state = StopwatchState.RUNNING

    var elapsed = 0L

    init {
        startTime = System.currentTimeMillis()
    }

    fun reset() {
        startTime = System.currentTimeMillis()
        elapsed = 0L
        state = StopwatchState.RUNNING
    }

    fun pause() {
        if (state == StopwatchState.RUNNING) {
            elapsed = System.currentTimeMillis() - startTime
            state = StopwatchState.PAUSE
        }
    }

    fun resume() {
        if (state == StopwatchState.PAUSE) {
            startTime = System.currentTimeMillis() - elapsed
            state = StopwatchState.RUNNING
        }
    }
}