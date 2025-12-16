import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Layover chip showing wait time between transports
class LayoverChip extends StatelessWidget {
  final Duration duration;
  final String location;

  const LayoverChip({
    super.key,
    required this.duration,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    String durationText;
    if (hours > 0 && minutes > 0) {
      durationText = '${hours}h ${minutes}m';
    } else if (hours > 0) {
      durationText = '${hours}h';
    } else {
      durationText = '${minutes}m';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: WaydeckTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(WaydeckTheme.radiusSm),
        border: Border.all(
          color: WaydeckTheme.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⏱', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            'Layover: $durationText at $location',
            style: WaydeckTheme.bodySmall.copyWith(
              color: WaydeckTheme.warning,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
