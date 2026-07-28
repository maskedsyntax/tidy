import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/data/ai_settings_repository.dart';
import 'package:tidy/domain/models/ai_settings.dart';

class AiSettingsController extends StateNotifier<AiSettings> {
  AiSettingsController(this._repo) : super(const AiSettings()) {
    _init();
  }

  final AiSettingsRepository _repo;
  bool loaded = false;

  Future<void> _init() async {
    state = await _repo.load();
    loaded = true;
  }

  Future<void> update(AiSettings settings) async {
    state = settings;
    await _repo.save(state);
  }

  Future<void> applyPreset(AiProviderPreset preset) async {
    if (preset.id == 'custom') {
      state = state.copyWith(providerId: 'custom');
    } else {
      state = state.copyWith(
        providerId: preset.id,
        baseUrl: preset.baseUrl,
        model: preset.defaultModel,
      );
    }
    await _repo.save(state);
  }
}

final aiSettingsRepositoryProvider =
    Provider((ref) => AiSettingsRepository());

final aiSettingsControllerProvider =
    StateNotifierProvider<AiSettingsController, AiSettings>((ref) {
  return AiSettingsController(ref.watch(aiSettingsRepositoryProvider));
});
