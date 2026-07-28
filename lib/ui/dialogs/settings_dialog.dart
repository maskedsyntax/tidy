import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/core/theme/app_theme.dart';
import 'package:tidy/domain/models/ai_settings.dart';
import 'package:tidy/state/ai_settings_controller.dart';
import 'package:tidy/state/settings_controller.dart';

Future<void> showSettingsDialog(BuildContext context, WidgetRef ref) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => const _SettingsDialog(),
  );
}

class _SettingsDialog extends ConsumerStatefulWidget {
  const _SettingsDialog();

  @override
  ConsumerState<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<_SettingsDialog> {
  late TextEditingController _baseUrl;
  late TextEditingController _model;
  late TextEditingController _apiKey;
  bool _obscureKey = true;
  String _providerId = 'groq';

  @override
  void initState() {
    super.initState();
    final ai = ref.read(aiSettingsControllerProvider);
    _providerId = ai.providerId;
    _baseUrl = TextEditingController(text: ai.baseUrl);
    _model = TextEditingController(text: ai.model);
    _apiKey = TextEditingController(text: ai.apiKey);
  }

  @override
  void dispose() {
    _baseUrl.dispose();
    _model.dispose();
    _apiKey.dispose();
    super.dispose();
  }

  Future<void> _saveAi() async {
    await ref.read(aiSettingsControllerProvider.notifier).update(
          AiSettings(
            providerId: _providerId,
            baseUrl: _baseUrl.text.trim(),
            model: _model.text.trim(),
            apiKey: _apiKey.text.trim(),
          ),
        );
  }

  void _onPreset(AiProviderPreset preset) {
    setState(() {
      _providerId = preset.id;
      if (preset.id != 'custom') {
        _baseUrl.text = preset.baseUrl;
        _model.text = preset.defaultModel;
      }
    });
    ref.read(aiSettingsControllerProvider.notifier).applyPreset(preset);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Settings'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('THEME', style: theme.textTheme.labelSmall),
              const SizedBox(height: 8),
              for (final mode in ThemeMode.values)
                _ThemeOption(
                  mode: mode,
                  selected: settings.themeMode == mode,
                  onTap: () => ref
                      .read(settingsControllerProvider.notifier)
                      .setThemeMode(mode),
                ),
              const SizedBox(height: 18),
              Text('AI (BRING YOUR OWN KEY)',
                  style: theme.textTheme.labelSmall),
              const SizedBox(height: 6),
              Text(
                'Keys stay on this device. Uses the OpenAI Chat Completions API shape, so Groq, xAI, OpenAI, OpenRouter, and other compatible hosts work.',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final p in kAiProviderPresets)
                    ChoiceChip(
                      label: Text(p.label, style: const TextStyle(fontSize: 12)),
                      selected: _providerId == p.id,
                      onSelected: (_) => _onPreset(p),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _baseUrl,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: 'https://api.groq.com/openai/v1',
                ),
                style: const TextStyle(fontSize: 13),
                onChanged: (_) => setState(() => _providerId = 'custom'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _model,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  hintText: 'llama-3.3-70b-versatile',
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _apiKey,
                obscureText: _obscureKey,
                decoration: InputDecoration(
                  labelText: 'API key',
                  hintText: 'sk-…',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureKey
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _obscureKey = !_obscureKey),
                  ),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await _saveAi();
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, label) = switch (mode) {
      ThemeMode.system => (Icons.brightness_auto_outlined, 'System'),
      ThemeMode.light => (Icons.light_mode_outlined, 'Light'),
      ThemeMode.dark => (Icons.dark_mode_outlined, 'Dark'),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? theme.selectedBg : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: theme.textPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_rounded, size: 16, color: theme.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
