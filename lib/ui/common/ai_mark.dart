import 'package:flutter/material.dart';

/// Soft pastel AI mark (speech-bubble character) — light/dark assets.
class AiMark extends StatelessWidget {
  const AiMark({
    super.key,
    this.size = 24,
    this.filled = false,
  });

  final double size;

  /// FAB uses a slightly stronger shadow via the parent; asset already has
  /// its own soft badge. [filled] kept for API compatibility.
  final bool filled;

  static const _light = 'assets/ai_mark_light.png';
  static const _dark = 'assets/ai_mark_dark.png';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = isDark ? _dark : _light;

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            // Tiny fallback if assets fail to load
            return DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF3A4A5C)
                    : const Color(0xFFE4E9F8),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: size * 0.45,
                color: isDark
                    ? const Color(0xFFB8C8E8)
                    : const Color(0xFF4A5F8A),
              ),
            );
          },
        ),
      ),
    );
  }
}
