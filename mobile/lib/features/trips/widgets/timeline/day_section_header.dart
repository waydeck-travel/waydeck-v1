import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';

/// Day section header for timeline grouping
class DaySectionHeader extends StatelessWidget {
  final DateTime date;

  const DaySectionHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    String label;
    if (dateOnly == today) {
      label = 'Today';
    } else if (dateOnly == tomorrow) {
      label = 'Tomorrow';
    } else {
      label = DateFormat('EEE, d MMM yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: WaydeckTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(WaydeckTheme.radiusSm),
            ),
            child: Text(
              label,
              style: WaydeckTheme.bodySmall.copyWith(
                color: WaydeckTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}
