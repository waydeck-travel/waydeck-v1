import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Waydeck styled card widget
class WaydeckCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool hasShadow;

  const WaydeckCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? WaydeckTheme.surface,
        borderRadius: BorderRadius.circular(WaydeckTheme.radiusLg),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: hasShadow ? WaydeckTheme.shadowSm : null,
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(WaydeckTheme.radiusLg),
          child: card,
        ),
      );
    }

    return card;
  }
}
