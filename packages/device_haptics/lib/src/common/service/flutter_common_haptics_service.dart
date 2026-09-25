import 'package:flutter/services.dart';

import '../model/haptic_experiment.dart';
import 'common_haptics_service.dart';

/// Flutter標準APIを使って端末の触覚フィードバックを実行します。
final class FlutterCommonHapticsService implements CommonHapticsService {
  const FlutterCommonHapticsService();

  @override
  Future<void> play(HapticExperiment experiment) => switch (experiment) {
    HapticExperiment.selectionClick => HapticFeedback.selectionClick(),
    HapticExperiment.lightImpact => HapticFeedback.lightImpact(),
    HapticExperiment.mediumImpact => HapticFeedback.mediumImpact(),
    HapticExperiment.heavyImpact => HapticFeedback.heavyImpact(),
    HapticExperiment.successNotification =>
      HapticFeedback.successNotification(),
    HapticExperiment.warningNotification =>
      HapticFeedback.warningNotification(),
    HapticExperiment.errorNotification => HapticFeedback.errorNotification(),
    HapticExperiment.vibrate => HapticFeedback.vibrate(),
  };
}
