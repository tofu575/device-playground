import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../service/common_haptics_service.dart';
import '../../service/flutter_common_haptics_service.dart';

/// Common Hapticsで共有するServiceを提供します。
final commonHapticsServiceProvider = Provider<CommonHapticsService>(
  (ref) => const FlutterCommonHapticsService(),
);
