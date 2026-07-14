import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderSettings {
  const ReaderSettings({
    required this.showSanskrit,
    required this.showTransliteration,
    required this.showTranslation,
    required this.showComment,
    required this.showVocabulary,
  });

  const ReaderSettings.defaults()
    : showSanskrit = true,
      showTransliteration = true,
      showTranslation = true,
      showComment = true,
      showVocabulary = true;

  final bool showSanskrit;
  final bool showTransliteration;
  final bool showTranslation;
  final bool showComment;
  final bool showVocabulary;

  ReaderSettings copyWith({
    bool? showSanskrit,
    bool? showTransliteration,
    bool? showTranslation,
    bool? showComment,
    bool? showVocabulary,
  }) {
    return ReaderSettings(
      showSanskrit: showSanskrit ?? this.showSanskrit,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showTranslation: showTranslation ?? this.showTranslation,
      showComment: showComment ?? this.showComment,
      showVocabulary: showVocabulary ?? this.showVocabulary,
    );
  }

  Map<String, bool> toMap() {
    return {
      'showSanskrit': showSanskrit,
      'showTransliteration': showTransliteration,
      'showTranslation': showTranslation,
      'showComment': showComment,
      'showVocabulary': showVocabulary,
    };
  }

  static ReaderSettings fromMap(Map<String, bool> map) {
    const defaults = ReaderSettings.defaults();
    return ReaderSettings(
      showSanskrit: map['showSanskrit'] ?? defaults.showSanskrit,
      showTransliteration:
          map['showTransliteration'] ?? defaults.showTransliteration,
      showTranslation: map['showTranslation'] ?? defaults.showTranslation,
      showComment: map['showComment'] ?? defaults.showComment,
      showVocabulary: map['showVocabulary'] ?? defaults.showVocabulary,
    );
  }
}

class ReaderSettingsController extends ValueNotifier<ReaderSettings> {
  ReaderSettingsController() : super(const ReaderSettings.defaults()) {
    _load();
  }

  static const _prefix = 'reader_settings.';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = <String, bool>{};
    for (final key in const [
      'showSanskrit',
      'showTransliteration',
      'showTranslation',
      'showComment',
      'showVocabulary',
    ]) {
      final value = prefs.getBool('$_prefix$key');
      if (value != null) stored[key] = value;
    }
    if (stored.isNotEmpty) {
      value = ReaderSettings.fromMap(stored);
    }
  }

  Future<void> update(ReaderSettings next) async {
    value = next;
    final prefs = await SharedPreferences.getInstance();
    final map = next.toMap();
    for (final entry in map.entries) {
      await prefs.setBool('$_prefix${entry.key}', entry.value);
    }
  }
}

final ReaderSettingsController readerSettingsController =
    ReaderSettingsController();
