import 'package:flutter/material.dart';

import '../context/haptics_context.dart';
import '../model/haptic_experiment.dart';
import 'widgets/haptic_section.dart';
import 'widgets/last_played_card.dart';

/// Flutter標準Hapticsを実機で実行し、連続比較できる画面です。
final class HapticsPage extends StatefulWidget {
  const HapticsPage({super.key});

  @override
  State<HapticsPage> createState() => _HapticsPageState();
}

/// 最後に実行したHapticsを画面内で保持します。
final class _HapticsPageState extends State<HapticsPage> {
  HapticExperiment? _lastPlayed;

  /// Hapticsを実行し、完了後にLast playedへ反映します。
  Future<void> _play(HapticExperiment experiment) async {
    await HapticsContext.of(context).play(experiment);
    if (!mounted) {
      return;
    }
    setState(() => _lastPlayed = experiment);
  }

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
          HapticSection(
            title: 'Selection',
            experiments: const <HapticExperiment>[
              HapticExperiment.selectionClick,
            ],
            descriptions: const <HapticExperiment, String>{
              HapticExperiment.selectionClick: 'Discrete selection changes.',
            },
            onPlay: _play,
          ),
          HapticSection(
            title: 'Impact',
            experiments: const <HapticExperiment>[
              HapticExperiment.lightImpact,
              HapticExperiment.mediumImpact,
              HapticExperiment.heavyImpact,
            ],
            onPlay: _play,
          ),
          HapticSection(
            title: 'Notification',
            experiments: const <HapticExperiment>[
              HapticExperiment.successNotification,
              HapticExperiment.warningNotification,
              HapticExperiment.errorNotification,
            ],
            onPlay: _play,
          ),
          HapticSection(
            title: 'Vibration',
            experiments: const <HapticExperiment>[HapticExperiment.vibrate],
            descriptions: const <HapticExperiment, String>{
              HapticExperiment.vibrate: 'Platform-default vibration.',
            },
            onPlay: _play,
          ),
          LastPlayedCard(experiment: _lastPlayed),
        ],
      ),
    );
  }
}
