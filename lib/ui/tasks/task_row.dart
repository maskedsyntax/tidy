import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/core/theme/app_theme.dart';
import 'package:tidy/domain/models/task.dart';
import 'package:tidy/domain/models/todo_list.dart';
import 'package:tidy/state/todo_controller.dart';
import 'package:tidy/state/ui_controllers.dart';
import 'package:tidy/ui/common/app_checkbox.dart';
import 'package:tidy/ui/common/list_badge.dart';

class TaskRow extends ConsumerStatefulWidget {
  const TaskRow({
    super.key,
    required this.row,
    required this.showListBadge,
    required this.lists,
  });

  final TaskRowData row;
  final bool showListBadge;
  final List<TodoList> lists;

  @override
  ConsumerState<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends ConsumerState<TaskRow> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hover = false;
  bool _focused = false;

  Task get task => widget.row.task;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: task.title);
    _focusNode = FocusNode(
      debugLabel: 'task-${task.id}',
      onKeyEvent: _onKey,
    );
    _focusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoFocus());
  }

  @override
  void didUpdateWidget(covariant TaskRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.row.task.id != task.id) {
      _controller.text = task.title;
    } else if (!_focusNode.hasFocus && _controller.text != task.title) {
      _controller.text = task.title;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoFocus());
  }

  void _maybeAutoFocus() {
    final focusId = ref.read(focusTaskIdProvider);
    if (focusId == task.id && mounted) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
      ref.read(focusTaskIdProvider.notifier).state = null;
    }
  }

  void _onFocusChange() {
    setState(() => _focused = _focusNode.hasFocus);
    if (!_focusNode.hasFocus) {
      _commitTitle();
    }
  }

  void _commitTitle() {
    final text = _controller.text;
    if (text != task.title) {
      ref.read(todoControllerProvider.notifier).updateTitle(task.id, text);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final isTab = event.logicalKey == LogicalKeyboardKey.tab;
    final isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    final isBackspace = event.logicalKey == LogicalKeyboardKey.backspace;
    final shift = HardwareKeyboard.instance.isShiftPressed;

    if (isTab) {
      final controller = ref.read(todoControllerProvider.notifier);
      if (shift) {
        controller.outdent(task.id);
      } else {
        controller.indent(task.id);
      }
      ref.read(focusTaskIdProvider.notifier).state = task.id;
      return KeyEventResult.handled;
    }

    if (isEnter && event is KeyDownEvent) {
      _commitTitle();
      ref
          .read(todoControllerProvider.notifier)
          .addSiblingAfter(task.id)
          .then((t) {
        ref.read(focusTaskIdProvider.notifier).state = t.id;
      });
      return KeyEventResult.handled;
    }

    if (isBackspace &&
        event is KeyDownEvent &&
        _controller.text.isEmpty) {
      ref.read(todoControllerProvider.notifier).deleteTask(task.id);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final depth = widget.row.depth;
    TodoList? list;
    for (final l in widget.lists) {
      if (l.id == task.listId) {
        list = l;
        break;
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        padding: EdgeInsets.only(
          left: 12.0 + depth * 24.0,
          right: 8,
          top: 4,
          bottom: 4,
        ),
        decoration: BoxDecoration(
          color: (_hover || _focused) ? theme.hoverBg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            AppCheckbox(
              value: task.completed,
              onChanged: (_) {
                ref
                    .read(todoControllerProvider.notifier)
                    .toggleComplete(task.id);
              },
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: theme.textTheme.bodyLarge?.copyWith(
                  decoration:
                      task.completed ? TextDecoration.lineThrough : null,
                  color: task.completed
                      ? theme.textMuted
                      : theme.textPrimary,
                  decorationColor: theme.textMuted,
                ),
                cursorColor: AppColors.checkbox,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 6),
                  hintText: 'New task',
                ),
                textInputAction: TextInputAction.done,
                maxLines: 1,
              ),
            ),
            if (widget.showListBadge && list != null) ...[
              const SizedBox(width: 8),
              ListBadge(list: list),
            ],
            const SizedBox(width: 4),
            Opacity(
              opacity: _hover || _focused ? 1 : 0,
              child: PopupMenuButton<String>(
                tooltip: 'More',
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_horiz_rounded,
                    size: 18, color: theme.textMuted),
                onSelected: (value) async {
                  final ctrl = ref.read(todoControllerProvider.notifier);
                  if (value == 'delete') {
                    await ctrl.deleteTask(task.id);
                  } else if (value.startsWith('move:')) {
                    final listId = value.substring(5);
                    await ctrl.moveTaskToList(task.id, listId);
                  }
                },
                itemBuilder: (context) => [
                  for (final l in widget.lists)
                    if (l.id != task.listId)
                      PopupMenuItem(
                        value: 'move:${l.id}',
                        child: Text('Move to ${l.name}'),
                      ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
