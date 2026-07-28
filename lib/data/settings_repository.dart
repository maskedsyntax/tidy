import 'package:tidy/core/persistence/json_store.dart';
import 'package:tidy/domain/models/app_settings.dart';

class SettingsRepository {
  SettingsRepository({JsonStore? store})
      : _store = store ?? JsonStore(fileName: 'settings.json');

  final JsonStore _store;

  Future<AppSettings> load() async {
    final data = await _store.read();
    if (data == null) return const AppSettings();
    try {
      return AppSettings.fromJson(data);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    await _store.write(settings.toJson());
  }
}
