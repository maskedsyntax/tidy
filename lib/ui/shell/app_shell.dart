import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/core/shortcuts/platform_keys.dart';
import 'package:tidy/core/theme/app_theme.dart';
import 'package:tidy/domain/models/todo_list.dart';
import 'package:tidy/state/todo_controller.dart';
import 'package:tidy/state/ui_controllers.dart';
import 'package:tidy/ui/dialogs/new_list_dialog.dart';
import 'package:tidy/ui/palette/command_palette.dart';
import 'package:tidy/ui/sidebar/sidebar.dart';
import 'package:tidy/ui/tasks/task_list_view.dart';

class OpenPaletteIntent extends Intent {
  const OpenPaletteIntent();
}

class NewListIntent extends Intent {
  const NewListIntent();
}

class GoToListIntent extends Intent {
  const GoToListIntent(this.index);
  final int index; // 0 = All Tasks, 1+ = lists
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
    // Global handler so shortcuts work even when a TextField has focus.
    // Flutter's Shortcuts widget often fails to fire for Meta/Control combos
    // while an EditableText is focused.
    HardwareKeyboard.instance.addHandler(_handleGlobalKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKey);
    super.dispose();
  }

  bool _isPrimaryModifierPressed() {
    if (isApple) {
      return HardwareKeyboard.instance.isMetaPressed;
    }
    return HardwareKeyboard.instance.isControlPressed;
  }

  bool _handleGlobalKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (!_isPrimaryModifierPressed()) return false;

    final key = event.logicalKey;
    final lists = ref.read(todoControllerProvider).lists;

    // ⌘/Ctrl+K — toggle command palette
    if (key == LogicalKeyboardKey.keyK) {
      final open = ref.read(commandPaletteOpenProvider);
      ref.read(commandPaletteOpenProvider.notifier).state = !open;
      return true;
    }

    // ⌘/Ctrl+N — new list (ignore while palette filter field is typing… still ok)
    if (key == LogicalKeyboardKey.keyN) {
      // Don't open while a dialog might already be up; still safe to invoke.
      if (ref.read(commandPaletteOpenProvider)) {
        ref.read(commandPaletteOpenProvider.notifier).state = false;
      }
      showNewListDialog(context, ref);
      return true;
    }

    // ⌘/Ctrl+1…9 — switch list
    final digitIndex = _digitIndex(key);
    if (digitIndex != null) {
      if (digitIndex == 0) {
        ref.read(activeListIdProvider.notifier).state = kAllTasksListId;
      } else {
        final i = digitIndex - 1;
        if (i >= 0 && i < lists.length) {
          ref.read(activeListIdProvider.notifier).state = lists[i].id;
        }
      }
      if (ref.read(commandPaletteOpenProvider)) {
        ref.read(commandPaletteOpenProvider.notifier).state = false;
      }
      return true;
    }

    return false;
  }

  int? _digitIndex(LogicalKeyboardKey key) {
    const digits = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
      LogicalKeyboardKey.digit7,
      LogicalKeyboardKey.digit8,
      LogicalKeyboardKey.digit9,
    ];
    // Also accept numpad
    const numpad = [
      LogicalKeyboardKey.numpad1,
      LogicalKeyboardKey.numpad2,
      LogicalKeyboardKey.numpad3,
      LogicalKeyboardKey.numpad4,
      LogicalKeyboardKey.numpad5,
      LogicalKeyboardKey.numpad6,
      LogicalKeyboardKey.numpad7,
      LogicalKeyboardKey.numpad8,
      LogicalKeyboardKey.numpad9,
    ];
    final i = digits.indexOf(key);
    if (i >= 0) return i;
    final n = numpad.indexOf(key);
    if (n >= 0) return n;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paletteOpen = ref.watch(commandPaletteOpenProvider);
    final lists = ref.watch(todoControllerProvider).lists;

    // Keep Shortcuts/Actions as a secondary path (e.g. for semantics / tests).
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        primaryActivator(LogicalKeyboardKey.keyK): const OpenPaletteIntent(),
        primaryActivator(LogicalKeyboardKey.keyN): const NewListIntent(),
        primaryActivator(LogicalKeyboardKey.digit1): const GoToListIntent(0),
        primaryActivator(LogicalKeyboardKey.digit2): const GoToListIntent(1),
        primaryActivator(LogicalKeyboardKey.digit3): const GoToListIntent(2),
        primaryActivator(LogicalKeyboardKey.digit4): const GoToListIntent(3),
        primaryActivator(LogicalKeyboardKey.digit5): const GoToListIntent(4),
        primaryActivator(LogicalKeyboardKey.digit6): const GoToListIntent(5),
        primaryActivator(LogicalKeyboardKey.digit7): const GoToListIntent(6),
        primaryActivator(LogicalKeyboardKey.digit8): const GoToListIntent(7),
        primaryActivator(LogicalKeyboardKey.digit9): const GoToListIntent(8),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          OpenPaletteIntent: CallbackAction<OpenPaletteIntent>(
            onInvoke: (_) {
              final open = ref.read(commandPaletteOpenProvider);
              ref.read(commandPaletteOpenProvider.notifier).state = !open;
              return null;
            },
          ),
          NewListIntent: CallbackAction<NewListIntent>(
            onInvoke: (_) {
              showNewListDialog(context, ref);
              return null;
            },
          ),
          GoToListIntent: CallbackAction<GoToListIntent>(
            onInvoke: (intent) {
              if (intent.index == 0) {
                ref.read(activeListIdProvider.notifier).state = kAllTasksListId;
              } else {
                final i = intent.index - 1;
                if (i >= 0 && i < lists.length) {
                  ref.read(activeListIdProvider.notifier).state = lists[i].id;
                }
              }
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: theme.appBg,
                body: Row(
                  children: [
                    const AppSidebar(),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.surfaceBg,
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                          border: Border.all(color: theme.borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: theme.isDark ? 0.25 : 0.04,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: const TaskListView(),
                      ),
                    ),
                  ],
                ),
              ),
              if (paletteOpen) const CommandPalette(),
            ],
          ),
        ),
      ),
    );
  }
}
