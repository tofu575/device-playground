import 'package:flutter/widgets.dart';

import '../presentation/haptics_page.dart';
import '../service/flutter_haptics_service.dart';
import 'haptics_context.dart';

/// Hapticsの機能アクセスをContextへ設定し、実験ページを起動します。
final class HapticsFeature extends StatelessWidget {
  const HapticsFeature({super.key});

  @override
  Widget build(BuildContext context) {
    return const HapticsContext(
      service: FlutterHapticsService(),
      child: HapticsPage(),
    );
  }
}
