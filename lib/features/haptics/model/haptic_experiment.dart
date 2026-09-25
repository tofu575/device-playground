/// 比較対象となるFlutter標準Hapticsと、その表示情報を定義します。
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
}
