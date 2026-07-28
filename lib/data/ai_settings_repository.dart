import 'package:tidy/core/persistence/json_store.dart';
import 'package:tidy/domain/models/ai_settings.dart';

class AiSettingsRepository {
  AiSettingsRepository({JsonStore? store})
      : _store = store ?? JsonStore(fileName: 'ai_settings.json');

  final JsonStore _store;

  Future<AiSettings> load() async {
    final data = await _store.read();
    if (data == null) return const AiSettings();
    try {
      return AiSettings.fromJson(data);
    } catch (_) {
      return const AiSettings();
    }
  }

  Future<void> save(AiSettings settings) async {
    await _store.write(settings.toJson());
  }
}
