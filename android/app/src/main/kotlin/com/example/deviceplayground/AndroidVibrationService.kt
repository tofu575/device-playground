package com.example.deviceplayground

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/// Flutterから受け取った波形をAndroid Vibratorで実行します。
class AndroidVibrationService(
    context: Context,
    messenger: BinaryMessenger,
) {
    private val vibrator = resolveVibrator(context)
    private val channel = MethodChannel(
        messenger,
        "device_playground/android_vibration",
    )

    init {
        channel.setMethodCallHandler(::handleMethodCall)
    }

    /// Method Channelの呼び出しを対応するVibrator操作へ振り分けます。
    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getCapabilities" -> result.success(
                mapOf(
                    "hasVibrator" to vibrator.hasVibrator(),
                    "hasAmplitudeControl" to (
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                            vibrator.hasAmplitudeControl()
                        ),
                ),
            )
            "playWaveform" -> playWaveform(call, result)
            "cancel" -> {
                vibrator.cancel()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /// Dart側のセグメント配列を検証してVibrationEffectとして再生します。
    private fun playWaveform(call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            result.error(
                "unsupported_android_version",
                "Amplitude waveforms require Android 8.0 or later.",
                null,
            )
            return
        }
        val rawSegments = call.argument<List<Map<String, Number>>>("segments")
        if (rawSegments.isNullOrEmpty()) {
            result.error("invalid_segments", "At least one segment is required.", null)
            return
        }

        val timings = LongArray(rawSegments.size)
        val amplitudes = IntArray(rawSegments.size)
        for ((index, segment) in rawSegments.withIndex()) {
            val duration = segment["durationMilliseconds"]?.toLong()
            val amplitude = segment["amplitude"]?.toInt()
            if (duration == null || duration <= 0 || amplitude == null || amplitude !in 0..255) {
                result.error(
                    "invalid_segment",
                    "Duration must be positive and amplitude must be between 0 and 255.",
                    null,
                )
                return
            }
            timings[index] = duration
            amplitudes[index] = amplitude
        }

        val repeats = call.argument<Boolean>("repeats")
        if (repeats == null) {
            result.error("invalid_repeat", "Repeat setting is required.", null)
            return
        }
        val effect = VibrationEffect.createWaveform(
            timings,
            amplitudes,
            if (repeats) 0 else -1,
        )
        vibrator.vibrate(effect)
        result.success(null)
    }

    companion object {
        /// OSバージョンに対応するAPIから既定のVibratorを取得します。
        private fun resolveVibrator(context: Context): Vibrator =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                context.getSystemService(VibratorManager::class.java).defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }
    }
}
