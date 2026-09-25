import 'package:flutter/material.dart';

import '../haptic_experiment.dart';

/// Hapticsの実行ボタンと、呼び出すFlutter API名を表示します。
final class HapticButton extends StatelessWidget {
  const HapticButton({
    required this.experiment,
    required this.onPressed,
    this.description,
    super.key,
  });

  final HapticExperiment experiment;
  final Future<void> Function(HapticExperiment experiment) onPressed;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final codeStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontFamily: 'monospace',
    );

    return Semantics(
      button: true,
      label: '${experiment.label}, ${experiment.apiName}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FilledButton.tonal(
            onPressed: () => onPressed(experiment),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(experiment.label),
          ),
          const SizedBox(height: 8),
          Text(experiment.apiName, style: codeStyle),
          if (description case final description?) ...<Widget>[
            const SizedBox(height: 6),
            Text(description),
          ],
        ],
      ),
    );
  }
}
