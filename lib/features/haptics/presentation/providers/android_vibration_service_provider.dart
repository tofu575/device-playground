import 'package:device_haptics/device_haptics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Android Vibration用のServiceを共有します。
final androidVibrationServiceProvider = Provider<AndroidVibrationService>(
  (ref) => const MethodChannelAndroidVibrationService(),
);
