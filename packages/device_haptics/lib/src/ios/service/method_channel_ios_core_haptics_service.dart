import 'package:flutter/services.dart';

import '../model/ios_core_haptic_event_type.dart';
import '../model/ios_core_haptic_input.dart';
import 'ios_core_haptics_service.dart';

/// Method Channel経由でiOSのCore Hapticsを操作します。
final class MethodChannelIosCoreHapticsService
    implements IosCoreHapticsService {
  const MethodChannelIosCoreHapticsService();

  static const _channel = MethodChannel('device_haptics/ios_core_haptics');

  @override
  Future<bool> isSupported() async {
    final isSupported = await _channel.invokeMethod<bool>('isSupported');
    if (isSupported == null) {
      throw StateError('Core Haptics support status was not returned.');
    }
    return isSupported;
  }

  @override
  Future<void> play(IosCoreHapticInput input) =>
      _channel.invokeMethod<void>('play', <String, Object>{
        'eventType': switch (input.eventType) {
          IosCoreHapticEventType.transient => 'transient',
          IosCoreHapticEventType.continuous => 'continuous',
        },
        'intensity': input.intensity,
        'sharpness': input.sharpness,
        'durationMilliseconds': input.durationMilliseconds,
      });
}
