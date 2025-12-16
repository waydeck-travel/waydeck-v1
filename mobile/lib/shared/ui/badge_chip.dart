import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Badge/Chip widget for modes, status, etc.
class BadgeChip extends StatelessWidget {
  final String label;
  final String? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool small;

  const BadgeChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.small = false,
  });

  /// Transport mode badge
  factory BadgeChip.transport({String? label, String? icon}) {
    return BadgeChip(
      label: label ?? 'Transport',
      icon: icon,
      backgroundColor: WaydeckTheme.transportColor.withValues(alpha: 0.1),
      textColor: WaydeckTheme.transportColor,
    );
  }

  /// Stay badge
  factory BadgeChip.stay({String? label, String? icon}) {
    return BadgeChip(
      label: label ?? 'Stay',
      icon: icon,
      backgroundColor: WaydeckTheme.stayColor.withValues(alpha: 0.1),
      textColor: WaydeckTheme.stayColor,
    );
  }

  /// Activity badge
  factory BadgeChip.activity({String? label, String? icon}) {
    return BadgeChip(
      label: label ?? 'Activity',
      icon: icon,
      backgroundColor: WaydeckTheme.activityColor.withValues(alpha: 0.1),
      textColor: WaydeckTheme.activityColor,
    );
  }

  /// Info badge (for document attached, etc.)
  factory BadgeChip.info({required String label, String? icon}) {
    return BadgeChip(
      label: label,
      icon: icon,
      backgroundColor: WaydeckTheme.info.withValues(alpha: 0.1),
      textColor: WaydeckTheme.info,
    );
  }

  /// Success badge (for breakfast included, etc.)
  factory BadgeChip.success({required String label, String? icon}) {
    return BadgeChip(
      label: label,
      icon: icon,
      backgroundColor: WaydeckTheme.success.withValues(alpha: 0.1),
      textColor: WaydeckTheme.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? WaydeckTheme.surfaceVariant;
    final fgColor = textColor ?? WaydeckTheme.textSecondary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(WaydeckTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(
              icon!,
              style: TextStyle(fontSize: small ? 10 : 12),
            ),
            SizedBox(width: small ? 2 : 4),
          ],
          Text(
            label,
            style: (small ? WaydeckTheme.caption : WaydeckTheme.bodySmall)
                .copyWith(
              color: fgColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
