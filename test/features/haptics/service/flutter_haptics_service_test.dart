import 'package:device_playground/features/haptics/model/haptic_experiment.dart';
import 'package:device_playground/features/haptics/service/flutter_haptics_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Flutter実装が各Hapticsを正しいPlatform Channel値へ変換するか検証します。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('maps every experiment to Flutter HapticFeedback', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    const service = FlutterHapticsService();
    const expectations = <HapticExperiment, Object?>{
      HapticExperiment.selectionClick: 'HapticFeedbackType.selectionClick',
      HapticExperiment.lightImpact: 'HapticFeedbackType.lightImpact',
      HapticExperiment.mediumImpact: 'HapticFeedbackType.mediumImpact',
      HapticExperiment.heavyImpact: 'HapticFeedbackType.heavyImpact',
      HapticExperiment.successNotification:
          'HapticFeedbackType.successNotification',
      HapticExperiment.warningNotification:
          'HapticFeedbackType.warningNotification',
      HapticExperiment.errorNotification:
          'HapticFeedbackType.errorNotification',
      HapticExperiment.vibrate: null,
    };

    for (final MapEntry(key: experiment, value: argument)
        in expectations.entries) {
      await service.play(experiment);

      expect(calls.last.method, 'HapticFeedback.vibrate');
      expect(calls.last.arguments, argument);
    }
  });
}
