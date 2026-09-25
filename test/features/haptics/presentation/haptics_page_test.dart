import 'package:device_playground/features/haptics/context/haptics_context.dart';
import 'package:device_playground/features/haptics/model/haptic_experiment.dart';
import 'package:device_playground/features/haptics/presentation/haptics_page.dart';
import 'package:device_playground/features/haptics/service/haptics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// PageからContextへ渡された実験とLast playedの更新を検証します。
void main() {
  testWidgets('plays every common haptic and updates Last played', (
    tester,
  ) async {
    final service = _HapticsServiceStub();

    await tester.pumpWidget(
      MaterialApp(
        home: HapticsContext(service: service, child: const HapticsPage()),
      ),
    );

    const expectations = <String, HapticExperiment>{
      'Selection Click': HapticExperiment.selectionClick,
      'Light': HapticExperiment.lightImpact,
      'Medium': HapticExperiment.mediumImpact,
      'Heavy': HapticExperiment.heavyImpact,
      'Success': HapticExperiment.successNotification,
      'Warning': HapticExperiment.warningNotification,
      'Error': HapticExperiment.errorNotification,
      'Vibrate': HapticExperiment.vibrate,
    };

    for (final MapEntry(key: label, value: experiment)
        in expectations.entries) {
      final button = find.widgetWithText(FilledButton, label);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();

      expect(service.played.last, experiment);
    }

    expect(find.text('Last played'), findsOneWidget);
    expect(find.text('HapticFeedback.vibrate()'), findsNWidgets(2));
  });
}

/// Pageから受け取ったHaptics実行要求を記録するテスト実装です。
final class _HapticsServiceStub implements HapticsService {
  final played = <HapticExperiment>[];

  @override
  Future<void> play(HapticExperiment experiment) async {
    played.add(experiment);
  }
}
