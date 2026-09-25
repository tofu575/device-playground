import '../model/haptic_experiment.dart';

/// Common Hapticsの触覚フィードバック機能を提供します。
abstract interface class CommonHapticsService {
  /// 指定された種類の触覚フィードバックを端末で実行します。
  Future<void> play(HapticExperiment experiment);
}
