import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/core/theme/app_theme.dart';
import 'package:tidy/state/todo_controller.dart';
import 'package:tidy/state/ui_controllers.dart';

class AddTaskField extends ConsumerStatefulWidget {
  const AddTaskField({super.key, required this.listId});

  final String listId;

  @override
  ConsumerState<AddTaskField> createState() => _AddTaskFieldState();
}

class _AddTaskFieldState extends ConsumerState<AddTaskField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _hover = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    final task = await ref.read(todoControllerProvider.notifier).addTask(
          listId: widget.listId,
          title: text,
        );
    _controller.clear();
    ref.read(focusTaskIdProvider.notifier).state = task.id;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: _hover || _focus.hasFocus
              ? theme.hoverBg
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border(
            top: BorderSide(color: theme.borderColor.withValues(alpha: 0.6)),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.add_rounded, size: 18, color: theme.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                style: theme.textTheme.bodyLarge,
                cursorColor: AppColors.checkbox,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintText: 'Add a new task...',
                  hintStyle: TextStyle(color: theme.textMuted, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
