/// Android波形を構成する1区間の長さと振幅です。
final class VibrationSegment {
  const VibrationSegment({
    required this.durationMilliseconds,
    required this.amplitude,
  });

  final int durationMilliseconds;
  final int amplitude;

  /// 一部の値を置き換えた新しい区間を返します。
  VibrationSegment copyWith({int? durationMilliseconds, int? amplitude}) =>
      VibrationSegment(
        durationMilliseconds: durationMilliseconds ?? this.durationMilliseconds,
        amplitude: amplitude ?? this.amplitude,
      );
}
