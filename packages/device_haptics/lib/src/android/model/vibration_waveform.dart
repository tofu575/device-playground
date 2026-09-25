import 'vibration_segment.dart';

/// Android Vibratorへ渡す波形セグメントと繰り返し設定です。
final class VibrationWaveform {
  const VibrationWaveform({required this.segments, required this.repeats});

  final List<VibrationSegment> segments;
  final bool repeats;
}
