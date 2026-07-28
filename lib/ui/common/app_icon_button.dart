import 'package:flutter/material.dart';
import 'package:tidy/core/theme/app_theme.dart';

/// Compact square toolbar button used across panes (matches app chrome).
class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
    this.label,
    this.size = 30,
    this.iconSize = 16,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool active;

  /// Optional text chip instead of / in addition to icon (e.g. ⌘K).
  final String? label;
  final double size;
  final double iconSize;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = widget.active
        ? theme.selectedBg
        : _hover
            ? theme.hoverBg
            : Colors.transparent;
    final fg = widget.active ? theme.textPrimary : theme.textMuted;

    final child = widget.label != null
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.label!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: fg,
                letterSpacing: -0.2,
              ),
            ),
          )
        : Icon(widget.icon, size: widget.iconSize, color: fg);

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            height: widget.size,
            constraints: BoxConstraints(
              minWidth: widget.size,
              minHeight: widget.size,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
