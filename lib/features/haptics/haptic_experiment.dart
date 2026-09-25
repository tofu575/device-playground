import 'package:flutter/services.dart';

/// 比較できるFlutter標準Hapticsと、その表示情報を定義します。
enum HapticExperiment {
  selectionClick('Selection Click', 'HapticFeedback.selectionClick()'),
  lightImpact('Light', 'HapticFeedback.lightImpact()'),
  mediumImpact('Medium', 'HapticFeedback.mediumImpact()'),
  heavyImpact('Heavy', 'HapticFeedback.heavyImpact()'),
  successNotification('Success', 'HapticFeedback.successNotification()'),
  warningNotification('Warning', 'HapticFeedback.warningNotification()'),
  errorNotification('Error', 'HapticFeedback.errorNotification()'),
  vibrate('Vibrate', 'HapticFeedback.vibrate()');

  const HapticExperiment(this.label, this.apiName);

  final String label;
  final String apiName;

  /// 対応するFlutter標準の触覚フィードバックを実行します。
  Future<void> play() => switch (this) {
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
