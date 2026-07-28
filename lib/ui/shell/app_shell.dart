import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/core/shortcuts/platform_keys.dart';
import 'package:tidy/core/theme/app_theme.dart';
import 'package:tidy/domain/models/todo_list.dart';
import 'package:tidy/state/settings_controller.dart';
import 'package:tidy/state/todo_controller.dart';
import 'package:tidy/state/ui_controllers.dart';
import 'package:tidy/ui/chat/chat_pane.dart';
import 'package:tidy/ui/common/ai_mark.dart';
import 'package:tidy/ui/common/pane_toggle.dart';
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

class ToggleListsIntent extends Intent {
  const ToggleListsIntent();
}

class ToggleChatIntent extends Intent {
  const ToggleChatIntent();
}

class FocusModeIntent extends Intent {
  const FocusModeIntent();
}

class FullModeIntent extends Intent {
  const FullModeIntent();
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
    final settings = ref.read(settingsControllerProvider.notifier);
    final shift = HardwareKeyboard.instance.isShiftPressed;

    // ⌘/Ctrl+K — command palette
    if (key == LogicalKeyboardKey.keyK) {
      final open = ref.read(commandPaletteOpenProvider);
      ref.read(commandPaletteOpenProvider.notifier).state = !open;
      return true;
    }

    // ⌘/Ctrl+B — toggle lists sidebar
    if (key == LogicalKeyboardKey.keyB) {
      settings.toggleListsPane();
      return true;
    }

    // ⌘/Ctrl+J — toggle AI chat
    if (key == LogicalKeyboardKey.keyJ) {
      settings.toggleChatPane();
      return true;
    }

    // ⌘/Ctrl+. — focus mode (hide both)
    // ⌘/Ctrl+Shift+. — full mode (show both)
    if (key == LogicalKeyboardKey.period) {
      if (shift) {
        settings.enterFullMode();
      } else {
        settings.enterFocusMode();
      }
      return true;
    }

    // ⌘/Ctrl+N — new list
    if (key == LogicalKeyboardKey.keyN) {
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
    final layout = ref.watch(settingsControllerProvider);
    final listsOpen = layout.listsPaneOpen;
    final chatOpen = layout.chatPaneOpen;
    final lists = ref.watch(todoControllerProvider).lists;
    final settingsCtrl = ref.read(settingsControllerProvider.notifier);

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        primaryActivator(LogicalKeyboardKey.keyK): const OpenPaletteIntent(),
        primaryActivator(LogicalKeyboardKey.keyB): const ToggleListsIntent(),
        primaryActivator(LogicalKeyboardKey.keyJ): const ToggleChatIntent(),
        primaryActivator(LogicalKeyboardKey.period): const FocusModeIntent(),
        primaryActivator(LogicalKeyboardKey.period, shift: true):
            const FullModeIntent(),
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
          ToggleListsIntent: CallbackAction<ToggleListsIntent>(
            onInvoke: (_) {
              settingsCtrl.toggleListsPane();
              return null;
            },
          ),
          ToggleChatIntent: CallbackAction<ToggleChatIntent>(
            onInvoke: (_) {
              settingsCtrl.toggleChatPane();
              return null;
            },
          ),
          FocusModeIntent: CallbackAction<FocusModeIntent>(
            onInvoke: (_) {
              settingsCtrl.enterFocusMode();
              return null;
            },
          ),
          FullModeIntent: CallbackAction<FullModeIntent>(
            onInvoke: (_) {
              settingsCtrl.enterFullMode();
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
                    SlidingPane(
                      open: listsOpen,
                      width: 256,
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 6, 10),
                        child: AppSidebar(),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(
                          listsOpen ? 0 : 10,
                          10,
                          chatOpen ? 6 : 10,
                          10,
                        ),
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
                    SlidingPane(
                      open: chatOpen,
                      width: 340,
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                        child: ChatPane(
                          onClose: () => settingsCtrl.setChatPaneOpen(false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Floating AI launcher — only when chat pane is closed
              if (!chatOpen)
                Positioned(
                  right: 22,
                  bottom: 22,
                  child: _AiFab(
                    onPressed: () => settingsCtrl.setChatPaneOpen(true),
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

class _AiFab extends StatefulWidget {
  const _AiFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_AiFab> createState() => _AiFabState();
}

class _AiFabState extends State<_AiFab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: 'Assistant (${shortcutLabel('J')})',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: _hover ? 1.05 : 1.0,
            duration: AppDurations.fast,
            child: AnimatedContainer(
              duration: AppDurations.fast,
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (theme.isDark
                            ? const Color(0xFF6B8CFF)
                            : AppColors.checkbox)
                        .withValues(alpha: theme.isDark ? 0.25 : 0.22),
                    blurRadius: _hover ? 20 : 14,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: theme.isDark ? 0.4 : 0.1,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const AiMark(size: 56, filled: true),
            ),
          ),
        ),
      ),
    );
  }
}
