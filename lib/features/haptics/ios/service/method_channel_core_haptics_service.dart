import 'package:flutter/services.dart';

import '../model/core_haptic_event_type.dart';
import '../model/core_haptic_input.dart';
import 'core_haptics_service.dart';

/// Method Channel経由でiOSのCore Hapticsを操作します。
final class MethodChannelCoreHapticsService implements CoreHapticsService {
  const MethodChannelCoreHapticsService();

  static const _channel = MethodChannel('device_playground/core_haptics');

  @override
  Future<bool> isSupported() async {
    final isSupported = await _channel.invokeMethod<bool>('isSupported');
    if (isSupported == null) {
      throw StateError('Core Haptics support status was not returned.');
    }
    return isSupported;
  }

  @override
  Future<void> play(CoreHapticInput input) =>
      _channel.invokeMethod<void>('play', <String, Object>{
        'eventType': switch (input.eventType) {
          CoreHapticEventType.transient => 'transient',
          CoreHapticEventType.continuous => 'continuous',
        },
        'intensity': input.intensity,
        'sharpness': input.sharpness,
        'durationMilliseconds': input.durationMilliseconds,
      });
}
