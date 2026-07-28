import 'package:flutter/material.dart';
import 'package:tidy/core/theme/app_theme.dart';

/// Subtle hover background for desktop list rows.
class HoverSurface extends StatefulWidget {
  const HoverSurface({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.borderRadius,
    this.padding,
    this.selectedColor,
    this.hoverColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? selectedColor;
  final Color? hoverColor;

  @override
  State<HoverSurface> createState() => _HoverSurfaceState();
}

class _HoverSurfaceState extends State<HoverSurface> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = widget.borderRadius ?? BorderRadius.circular(AppRadii.md);
    final bg = widget.selected
        ? (widget.selectedColor ?? theme.selectedBg)
        : _hover
            ? (widget.hoverColor ?? theme.hoverBg)
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: Curves.easeOut,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
