import 'package:flutter/material.dart';

import '../common/presentation/common_haptics_feature.dart';

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
          const CommonHapticsFeature(),
        ],
      ),
    );
  }
}
