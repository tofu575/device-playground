import 'package:flutter/services.dart';

import '../model/vibration_waveform.dart';
import '../model/vibrator_capabilities.dart';
import 'android_vibration_service.dart';

/// Method Channel経由でAndroidのVibratorを操作します。
final class MethodChannelAndroidVibrationService
    implements AndroidVibrationService {
  const MethodChannelAndroidVibrationService();

  static const _channel = MethodChannel('device_playground/android_vibration');

  @override
  Future<VibratorCapabilities> getCapabilities() async {
    final values = await _channel.invokeMapMethod<String, bool>(
      'getCapabilities',
    );
    if (values == null) {
      throw StateError('Android vibrator capabilities were not returned.');
    }
    final hasVibrator = values['hasVibrator'];
    final hasAmplitudeControl = values['hasAmplitudeControl'];
    if (hasVibrator == null || hasAmplitudeControl == null) {
      throw StateError('Android vibrator capabilities were incomplete.');
    }
    return VibratorCapabilities(
      hasVibrator: hasVibrator,
      hasAmplitudeControl: hasAmplitudeControl,
    );
  }

  @override
  Future<void> play(VibrationWaveform waveform) =>
      _channel.invokeMethod<void>('playWaveform', <String, Object>{
        'segments': <Map<String, int>>[
          for (final segment in waveform.segments)
            <String, int>{
              'durationMilliseconds': segment.durationMilliseconds,
              'amplitude': segment.amplitude,
            },
        ],
        'repeats': waveform.repeats,
      });

  @override
  Future<void> cancel() => _channel.invokeMethod<void>('cancel');
}
