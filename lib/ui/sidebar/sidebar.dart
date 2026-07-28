import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/core/icons/list_icons.dart';
import 'package:tidy/core/shortcuts/platform_keys.dart';
import 'package:tidy/core/theme/app_theme.dart';
import 'package:tidy/domain/models/todo_list.dart';
import 'package:tidy/state/settings_controller.dart';
import 'package:tidy/state/todo_controller.dart';
import 'package:tidy/state/ui_controllers.dart';
import 'package:tidy/ui/common/app_icon_button.dart';
import 'package:tidy/ui/dialogs/new_list_dialog.dart';
import 'package:tidy/ui/dialogs/settings_dialog.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final todo = ref.watch(todoControllerProvider);
    final activeId = ref.watch(activeListIdProvider);
    final settings = ref.watch(settingsControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceBg,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: theme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            child: Row(
              children: [
                Text('Lists', style: theme.textTheme.titleMedium),
                const Spacer(),
                AppIconButton(
                  icon: Icons.terminal_rounded,
                  label: shortcutLabel('K'),
                  tooltip: 'Command palette (${shortcutLabel('K')})',
                  onPressed: () =>
                      ref.read(commandPaletteOpenProvider.notifier).state = true,
                ),
                const SizedBox(width: 2),
                AppIconButton(
                  icon: Icons.add_rounded,
                  tooltip: 'New list (${shortcutLabel('N')})',
                  onPressed: () => showNewListDialog(context, ref),
                ),
                const SizedBox(width: 2),
                AppIconButton(
                  icon: Icons.keyboard_double_arrow_left_rounded,
                  tooltip: 'Hide lists (${shortcutLabel('B')})',
                  onPressed: () => ref
                      .read(settingsControllerProvider.notifier)
                      .setListsPaneOpen(false),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.borderColor),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              children: [
                _ListNavItem(
                  icon: Icons.all_inclusive_rounded,
                  label: 'All Tasks',
                  count: todo.countForList(kAllTasksListId),
                  selected: activeId == kAllTasksListId,
                  color: theme.textPrimary,
                  onTap: () => ref.read(activeListIdProvider.notifier).state =
                      kAllTasksListId,
                ),
                for (final list in todo.lists)
                  _ListNavItem(
                    icon: iconForKey(list.iconKey),
                    label: list.name,
                    count: todo.countForList(list.id),
                    selected: activeId == list.id,
                    color: list.color,
                    onTap: () =>
                        ref.read(activeListIdProvider.notifier).state = list.id,
                    onDelete: () => _confirmDeleteList(context, ref, list),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
            child: Row(
              children: [
                AppIconButton(
                  icon: Icons.settings_outlined,
                  tooltip: 'Settings',
                  onPressed: () => showSettingsDialog(context, ref),
                ),
                const SizedBox(width: 2),
                AppIconButton(
                  icon: _themeIcon(settings.themeMode),
                  tooltip: _themeTooltip(settings.themeMode),
                  onPressed: () => ref
                      .read(settingsControllerProvider.notifier)
                      .cycleTheme(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _themeIcon(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => Icons.brightness_auto_outlined,
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
    };
  }

  String _themeTooltip(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'Theme: System (click to cycle)',
      ThemeMode.light => 'Theme: Light (click to cycle)',
      ThemeMode.dark => 'Theme: Dark (click to cycle)',
    };
  }

  Future<void> _confirmDeleteList(
    BuildContext context,
    WidgetRef ref,
    TodoList list,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${list.name}"?'),
        content: const Text(
          'All tasks in this list will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final active = ref.read(activeListIdProvider);
      await ref.read(todoControllerProvider.notifier).deleteList(list.id);
      if (active == list.id) {
        ref.read(activeListIdProvider.notifier).state = kAllTasksListId;
      }
    }
  }
}

class _ListNavItem extends StatefulWidget {
  const _ListNavItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.color,
    required this.onTap,
    this.onDelete,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  State<_ListNavItem> createState() => _ListNavItemState();
}

class _ListNavItemState extends State<_ListNavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTap: widget.onDelete,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected
                ? theme.selectedBg
                : _hover
                    ? theme.hoverBg
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 16, color: widget.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        widget.selected ? FontWeight.w600 : FontWeight.w500,
                    color: theme.textPrimary,
                  ),
                ),
              ),
              if (_hover && widget.onDelete != null)
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.close_rounded,
                        size: 14, color: theme.textMuted),
                  ),
                )
              else
                Text(
                  '${widget.count}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
