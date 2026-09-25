import '../model/core_haptic_input.dart';

/// iOS Core Hapticsの対応状況取得とイベント実行を提供します。
abstract interface class CoreHapticsService {
  /// 実行中の端末がCore Hapticsを再生できるか取得します。
  Future<bool> isSupported();

  /// 指定されたパラメータでCore Hapticsイベントを再生します。
  Future<void> play(CoreHapticInput input);
}
