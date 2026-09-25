import 'package:flutter/material.dart';

import '../../model/haptic_experiment.dart';
import 'haptic_button.dart';

/// 同種のHapticsを見出し付きでまとめ、比較しやすく配置します。
final class HapticSection extends StatelessWidget {
  const HapticSection({
    required this.title,
    required this.experiments,
    required this.onPlay,
    this.descriptions = const <HapticExperiment, String>{},
    super.key,
  });

  final String title;
  final List<HapticExperiment> experiments;
  final Map<HapticExperiment, String> descriptions;
  final Future<void> Function(HapticExperiment experiment) onPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Divider(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final columnCount = constraints.maxWidth >= 680
                  ? 3
                  : constraints.maxWidth >= 440
                  ? 2
                  : 1;
              final itemWidth =
                  (constraints.maxWidth - spacing * (columnCount - 1)) /
                  columnCount;

              return Wrap(
                spacing: spacing,
                runSpacing: 20,
                children: <Widget>[
                  for (final experiment in experiments)
                    SizedBox(
                      width: itemWidth,
                      child: HapticButton(
                        experiment: experiment,
                        description: descriptions[experiment],
                        onPressed: onPlay,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
