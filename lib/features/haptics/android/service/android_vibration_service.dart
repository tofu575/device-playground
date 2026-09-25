import '../model/vibration_waveform.dart';
import '../model/vibrator_capabilities.dart';

/// Android Vibratorの対応状況取得と波形操作を提供します。
abstract interface class AndroidVibrationService {
  /// 端末のVibrator対応状況を取得します。
  Future<VibratorCapabilities> getCapabilities();

  /// 指定された波形を再生します。
  Future<void> play(VibrationWaveform waveform);

  /// 実行中の波形を停止します。
  Future<void> cancel();
}
