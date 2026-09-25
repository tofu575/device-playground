import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/core_haptic_event_type.dart';
import '../model/core_haptic_input.dart';
import 'providers/core_haptics_service_provider.dart';

/// Core Hapticsの数値を編集し、iOS実機で再生します。
final class CoreHapticsSection extends ConsumerStatefulWidget {
  const CoreHapticsSection({super.key});

  @override
  ConsumerState<CoreHapticsSection> createState() => _CoreHapticsSectionState();
}

/// Core Hapticsの入力値と端末対応状況を管理します。
final class _CoreHapticsSectionState extends ConsumerState<CoreHapticsSection> {
  CoreHapticEventType _eventType = CoreHapticEventType.transient;
  double _intensity = 0.7;
  double _sharpness = 0.5;
  double _durationMilliseconds = 500;
  bool? _isSupported;
  bool _didLoadSupport = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadSupport) {
      return;
    }
    _didLoadSupport = true;
    _loadSupport();
  }

  /// Core Hapticsの対応状況を実機から取得します。
  Future<void> _loadSupport() async {
    try {
      final isSupported = await ref
          .read(coreHapticsServiceProvider)
          .isSupported();
      if (mounted) {
        setState(() => _isSupported = isSupported);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.toString());
      }
    }
  }

  /// 現在の入力値でCore Hapticsイベントを再生します。
  Future<void> _play() async {
    setState(() => _errorMessage = null);
    try {
      await ref
          .read(coreHapticsServiceProvider)
          .play(
            CoreHapticInput(
              eventType: _eventType,
              intensity: _intensity,
              sharpness: _sharpness,
              durationMilliseconds: _durationMilliseconds.round(),
            ),
          );
    } on Object catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isContinuous = _eventType == CoreHapticEventType.continuous;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 40),
        Text(
          'iOS Core Haptics',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(switch (_isSupported) {
          null => 'Checking hardware support…',
          true => 'Core Haptics supported',
          false => 'Core Haptics is not supported on this device.',
        }),
        const SizedBox(height: 20),
        SegmentedButton<CoreHapticEventType>(
          segments: const <ButtonSegment<CoreHapticEventType>>[
            ButtonSegment(
              value: CoreHapticEventType.transient,
              label: Text('Transient'),
            ),
            ButtonSegment(
              value: CoreHapticEventType.continuous,
              label: Text('Continuous'),
            ),
          ],
          selected: <CoreHapticEventType>{_eventType},
          onSelectionChanged: (selection) {
            setState(() => _eventType = selection.single);
          },
        ),
        const SizedBox(height: 20),
        Text('Intensity  ${_intensity.toStringAsFixed(2)}'),
        Slider(
          value: _intensity,
          divisions: 20,
          onChanged: (value) => setState(() => _intensity = value),
        ),
        Text('Sharpness  ${_sharpness.toStringAsFixed(2)}'),
        Slider(
          value: _sharpness,
          divisions: 20,
          onChanged: (value) => setState(() => _sharpness = value),
        ),
        if (isContinuous) ...<Widget>[
          Text('Duration  ${_durationMilliseconds.round()} ms'),
          Slider(
            value: _durationMilliseconds,
            min: 50,
            max: 3000,
            divisions: 59,
            onChanged: (value) {
              setState(() => _durationMilliseconds = value);
            },
          ),
        ],
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _isSupported == true ? _play : null,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Play Core Haptics'),
        ),
        if (_errorMessage case final errorMessage?) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            errorMessage,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}
