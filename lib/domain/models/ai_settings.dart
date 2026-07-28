import 'package:equatable/equatable.dart';

/// Preset OpenAI-compatible providers (BYOK).
class AiProviderPreset {
  const AiProviderPreset({
    required this.id,
    required this.label,
    required this.baseUrl,
    required this.defaultModel,
    this.hint,
  });

  final String id;
  final String label;
  final String baseUrl;
  final String defaultModel;
  final String? hint;
}

const kAiProviderPresets = <AiProviderPreset>[
  AiProviderPreset(
    id: 'groq',
    label: 'Groq',
    baseUrl: 'https://api.groq.com/openai/v1',
    defaultModel: 'llama-3.3-70b-versatile',
    hint: 'console.groq.com',
  ),
  AiProviderPreset(
    id: 'xai',
    label: 'xAI (Grok)',
    baseUrl: 'https://api.x.ai/v1',
    defaultModel: 'grok-4.5',
    hint: 'console.x.ai',
  ),
  AiProviderPreset(
    id: 'openai',
    label: 'OpenAI',
    baseUrl: 'https://api.openai.com/v1',
    defaultModel: 'gpt-4o-mini',
    hint: 'platform.openai.com',
  ),
  AiProviderPreset(
    id: 'openrouter',
    label: 'OpenRouter',
    baseUrl: 'https://openrouter.ai/api/v1',
    defaultModel: 'openai/gpt-4o-mini',
    hint: 'openrouter.ai',
  ),
  AiProviderPreset(
    id: 'custom',
    label: 'Custom',
    baseUrl: '',
    defaultModel: '',
    hint: 'Any OpenAI-compatible base URL',
  ),
];

class AiSettings extends Equatable {
  const AiSettings({
    this.providerId = 'groq',
    this.baseUrl = 'https://api.groq.com/openai/v1',
    this.model = 'llama-3.3-70b-versatile',
    this.apiKey = '',
  });

  final String providerId;
  final String baseUrl;
  final String model;
  final String apiKey;

  bool get isConfigured =>
      apiKey.trim().isNotEmpty &&
      baseUrl.trim().isNotEmpty &&
      model.trim().isNotEmpty;

  AiSettings copyWith({
    String? providerId,
    String? baseUrl,
    String? model,
    String? apiKey,
  }) {
    return AiSettings(
      providerId: providerId ?? this.providerId,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  Map<String, dynamic> toJson() => {
        'providerId': providerId,
        'baseUrl': baseUrl,
        'model': model,
        'apiKey': apiKey,
      };

  factory AiSettings.fromJson(Map<String, dynamic> json) {
    return AiSettings(
      providerId: json['providerId'] as String? ?? 'groq',
      baseUrl: json['baseUrl'] as String? ??
          'https://api.groq.com/openai/v1',
      model: json['model'] as String? ?? 'llama-3.3-70b-versatile',
      apiKey: json['apiKey'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [providerId, baseUrl, model, apiKey];
}
