/// Android端末におけるVibratorと振幅制御の対応状況です。
final class VibratorCapabilities {
  const VibratorCapabilities({
    required this.hasVibrator,
    required this.hasAmplitudeControl,
  });

  final bool hasVibrator;
  final bool hasAmplitudeControl;
}
