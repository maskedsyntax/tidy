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
import 'package:tidy/ui/tasks/add_task_field.dart';
import 'package:tidy/ui/tasks/task_row.dart';

class TaskListView extends ConsumerWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final todo = ref.watch(todoControllerProvider);
    final activeId = ref.watch(activeListIdProvider);
    final search = ref.watch(searchQueryProvider);
    final layout = ref.watch(settingsControllerProvider);
    final settingsCtrl = ref.read(settingsControllerProvider.notifier);

    if (!todo.loaded) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final rows = todo.rowsFor(listId: activeId, search: search);
    final showBadge = activeId == kAllTasksListId;

    final titleIcon = activeId == kAllTasksListId
        ? 'infinity'
        : (todo.listById(activeId)?.iconKey ?? 'list');
    final titleLabel = activeId == kAllTasksListId
        ? 'All Tasks'
        : (todo.listById(activeId)?.name ?? 'Tasks');
    final titleColor = activeId == kAllTasksListId
        ? theme.textPrimary
        : (todo.listById(activeId)?.color ?? theme.textPrimary);

    final bothHidden = !layout.listsPaneOpen && !layout.chatPaneOpen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              // Only show "open lists" when the lists pane is hidden
              if (!layout.listsPaneOpen) ...[
                AppIconButton(
                  icon: Icons.view_sidebar_outlined,
                  tooltip: 'Show lists (${shortcutLabel('B')})',
                  onPressed: () => settingsCtrl.setListsPaneOpen(true),
                ),
                const SizedBox(width: 4),
              ],
              AppIconButton(
                icon: bothHidden
                    ? Icons.view_column_outlined
                    : Icons.center_focus_strong_outlined,
                tooltip: bothHidden
                    ? 'Full mode (${shortcutLabel('⇧.')})'
                    : 'Focus mode — tasks only (${shortcutLabel('.')})',
                active: bothHidden,
                onPressed: () {
                  if (bothHidden) {
                    settingsCtrl.enterFullMode();
                  } else {
                    settingsCtrl.enterFocusMode();
                  }
                },
              ),
              const SizedBox(width: 12),
              Icon(iconForKey(titleIcon), size: 18, color: titleColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titleLabel,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 200,
                child: _SearchField(
                  value: search,
                  onChanged: (v) =>
                      ref.read(searchQueryProvider.notifier).state = v,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: AnimatedSwitcher(
            duration: AppDurations.normal,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: rows.isEmpty
                ? _EmptyState(
                    key: ValueKey('empty-$activeId-$search'),
                    hasSearch: search.trim().isNotEmpty,
                  )
                : ListView.builder(
                    key: ValueKey('list-$activeId'),
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      final prev = index > 0 ? rows[index - 1] : null;
                      final showDivider = showBadge &&
                          row.depth == 0 &&
                          prev != null &&
                          prev.task.listId != row.task.listId;

                      return Column(
                        key: ValueKey(row.task.id),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showDivider)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Divider(
                                height: 1,
                                color: theme.borderColor,
                              ),
                            ),
                          TaskRow(
                            row: row,
                            showListBadge: showBadge,
                            lists: todo.lists,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
        AddTaskField(listId: activeId),
      ],
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search',
        prefixIcon:
            Icon(Icons.search_rounded, size: 18, color: theme.textMuted),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 36, minHeight: 32),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        filled: true,
        fillColor: theme.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key, required this.hasSearch});

  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasSearch ? Icons.search_off_rounded : Icons.inbox_outlined,
            size: 36,
            color: theme.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            hasSearch ? 'No matches' : 'No tasks yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasSearch
                ? 'Try a different search'
                : 'Add a task below to get started',
            style: TextStyle(fontSize: 12, color: theme.textMuted),
          ),
        ],
      ),
    );
  }
}
