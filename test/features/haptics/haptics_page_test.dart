import 'package:device_playground/features/haptics/haptics_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 全HapticsボタンのPlatform Channel呼び出しとLast playedを検証します。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plays every common haptic and updates Last played', (
    tester,
  ) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: HapticsPage()));

    const expectations = <String, Object?>{
      'Selection Click': 'HapticFeedbackType.selectionClick',
      'Light': 'HapticFeedbackType.lightImpact',
      'Medium': 'HapticFeedbackType.mediumImpact',
      'Heavy': 'HapticFeedbackType.heavyImpact',
      'Success': 'HapticFeedbackType.successNotification',
      'Warning': 'HapticFeedbackType.warningNotification',
      'Error': 'HapticFeedbackType.errorNotification',
      'Vibrate': null,
    };

    for (final MapEntry(key: label, value: argument) in expectations.entries) {
      final button = find.widgetWithText(FilledButton, label);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();

      expect(calls.last.method, 'HapticFeedback.vibrate');
      expect(calls.last.arguments, argument);
    }

    expect(find.text('Last played'), findsOneWidget);
    expect(find.text('HapticFeedback.vibrate()'), findsNWidgets(2));
  });
}
