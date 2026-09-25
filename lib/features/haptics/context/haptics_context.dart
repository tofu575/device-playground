import 'package:flutter/widgets.dart';

import '../service/haptics_service.dart';

/// Haptics Feature内のWidgetへ機能アクセスを共有します。
final class HapticsContext extends InheritedWidget {
  const HapticsContext({
    required this.service,
    required super.child,
    super.key,
  });

  final HapticsService service;

  /// Widgetツリー内で共有されているHapticsアクセスを取得します。
  static HapticsService of(BuildContext context) {
    final featureContext = context
        .dependOnInheritedWidgetOfExactType<HapticsContext>();
    if (featureContext == null) {
      throw FlutterError(
        'HapticsContext was not found. '
        'Place HapticsPage below HapticsContext.',
      );
    }
    return featureContext.service;
  }

  @override
  bool updateShouldNotify(HapticsContext oldWidget) =>
      service != oldWidget.service;
}
