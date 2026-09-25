import 'package:flutter/widgets.dart';

import '../service/common_haptics_service.dart';

/// Common HapticsのWidgetへServiceを共有します。
final class CommonHapticsContext extends InheritedWidget {
  const CommonHapticsContext({
    required this.service,
    required super.child,
    super.key,
  });

  final CommonHapticsService service;

  /// Widgetツリー内で共有されているCommon Haptics Serviceを取得します。
  static CommonHapticsService of(BuildContext context) {
    final featureContext = context
        .dependOnInheritedWidgetOfExactType<CommonHapticsContext>();
    if (featureContext == null) {
      throw FlutterError(
        'CommonHapticsContext was not found. '
        'Place CommonHapticsSection below CommonHapticsContext.',
      );
    }
    return featureContext.service;
  }

  @override
  bool updateShouldNotify(CommonHapticsContext oldWidget) =>
      service != oldWidget.service;
}
