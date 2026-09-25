import 'package:device_haptics/device_haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ios_core_haptics_service_provider.dart';

/// Core Hapticsの数値を編集し、iOS実機で再生します。
final class IosCoreHapticsSection extends ConsumerStatefulWidget {
  const IosCoreHapticsSection({super.key});

  @override
  ConsumerState<IosCoreHapticsSection> createState() =>
      _IosCoreHapticsSectionState();
}

/// Core Hapticsの入力値と端末対応状況を管理します。
final class _IosCoreHapticsSectionState
    extends ConsumerState<IosCoreHapticsSection> {
  IosCoreHapticEventType _eventType = IosCoreHapticEventType.transient;
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
          .read(iosCoreHapticsServiceProvider)
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
          .read(iosCoreHapticsServiceProvider)
          .play(
            IosCoreHapticInput(
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
    final isContinuous = _eventType == IosCoreHapticEventType.continuous;

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
        SegmentedButton<IosCoreHapticEventType>(
          segments: const <ButtonSegment<IosCoreHapticEventType>>[
            ButtonSegment(
              value: IosCoreHapticEventType.transient,
              label: Text('Transient'),
            ),
            ButtonSegment(
              value: IosCoreHapticEventType.continuous,
              label: Text('Continuous'),
            ),
          ],
          selected: <IosCoreHapticEventType>{_eventType},
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
