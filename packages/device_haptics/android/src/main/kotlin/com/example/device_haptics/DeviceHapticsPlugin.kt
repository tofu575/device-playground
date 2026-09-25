package com.example.device_haptics

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/// Flutterから受け取った波形をAndroid Vibratorで実行します。
class DeviceHapticsPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var vibrator: Vibrator

    /// Flutter EngineへAndroid VibrationのMethod Channelを登録します。
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        vibrator = resolveVibrator(binding.applicationContext)
        channel = MethodChannel(
            binding.binaryMessenger,
            "device_haptics/android_vibration",
        )
        channel.setMethodCallHandler(this)
    }

    /// Method Channelの呼び出しを対応するVibrator操作へ振り分けます。
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
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

    /// Flutter Engineから切り離す際に実行中の振動とChannel購読を解除します。
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        vibrator.cancel()
        channel.setMethodCallHandler(null)
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
