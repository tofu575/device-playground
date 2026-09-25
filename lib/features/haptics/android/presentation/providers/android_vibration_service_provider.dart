import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../service/android_vibration_service.dart';
import '../../service/method_channel_android_vibration_service.dart';

/// Android Vibrationで共有するServiceを提供します。
final androidVibrationServiceProvider = Provider<AndroidVibrationService>(
  (ref) => const MethodChannelAndroidVibrationService(),
);
