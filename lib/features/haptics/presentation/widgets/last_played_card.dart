import 'package:flutter/material.dart';

import '../../model/haptic_experiment.dart';

/// 直近に実行したHapticsとAPI名、または未実行状態を表示します。
final class LastPlayedCard extends StatelessWidget {
  const LastPlayedCard({required this.experiment, super.key});

  final HapticExperiment? experiment;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Last played',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (experiment case final experiment?) ...<Widget>[
              Text(
                experiment.label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                experiment.apiName,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            ] else
              const Text('Nothing played yet.'),
          ],
        ),
      ),
    );
  }
}
