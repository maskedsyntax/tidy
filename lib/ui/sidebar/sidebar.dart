import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/core/icons/list_icons.dart';
import 'package:tidy/core/shortcuts/platform_keys.dart';
import 'package:tidy/core/theme/app_theme.dart';
import 'package:tidy/domain/models/todo_list.dart';
import 'package:tidy/state/settings_controller.dart';
import 'package:tidy/state/todo_controller.dart';
import 'package:tidy/state/ui_controllers.dart';
import 'package:tidy/ui/common/hover_surface.dart';
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
      width: 240,
      decoration: BoxDecoration(
        color: theme.sidebarBg,
        border: Border(
          right: BorderSide(color: theme.borderColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 14),
          // Header: title + command palette
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Text(
                  'Todo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                _IconChip(
                  tooltip: 'Command palette (${shortcutLabel('K')})',
                  label: shortcutLabel('K'),
                  onTap: () =>
                      ref.read(commandPaletteOpenProvider.notifier).state = true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'LISTS',
              style: theme.textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _ListNavItem(
                  icon: Icons.all_inclusive_rounded,
                  label: 'All Tasks',
                  count: todo.countForList(kAllTasksListId),
                  selected: activeId == kAllTasksListId,
                  color: theme.textPrimary,
                  onTap: () =>
                      ref.read(activeListIdProvider.notifier).state =
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
                const SizedBox(height: 4),
                HoverSurface(
                  onTap: () => showNewListDialog(context, ref),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.add_rounded,
                          size: 16, color: theme.textMuted),
                      const SizedBox(width: 8),
                      Text(
                        'New List',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            child: Row(
              children: [
                _FooterIcon(
                  icon: Icons.settings_outlined,
                  tooltip: 'Settings',
                  onTap: () => showSettingsDialog(context, ref),
                ),
                const SizedBox(width: 4),
                _FooterIcon(
                  icon: _themeIcon(settings.themeMode),
                  tooltip: _themeTooltip(settings.themeMode),
                  onTap: () =>
                      ref.read(settingsControllerProvider.notifier).cycleTheme(),
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

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.label,
    required this.onTap,
    this.tooltip,
  });

  final String label;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = HoverSurface(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      borderRadius: BorderRadius.circular(6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.textMuted,
          letterSpacing: -0.2,
        ),
      ),
    );
    if (tooltip == null) return child;
    return Tooltip(message: tooltip!, child: child);
  }
}

class _FooterIcon extends StatelessWidget {
  const _FooterIcon({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = HoverSurface(
      onTap: onTap,
      padding: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      child: Icon(icon, size: 18, color: theme.textMuted),
    );
    if (tooltip == null) return child;
    return Tooltip(message: tooltip!, child: child);
  }
}
