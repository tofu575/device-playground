import 'package:device_playground/app/device_playground_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Homeから実装済みのHaptics実験へ移動できることを検証します。
void main() {
  testWidgets('opens the Haptics experiment from Home', (tester) async {
    await tester.pumpWidget(const DevicePlaygroundApp());

    expect(find.text('Experiments'), findsOneWidget);
    expect(find.text('Tactile feedback'), findsOneWidget);

    await tester.tap(find.text('Haptics'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Haptics'), findsOneWidget);
    expect(find.textContaining('Compare the haptic feedback'), findsOneWidget);
  });
}
