import 'ios_core_haptic_event_type.dart';

/// iOS Core Hapticsへ渡すイベント種別と触感パラメータです。
final class IosCoreHapticInput {
  const IosCoreHapticInput({
    required this.eventType,
    required this.intensity,
    required this.sharpness,
    required this.durationMilliseconds,
  });

  final IosCoreHapticEventType eventType;
  final double intensity;
  final double sharpness;
  final int durationMilliseconds;
}
