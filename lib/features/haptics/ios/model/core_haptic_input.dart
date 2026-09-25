import 'core_haptic_event_type.dart';

/// Core Hapticsへ渡すイベント種別と触感パラメータです。
final class CoreHapticInput {
  const CoreHapticInput({
    required this.eventType,
    required this.intensity,
    required this.sharpness,
    required this.durationMilliseconds,
  });

  final CoreHapticEventType eventType;
  final double intensity;
  final double sharpness;
  final int durationMilliseconds;
}
