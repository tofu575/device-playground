import 'package:flutter/material.dart';

import '../../model/vibration_segment.dart';

/// Android波形の1区間についてDurationとAmplitudeを編集します。
final class VibrationSegmentEditor extends StatelessWidget {
  const VibrationSegmentEditor({
    required this.index,
    required this.segment,
    required this.onChanged,
    required this.onRemove,
    super.key,
  });

  final int index;
  final VibrationSegment segment;
  final ValueChanged<VibrationSegment> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Segment ${index + 1}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Remove segment',
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            Text('Duration  ${segment.durationMilliseconds} ms'),
            Slider(
              value: segment.durationMilliseconds.toDouble(),
              min: 10,
              max: 1000,
              divisions: 99,
              onChanged: (value) => onChanged(
                segment.copyWith(durationMilliseconds: value.round()),
              ),
            ),
            Text('Amplitude  ${segment.amplitude}'),
            Slider(
              value: segment.amplitude.toDouble(),
              min: 0,
              max: 255,
              divisions: 255,
              onChanged: (value) =>
                  onChanged(segment.copyWith(amplitude: value.round())),
            ),
          ],
        ),
      ),
    );
  }
}
