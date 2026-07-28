import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/core/icons/list_icons.dart';
import 'package:tidy/core/theme/app_theme.dart';
import 'package:tidy/state/todo_controller.dart';
import 'package:tidy/state/ui_controllers.dart';

Future<void> showNewListDialog(BuildContext context, WidgetRef ref) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => const _NewListDialog(),
  );
}

class _NewListDialog extends ConsumerStatefulWidget {
  const _NewListDialog();

  @override
  ConsumerState<_NewListDialog> createState() => _NewListDialogState();
}

class _NewListDialogState extends ConsumerState<_NewListDialog> {
  final _name = TextEditingController();
  String _iconKey = kListIconKeys.first;
  Color _color = kListColorPresets.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final list = await ref.read(todoControllerProvider.notifier).createList(
          name: _name.text,
          iconKey: _iconKey,
          colorValue: _color.toARGB32(),
        );
    if (mounted) {
      ref.read(activeListIdProvider.notifier).state = list.id;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('New List'),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'List name'),
              onSubmitted: (_) => _create(),
            ),
            const SizedBox(height: 16),
            Text('Icon', style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final key in kListIconKeys)
                  _PickChip(
                    selected: _iconKey == key,
                    onTap: () => setState(() => _iconKey = key),
                    child: Icon(
                      iconForKey(key),
                      size: 18,
                      color: _iconKey == key ? _color : theme.textPrimary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Color', style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final c in kListColorPresets)
                  _PickChip(
                    selected: _color == c,
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: _color == c
                            ? Border.all(color: theme.textPrimary, width: 2)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _create,
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _PickChip extends StatelessWidget {
  const _PickChip({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? theme.selectedBg : theme.hoverBg,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(child: child),
        ),
      ),
    );
  }
}
