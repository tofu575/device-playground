import 'package:device_haptics/device_haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/common_haptics_service_provider.dart';
import '../widgets/haptic_section.dart';
import '../widgets/last_played_card.dart';

/// Flutter標準Hapticsの実行UIと直近の実行状態を管理します。
final class CommonHapticsSection extends ConsumerStatefulWidget {
  const CommonHapticsSection({super.key});

  @override
  ConsumerState<CommonHapticsSection> createState() =>
      _CommonHapticsSectionState();
}

/// Common Hapticsで最後に実行した種類を画面内で保持します。
final class _CommonHapticsSectionState
    extends ConsumerState<CommonHapticsSection> {
  HapticExperiment? _lastPlayed;

  /// Hapticsを実行し、完了後にLast playedへ反映します。
  Future<void> _play(HapticExperiment experiment) async {
    await ref.read(commonHapticsServiceProvider).play(experiment);
    if (!mounted) {
      return;
    }
    setState(() => _lastPlayed = experiment);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Common Haptics',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
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
    );
  }
}
