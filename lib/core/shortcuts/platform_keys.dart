import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Platform-aware modifier for shortcut labels and LogicalKeySet.
bool get isApple =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS);

String get modSymbol => isApple ? '⌘' : 'Ctrl';

String shortcutLabel(String key) => '$modSymbol$key';

/// Primary modifier key (Meta on Apple, Control elsewhere).
LogicalKeyboardKey get primaryModifier =>
    isApple ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control;

SingleActivator primaryActivator(LogicalKeyboardKey key, {bool shift = false}) {
  return SingleActivator(
    key,
    meta: isApple,
    control: !isApple,
    shift: shift,
  );
}
