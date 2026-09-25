import 'package:device_haptics/device_haptics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS Core Haptics用のServiceを共有します。
final iosCoreHapticsServiceProvider = Provider<IosCoreHapticsService>(
  (ref) => const MethodChannelIosCoreHapticsService(),
);
