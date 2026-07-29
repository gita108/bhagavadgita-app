import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioSettings {
  const AudioSettings({
    required this.useTranslationAudio,
    required this.useSanskritAudio,
    required this.autoPlayNext,
  });

  const AudioSettings.defaults()
    : useTranslationAudio = false,
      useSanskritAudio = false,
      autoPlayNext = false;

  final bool useTranslationAudio;
  final bool useSanskritAudio;
  final bool autoPlayNext;

  AudioSettings copyWith({
    bool? useTranslationAudio,
    bool? useSanskritAudio,
    bool? autoPlayNext,
  }) {
    return AudioSettings(
      useTranslationAudio: useTranslationAudio ?? this.useTranslationAudio,
      useSanskritAudio: useSanskritAudio ?? this.useSanskritAudio,
      autoPlayNext: autoPlayNext ?? this.autoPlayNext,
    );
  }
}

class AudioSettingsController extends ValueNotifier<AudioSettings> {
  AudioSettingsController() : super(const AudioSettings.defaults()) {
    _load();
  }

  static const _prefix = 'audio.';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = <String, bool>{};
    for (final key in const [
      'useTranslationAudio',
      'useSanskritAudio',
      'autoPlayNext',
    ]) {
      final value = prefs.getBool('$_prefix$key');
      if (value != null) stored[key] = value;
    }
    if (stored.isEmpty) return;

    final defaults = value;
    value = defaults.copyWith(
      useTranslationAudio: stored['useTranslationAudio'],
      useSanskritAudio: stored['useSanskritAudio'],
      autoPlayNext: stored['autoPlayNext'],
    );
  }

  Future<void> update(AudioSettings next) async {
    value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      '${_prefix}useTranslationAudio',
      next.useTranslationAudio,
    );
    await prefs.setBool('${_prefix}useSanskritAudio', next.useSanskritAudio);
    await prefs.setBool('${_prefix}autoPlayNext', next.autoPlayNext);
  }
}

final AudioSettingsController audioSettingsController = AudioSettingsController();

