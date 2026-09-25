import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../service/core_haptics_service.dart';
import '../../service/method_channel_core_haptics_service.dart';

/// iOS Core Hapticsで共有するServiceを提供します。
final coreHapticsServiceProvider = Provider<CoreHapticsService>(
  (ref) => const MethodChannelCoreHapticsService(),
);
