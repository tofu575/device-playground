import 'package:device_haptics/device_haptics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Common Haptics用のServiceを共有します。
final commonHapticsServiceProvider = Provider<CommonHapticsService>(
  (ref) => const FlutterCommonHapticsService(),
);
