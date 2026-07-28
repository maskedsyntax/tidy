import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/core/icons/list_icons.dart';
import 'package:tidy/core/shortcuts/platform_keys.dart';
import 'package:tidy/core/theme/app_theme.dart';
import 'package:tidy/domain/models/todo_list.dart';
import 'package:tidy/state/settings_controller.dart';
import 'package:tidy/state/todo_controller.dart';
import 'package:tidy/state/ui_controllers.dart';
import 'package:tidy/ui/dialogs/about_dialog.dart';
import 'package:tidy/ui/dialogs/new_list_dialog.dart';
import 'package:tidy/ui/dialogs/settings_dialog.dart';

enum _CmdSection { theme, navigation, actions }

class _Command {
  const _Command({
    required this.id,
    required this.section,
    required this.label,
    required this.icon,
    this.shortcut,
    this.color,
    required this.run,
    this.isSelected = false,
  });

  final String id;
  final _CmdSection section;
  final String label;
  final IconData icon;
  final String? shortcut;
  final Color? color;
  final VoidCallback run;
  final bool isSelected;
}

class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette>
    with SingleTickerProviderStateMixin {
  final _query = TextEditingController();
  final _focus = FocusNode();
  int _index = 0;
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: AppDurations.palette);
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _scale = Tween(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
    );
    _anim.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _close() {
    ref.read(commandPaletteOpenProvider.notifier).state = false;
  }

  List<_Command> _buildCommands() {
    final todo = ref.read(todoControllerProvider);
    final settings = ref.read(settingsControllerProvider);
    final mode = settings.themeMode;
    final lists = todo.lists;

    final cmds = <_Command>[
      _Command(
        id: 'theme-system',
        section: _CmdSection.theme,
        label: 'System',
        icon: Icons.brightness_auto_outlined,
        isSelected: mode == ThemeMode.system,
        run: () {
          ref
              .read(settingsControllerProvider.notifier)
              .setThemeMode(ThemeMode.system);
          _close();
        },
      ),
      _Command(
        id: 'theme-light',
        section: _CmdSection.theme,
        label: 'Light',
        icon: Icons.light_mode_outlined,
        isSelected: mode == ThemeMode.light,
        run: () {
          ref
              .read(settingsControllerProvider.notifier)
              .setThemeMode(ThemeMode.light);
          _close();
        },
      ),
      _Command(
        id: 'theme-dark',
        section: _CmdSection.theme,
        label: 'Dark',
        icon: Icons.dark_mode_outlined,
        isSelected: mode == ThemeMode.dark,
        run: () {
          ref
              .read(settingsControllerProvider.notifier)
              .setThemeMode(ThemeMode.dark);
          _close();
        },
      ),
      _Command(
        id: 'nav-all',
        section: _CmdSection.navigation,
        label: 'All Tasks',
        icon: Icons.all_inclusive_rounded,
        shortcut: shortcutLabel('1'),
        run: () {
          ref.read(activeListIdProvider.notifier).state = kAllTasksListId;
          _close();
        },
      ),
      for (var i = 0; i < lists.length && i < 8; i++)
        _Command(
          id: 'nav-${lists[i].id}',
          section: _CmdSection.navigation,
          label: lists[i].name,
          icon: iconForKey(lists[i].iconKey),
          color: lists[i].color,
          shortcut: shortcutLabel('${i + 2}'),
          run: () {
            ref.read(activeListIdProvider.notifier).state = lists[i].id;
            _close();
          },
        ),
      _Command(
        id: 'action-new-list',
        section: _CmdSection.actions,
        label: 'New List',
        icon: Icons.add_rounded,
        shortcut: shortcutLabel('N'),
        run: () {
          _close();
          showNewListDialog(context, ref);
        },
      ),
      _Command(
        id: 'action-settings',
        section: _CmdSection.actions,
        label: 'Settings',
        icon: Icons.settings_outlined,
        shortcut: ',',
        run: () {
          _close();
          showSettingsDialog(context, ref);
        },
      ),
      _Command(
        id: 'action-about',
        section: _CmdSection.actions,
        label: 'About',
        icon: Icons.info_outline_rounded,
        run: () {
          _close();
          showTidyAboutDialog(context);
        },
      ),
    ];

    final q = _query.text.trim().toLowerCase();
    if (q.isEmpty) return cmds;
    return cmds.where((c) => c.label.toLowerCase().contains(q)).toList();
  }

  void _runSelected(List<_Command> cmds) {
    if (cmds.isEmpty) return;
    final i = _index.clamp(0, cmds.length - 1);
    cmds[i].run();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final cmds = _buildCommands();

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _close();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() => _index = cmds.isEmpty ? 0 : (_index + 1) % cmds.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() => _index =
          cmds.isEmpty ? 0 : (_index - 1 + cmds.length) % cmds.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _runSelected(cmds);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    final cmds = _buildCommands();
    if (_index >= cmds.length) _index = 0;

    // Group for section headers
    final sections = <_CmdSection, List<_Command>>{};
    for (final c in cmds) {
      sections.putIfAbsent(c.section, () => []).add(c);
    }

    final panel = Material(
      color: theme.surfaceBg,
      elevation: 24,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(AppRadii.xl),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 18, color: theme.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Focus(
                      onKeyEvent: _onKey,
                      child: TextField(
                        controller: _query,
                        focusNode: _focus,
                        style: theme.textTheme.bodyLarge,
                        cursorColor: AppColors.checkbox,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Type a command...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onChanged: (_) => setState(() => _index = 0),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.hoverBg,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      shortcutLabel('K'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.borderColor),
            Flexible(
              child: cmds.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No commands found',
                        style: TextStyle(color: theme.textMuted),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      children: [
                        for (final section in _CmdSection.values)
                          if (sections[section]?.isNotEmpty == true) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                              child: Text(
                                section.name.toUpperCase(),
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                            for (final cmd in sections[section]!)
                              _CommandTile(
                                command: cmd,
                                selected: cmds.indexOf(cmd) == _index,
                                onTap: cmd.run,
                                onHover: () => setState(
                                  () => _index = cmds.indexOf(cmd),
                                ),
                              ),
                          ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Scrim
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              child: FadeTransition(
                opacity: reduce ? const AlwaysStoppedAnimation(1) : _fade,
                child: Container(color: AppColors.paletteScrim),
              ),
            ),
          ),
          // Panel
          Center(
            child: reduce
                ? panel
                : FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(scale: _scale, child: panel),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CommandTile extends StatelessWidget {
  const _CommandTile({
    required this.command,
    required this.selected,
    required this.onTap,
    required this.onHover,
  });

  final _Command command;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => onHover(),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? theme.selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              Icon(
                command.icon,
                size: 16,
                color: command.color ?? theme.textPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  command.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.textPrimary,
                  ),
                ),
              ),
              if (command.isSelected)
                Icon(Icons.check_rounded, size: 16, color: theme.textMuted)
              else if (command.shortcut != null)
                Text(
                  command.shortcut!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
