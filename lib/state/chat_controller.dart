import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/ai/openai_client.dart';
import 'package:tidy/ai/tool_executor.dart';
import 'package:tidy/ai/tools.dart';
import 'package:tidy/domain/models/ai_settings.dart';
import 'package:tidy/state/ai_settings_controller.dart';
import 'package:tidy/state/todo_controller.dart';
import 'package:tidy/state/ui_controllers.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum ChatRole { user, assistant, toolNote }

class UiChatMessage extends Equatable {
  const UiChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.toolNames = const [],
    this.isError = false,
  });

  final String id;
  final ChatRole role;
  final String content;
  final List<String> toolNames;
  final bool isError;

  @override
  List<Object?> get props => [id, role, content, toolNames, isError];
}

class ChatState extends Equatable {
  const ChatState({
    this.messages = const [],
    this.isSending = false,
    this.error,
  });

  final List<UiChatMessage> messages;
  final bool isSending;
  final String? error;

  ChatState copyWith({
    List<UiChatMessage>? messages,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [messages, isSending, error];
}

class ChatController extends StateNotifier<ChatState> {
  ChatController(this.ref) : super(const ChatState());

  final Ref ref;
  final _client = OpenAiCompatibleClient();
  final List<ChatMessage> _apiHistory = [];
  static const _maxToolRounds = 8;

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final settings = ref.read(aiSettingsControllerProvider);
    if (!settings.isConfigured) {
      state = state.copyWith(
        error:
            'Add your API key in Settings → AI (BYOK). Supports Groq, xAI, OpenAI, or any OpenAI-compatible endpoint.',
      );
      return;
    }

    final userUi = UiChatMessage(
      id: _uuid.v4(),
      role: ChatRole.user,
      content: trimmed,
    );
    state = state.copyWith(
      messages: [...state.messages, userUi],
      isSending: true,
      clearError: true,
    );

    _apiHistory.add(ChatMessage.user(trimmed));

    try {
      await _runAgentLoop(settings);
    } catch (e) {
      final err = e.toString();
      state = state.copyWith(
        isSending: false,
        error: err,
        messages: [
          ...state.messages,
          UiChatMessage(
            id: _uuid.v4(),
            role: ChatRole.assistant,
            content: 'Something went wrong: $err',
            isError: true,
          ),
        ],
      );
    }
  }

  Future<void> _runAgentLoop(AiSettings settings) async {
    final tools = tidyToolDefinitions();
    final executor = ToolExecutor(ref);
    var rounds = 0;

    while (rounds < _maxToolRounds) {
      rounds++;
      final active = ref.read(activeListIdProvider);
      final snapshot = ref
          .read(todoControllerProvider.notifier)
          .snapshotForAi(activeListId: active);
      final system = ChatMessage.system(tidySystemPrompt(snapshot));

      final result = await _client.chat(
        settings: settings,
        messages: [system, ..._apiHistory],
        tools: tools,
      );

      final assistant = result.message;
      _apiHistory.add(assistant);

      if (!result.hasToolCalls) {
        final content = (assistant.content ?? '').trim();
        if (content.isNotEmpty) {
          state = state.copyWith(
            isSending: false,
            messages: [
              ...state.messages,
              UiChatMessage(
                id: _uuid.v4(),
                role: ChatRole.assistant,
                content: content,
              ),
            ],
          );
        } else {
          state = state.copyWith(isSending: false);
        }
        return;
      }

      final names = <String>[];
      for (final call in assistant.toolCalls!) {
        names.add(call.name);
        final toolResult = await executor.execute(call);
        _apiHistory.add(
          ChatMessage.tool(
            toolCallId: call.id,
            name: call.name,
            content: toolResult,
          ),
        );
      }

      state = state.copyWith(
        messages: [
          ...state.messages,
          UiChatMessage(
            id: _uuid.v4(),
            role: ChatRole.toolNote,
            content: 'Ran: ${names.join(', ')}',
            toolNames: names,
          ),
        ],
      );
    }

    state = state.copyWith(
      isSending: false,
      error: 'Stopped after $_maxToolRounds tool rounds.',
    );
  }

  void clear() {
    _apiHistory.clear();
    state = const ChatState();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref);
});
