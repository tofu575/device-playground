import 'package:flutter/widgets.dart';

import '../service/flutter_common_haptics_service.dart';
import 'common_haptics_context.dart';
import 'common_haptics_section.dart';

/// Common Haptics ServiceをContextへ設定し、Sectionを構成します。
final class CommonHapticsFeature extends StatelessWidget {
  const CommonHapticsFeature({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonHapticsContext(
      service: FlutterCommonHapticsService(),
      child: CommonHapticsSection(),
    );
  }
}
