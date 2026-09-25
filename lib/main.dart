import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/device_playground_app.dart';

/// Device Playgroundを起動します。
void main() => runApp(const ProviderScope(child: DevicePlaygroundApp()));
