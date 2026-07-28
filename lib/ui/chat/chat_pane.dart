import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/core/shortcuts/platform_keys.dart';
import 'package:tidy/core/theme/app_theme.dart';
import 'package:tidy/state/ai_settings_controller.dart';
import 'package:tidy/state/chat_controller.dart';
import 'package:tidy/ui/common/ai_mark.dart';
import 'package:tidy/ui/common/app_icon_button.dart';
import 'package:tidy/ui/dialogs/settings_dialog.dart';

class ChatPane extends ConsumerStatefulWidget {
  const ChatPane({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  ConsumerState<ChatPane> createState() => _ChatPaneState();
}

class _ChatPaneState extends ConsumerState<ChatPane> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final FocusNode _focus;
  bool _hasText = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode(
      debugLabel: 'chat-composer',
      onKeyEvent: _onComposerKey,
    );
    _input.addListener(() {
      final has = _input.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _focus.addListener(() {
      if (_focused != _focus.hasFocus) {
        setState(() => _focused = _focus.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: AppDurations.normal,
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    if (ref.read(chatControllerProvider).isSending) return;
    _input.clear();
    setState(() => _hasText = false);
    await ref.read(chatControllerProvider.notifier).send(text);
    _scrollToEnd();
    _focus.requestFocus();
  }

  /// Enter → send. Shift+Enter → new line.
  KeyEventResult _onComposerKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (!isEnter) return KeyEventResult.ignored;

    // Shift+Enter: let the field insert a newline.
    if (HardwareKeyboard.instance.isShiftPressed) {
      return KeyEventResult.ignored;
    }

    // Enter alone: send.
    if (_hasText && !ref.read(chatControllerProvider).isSending) {
      _send();
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chat = ref.watch(chatControllerProvider);
    final ai = ref.watch(aiSettingsControllerProvider);

    ref.listen(chatControllerProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length || next.isSending) {
        _scrollToEnd();
      }
    });

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
          // Header: title left, actions stuck right
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            child: Row(
              children: [
                const AiMark(size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Assistant',
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (ai.isConfigured)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 90),
                      child: Text(
                        ai.model.split('/').last,
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 11, color: theme.textMuted),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                AppIconButton(
                  icon: Icons.restart_alt_rounded,
                  tooltip: 'Reset chat',
                  onPressed: () =>
                      ref.read(chatControllerProvider.notifier).clear(),
                ),
                const SizedBox(width: 2),
                AppIconButton(
                  icon: Icons.tune_rounded,
                  tooltip: 'AI settings',
                  onPressed: () => showSettingsDialog(context, ref),
                ),
                if (widget.onClose != null) ...[
                  const SizedBox(width: 2),
                  AppIconButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Hide assistant (${shortcutLabel('J')})',
                    onPressed: widget.onClose!,
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: theme.borderColor),

          Expanded(
            child: chat.messages.isEmpty
                ? _EmptyChat(
                    configured: ai.isConfigured,
                    onOpenSettings: () => showSettingsDialog(context, ref),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    itemCount: chat.messages.length + (chat.isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chat.messages.length && chat.isSending) {
                        return const _TypingIndicator();
                      }
                      return _Bubble(message: chat.messages[index]);
                    },
                  ),
          ),

          if (chat.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Text(
                chat.error!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade400,
                  height: 1.3,
                ),
              ),
            ),

          // Composer — single field with send nested inside (ChatGPT-style)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
            child: AnimatedContainer(
              duration: AppDurations.fast,
              decoration: BoxDecoration(
                color: theme.inputBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _focused
                      ? AppColors.checkbox.withValues(alpha: 0.55)
                      : theme.borderColor,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      focusNode: _focus,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      minLines: 1,
                      maxLines: 12,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                      decoration: const InputDecoration(
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(
                          14,
                          12,
                          8,
                          12,
                        ),
                      ),
                      enabled: !chat.isSending,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6, bottom: 6),
                    child: Tooltip(
                      message: 'Send (Enter)',
                      child: Material(
                        color: (_hasText && !chat.isSending)
                            ? AppColors.checkbox
                            : theme.hoverBg,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap:
                              (_hasText && !chat.isSending) ? _send : null,
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Icon(
                              Icons.arrow_upward_rounded,
                              size: 18,
                              color: (_hasText && !chat.isSending)
                                  ? Colors.white
                                  : theme.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({
    required this.configured,
    required this.onOpenSettings,
  });

  final bool configured;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: 0.9,
              child: const AiMark(size: 40),
            ),
            const SizedBox(height: 12),
            Text(
              configured
                  ? 'Control Tidy with natural language'
                  : 'Bring your own API key',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              configured
                  ? 'Try: “Move Workout to Work” or “Reorder Learning by priority”'
                  : 'Open Settings → AI and paste a Groq, xAI, or OpenAI key.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: theme.textMuted, height: 1.4),
            ),
            if (!configured) ...[
              const SizedBox(height: 14),
              TextButton(
                onPressed: onOpenSettings,
                child: const Text('Open Settings'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final UiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (message.role == ChatRole.toolNote) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.hoverBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.content,
              style: TextStyle(fontSize: 11, color: theme.textMuted),
            ),
          ),
        ),
      );
    }

    final isUser = message.role == ChatRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.checkbox.withValues(alpha: theme.isDark ? 0.25 : 0.12)
              : theme.hoverBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isUser ? 12 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 12),
          ),
          border: message.isError
              ? Border.all(color: Colors.red.withValues(alpha: 0.4))
              : null,
        ),
        child: SelectableText(
          message.content,
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: message.isError ? Colors.red.shade300 : theme.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Thinking…',
            style: TextStyle(fontSize: 12, color: theme.textMuted),
          ),
        ],
      ),
    );
  }
}
