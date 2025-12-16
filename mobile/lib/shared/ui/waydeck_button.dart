import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Waydeck styled button with loading state
class WaydeckButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool isOutlined;
  final bool isDestructive;
  final double? width;

  const WaydeckButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDestructive = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor:
                isDestructive ? WaydeckTheme.error : WaydeckTheme.primary,
            side: BorderSide(
              color: isDestructive ? WaydeckTheme.error : WaydeckTheme.primary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor:
                isDestructive ? WaydeckTheme.error : WaydeckTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
            ),
          );

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: _buildChild(),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: _buildChild(),
          );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return SizedBox(width: double.infinity, child: button);
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined
                ? (isDestructive ? WaydeckTheme.error : WaydeckTheme.primary)
                : Colors.white,
          ),
        ),
      );
    }
    
    // Determine text color based on button type
    final textColor = isOutlined
        ? (isDestructive ? WaydeckTheme.error : WaydeckTheme.primary)
        : Colors.white;
    
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      child: child,
    );
  }
}
