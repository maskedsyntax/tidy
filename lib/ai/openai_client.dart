import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tidy/domain/models/ai_settings.dart';

class ChatMessage {
  ChatMessage({
    required this.role,
    this.content,
    this.toolCalls,
    this.toolCallId,
    this.name,
  });

  final String role; // system | user | assistant | tool
  final String? content;
  final List<ToolCall>? toolCalls;
  final String? toolCallId;
  final String? name;

  Map<String, dynamic> toApiJson() {
    final map = <String, dynamic>{'role': role};
    if (content != null) map['content'] = content;
    if (toolCalls != null && toolCalls!.isNotEmpty) {
      map['tool_calls'] = [for (final t in toolCalls!) t.toApiJson()];
    }
    if (toolCallId != null) map['tool_call_id'] = toolCallId;
    if (name != null) map['name'] = name;
    // Some providers require content even when tool_calls present
    if (role == 'assistant' && content == null && toolCalls != null) {
      map['content'] = null;
    }
    return map;
  }

  factory ChatMessage.system(String content) =>
      ChatMessage(role: 'system', content: content);

  factory ChatMessage.user(String content) =>
      ChatMessage(role: 'user', content: content);

  factory ChatMessage.assistant(String? content, {List<ToolCall>? toolCalls}) =>
      ChatMessage(role: 'assistant', content: content, toolCalls: toolCalls);

  factory ChatMessage.tool({
    required String toolCallId,
    required String name,
    required String content,
  }) =>
      ChatMessage(
        role: 'tool',
        toolCallId: toolCallId,
        name: name,
        content: content,
      );
}

class ToolCall {
  ToolCall({
    required this.id,
    required this.name,
    required this.argumentsJson,
  });

  final String id;
  final String name;
  final String argumentsJson;

  Map<String, dynamic> toApiJson() => {
        'id': id,
        'type': 'function',
        'function': {
          'name': name,
          'arguments': argumentsJson,
        },
      };

  Map<String, dynamic> parseArgs() {
    if (argumentsJson.trim().isEmpty) return {};
    final decoded = jsonDecode(argumentsJson);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {};
  }
}

class ChatCompletionResult {
  ChatCompletionResult({
    required this.message,
    required this.finishReason,
  });

  final ChatMessage message;
  final String? finishReason;

  bool get hasToolCalls =>
      message.toolCalls != null && message.toolCalls!.isNotEmpty;
}

class OpenAiCompatibleClient {
  OpenAiCompatibleClient({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;

  Future<ChatCompletionResult> chat({
    required AiSettings settings,
    required List<ChatMessage> messages,
    required List<Map<String, dynamic>> tools,
    double temperature = 0.2,
  }) async {
    final base = settings.baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base/chat/completions');

    final body = <String, dynamic>{
      'model': settings.model.trim(),
      'messages': [for (final m in messages) m.toApiJson()],
      'temperature': temperature,
      if (tools.isNotEmpty) 'tools': tools,
      if (tools.isNotEmpty) 'tool_choice': 'auto',
    };

    final response = await _http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${settings.apiKey.trim()}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiClientException(
        'HTTP ${response.statusCode}: ${_truncate(response.body)}',
        statusCode: response.statusCode,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw AiClientException('Empty choices from provider');
    }
    final choice = choices.first as Map<String, dynamic>;
    final msg = choice['message'] as Map<String, dynamic>;
    final finish = choice['finish_reason'] as String?;

    final toolCallsRaw = msg['tool_calls'] as List<dynamic>?;
    final toolCalls = <ToolCall>[];
    if (toolCallsRaw != null) {
      for (final raw in toolCallsRaw) {
        final m = raw as Map<String, dynamic>;
        final fn = m['function'] as Map<String, dynamic>? ?? {};
        toolCalls.add(
          ToolCall(
            id: m['id'] as String? ?? 'call_${toolCalls.length}',
            name: fn['name'] as String? ?? '',
            argumentsJson: fn['arguments'] as String? ?? '{}',
          ),
        );
      }
    }

    final content = msg['content'];
    return ChatCompletionResult(
      message: ChatMessage.assistant(
        content is String ? content : content?.toString(),
        toolCalls: toolCalls.isEmpty ? null : toolCalls,
      ),
      finishReason: finish,
    );
  }

  String _truncate(String s, [int max = 400]) {
    final t = s.trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max)}…';
  }

  void close() => _http.close();
}

class AiClientException implements Exception {
  AiClientException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
