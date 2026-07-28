import 'package:flutter/material.dart';
import 'package:tidy/core/theme/app_theme.dart';

/// Animated show/hide for a fixed-width side pane.
class SlidingPane extends StatelessWidget {
  const SlidingPane({
    super.key,
    required this.open,
    required this.width,
    required this.alignment,
    required this.child,
  });

  final bool open;
  final double width;
  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return ClipRect(
      child: AnimatedAlign(
        duration: reduce ? Duration.zero : AppDurations.normal,
        curve: Curves.easeOutCubic,
        alignment: alignment,
        widthFactor: open ? 1 : 0,
        child: SizedBox(width: width, child: child),
      ),
    );
  }
}
