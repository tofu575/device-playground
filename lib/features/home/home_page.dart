import 'package:flutter/material.dart';

import '../haptics/presentation/pages/haptics_page.dart';
import 'widgets/experiment_card.dart';

/// 実装済みのデバイス実験への入口を表示します。
final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Playground')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: <Widget>[
          Text(
            'Experiments',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ExperimentCard(
            title: 'Haptics',
            description: 'Tactile feedback',
            icon: Icons.vibration_rounded,
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => const HapticsPage()),
            ),
          ),
        ],
      ),
    );
  }
}
