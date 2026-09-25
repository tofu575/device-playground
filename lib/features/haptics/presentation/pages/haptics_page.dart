import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../sections/android_vibration_section.dart';
import '../sections/common_haptics_section.dart';
import '../sections/ios_core_haptics_section.dart';

/// CommonとPlatform固有のHaptics実験を縦に構成する画面です。
final class HapticsPage extends StatelessWidget {
  const HapticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Haptics')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: <Widget>[
          Text(
            'Compare the haptic feedback provided by this device.\n'
            'Actual behavior may differ between platforms and devices.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 28),
          const CommonHapticsSection(),
          switch (defaultTargetPlatform) {
            TargetPlatform.iOS => const IosCoreHapticsSection(),
            TargetPlatform.android => const AndroidVibrationSection(),
            final platform => throw UnsupportedError(
              'Haptics is not supported on $platform.',
            ),
          },
        ],
      ),
    );
  }
}
