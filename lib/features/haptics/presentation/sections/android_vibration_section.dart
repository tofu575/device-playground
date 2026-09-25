import 'package:device_haptics/device_haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/android_vibration_service_provider.dart';
import '../widgets/vibration_segment_editor.dart';

/// Androidの波形セグメントを編集し、Vibratorで再生します。
final class AndroidVibrationSection extends ConsumerStatefulWidget {
  const AndroidVibrationSection({super.key});

  @override
  ConsumerState<AndroidVibrationSection> createState() =>
      _AndroidVibrationSectionState();
}

/// Android波形と端末のVibrator対応状況を管理します。
final class _AndroidVibrationSectionState
    extends ConsumerState<AndroidVibrationSection> {
  List<VibrationSegment> _segments = const <VibrationSegment>[
    VibrationSegment(durationMilliseconds: 100, amplitude: 255),
    VibrationSegment(durationMilliseconds: 100, amplitude: 0),
    VibrationSegment(durationMilliseconds: 200, amplitude: 180),
  ];
  VibratorCapabilities? _capabilities;
  bool _repeats = false;
  bool _didLoadCapabilities = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadCapabilities) {
      return;
    }
    _didLoadCapabilities = true;
    _loadCapabilities();
  }

  /// Android端末のVibrator対応状況を取得します。
  Future<void> _loadCapabilities() async {
    try {
      final capabilities = await ref
          .read(androidVibrationServiceProvider)
          .getCapabilities();
      if (mounted) {
        setState(() => _capabilities = capabilities);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.toString());
      }
    }
  }

  /// 指定位置の波形セグメントを置き換えます。
  void _updateSegment(int index, VibrationSegment segment) {
    setState(() {
      _segments = <VibrationSegment>[
        for (
          var currentIndex = 0;
          currentIndex < _segments.length;
          currentIndex++
        )
          if (currentIndex == index) segment else _segments[currentIndex],
      ];
    });
  }

  /// 指定位置の波形セグメントを削除します。
  void _removeSegment(int index) {
    setState(() {
      _segments = <VibrationSegment>[
        for (
          var currentIndex = 0;
          currentIndex < _segments.length;
          currentIndex++
        )
          if (currentIndex != index) _segments[currentIndex],
      ];
    });
  }

  /// 既定値を持つ波形セグメントを末尾へ追加します。
  void _addSegment() {
    setState(() {
      _segments = <VibrationSegment>[
        ..._segments,
        const VibrationSegment(durationMilliseconds: 100, amplitude: 255),
      ];
    });
  }

  /// 現在のセグメント列をAndroid Vibratorで再生します。
  Future<void> _play() async {
    setState(() => _errorMessage = null);
    try {
      await ref
          .read(androidVibrationServiceProvider)
          .play(VibrationWaveform(segments: _segments, repeats: _repeats));
    } on Object catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.toString());
      }
    }
  }

  /// 実行中のAndroid波形を停止します。
  Future<void> _cancel() async {
    await ref.read(androidVibrationServiceProvider).cancel();
  }

  @override
  Widget build(BuildContext context) {
    final capabilities = _capabilities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 40),
        Text(
          'Android Vibrator',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (capabilities == null)
          const Text('Checking vibrator capabilities…')
        else ...<Widget>[
          Text(
            'Vibrator: ${capabilities.hasVibrator ? 'Available' : 'Unavailable'}',
          ),
          Text(
            'Amplitude control: '
            '${capabilities.hasAmplitudeControl ? 'Supported' : 'Unsupported'}',
          ),
        ],
        const SizedBox(height: 20),
        for (var index = 0; index < _segments.length; index++) ...<Widget>[
          VibrationSegmentEditor(
            index: index,
            segment: _segments[index],
            onChanged: (segment) => _updateSegment(index, segment),
            onRemove: _segments.length > 1 ? () => _removeSegment(index) : null,
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: _addSegment,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add segment'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Repeat waveform'),
          value: _repeats,
          onChanged: (value) => setState(() => _repeats = value),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: capabilities?.hasVibrator == true ? _play : null,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Play waveform'),
        ),
        if (_repeats) ...<Widget>[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _cancel,
            icon: const Icon(Icons.stop_rounded),
            label: const Text('Stop'),
          ),
        ],
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
