import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tidy/core/persistence/json_store.dart';
import 'package:tidy/domain/models/ai_settings.dart';

class AiSettingsRepository {
  AiSettingsRepository({JsonStore? store, FlutterSecureStorage? secureStorage})
      : _store = store ?? JsonStore(fileName: 'ai_settings.json'),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _apiKeyStorageKey = 'ai_api_key';

  final JsonStore _store;
  final FlutterSecureStorage _secureStorage;

  Future<AiSettings> load() async {
    final data = await _store.read();
    if (data == null) return const AiSettings();
    try {
      final legacyKey = data['apiKey'] as String? ?? '';
      if (legacyKey.isNotEmpty) {
        await _secureStorage.write(key: _apiKeyStorageKey, value: legacyKey);
        final sanitized = Map<String, dynamic>.from(data)..remove('apiKey');
        await _store.write(sanitized);
      }
      final apiKey =
          await _secureStorage.read(key: _apiKeyStorageKey) ?? '';
      return AiSettings.fromJson(data).copyWith(apiKey: apiKey);
    } catch (_) {
      return const AiSettings();
    }
  }

  Future<void> save(AiSettings settings) async {
    final json = settings.toJson()..remove('apiKey');
    await _store.write(json);
    if (settings.apiKey.trim().isEmpty) {
      await _secureStorage.delete(key: _apiKeyStorageKey);
    } else {
      await _secureStorage.write(
          key: _apiKeyStorageKey, value: settings.apiKey);
    }
  }
}
