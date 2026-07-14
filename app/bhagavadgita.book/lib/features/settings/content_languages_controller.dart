import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContentLanguageOption {
  const ContentLanguageOption({
    required this.code,
    required this.nameKey,
  });

  final String code;
  final String nameKey; // l10n key lookup handled in UI
}

class ContentLanguagesSettings {
  const ContentLanguagesSettings({
    required this.selectedCodes,
  });

  final Set<String> selectedCodes;

  ContentLanguagesSettings copyWith({
    Set<String>? selectedCodes,
  }) {
    return ContentLanguagesSettings(
      selectedCodes: selectedCodes ?? this.selectedCodes,
    );
  }
}

class ContentLanguagesController extends ValueNotifier<ContentLanguagesSettings> {
  ContentLanguagesController()
    : super(
        ContentLanguagesSettings(
          selectedCodes: {..._defaults},
        ),
      ) {
    _load();
  }

  static const _keySelected = 'content_languages.selectedCodes';

  static const available = <ContentLanguageOption>[
    ContentLanguageOption(code: 'en', nameKey: 'languageName_en'),
    ContentLanguageOption(code: 'ru', nameKey: 'languageName_ru'),
    ContentLanguageOption(code: 'de', nameKey: 'languageName_de'),
    ContentLanguageOption(code: 'spa', nameKey: 'languageName_spa'),
  ];

  static const _defaults = <String>{'en', 'ru'};

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_keySelected);
    if (stored == null || stored.isEmpty) return;

    final normalized =
        stored.where((c) => available.any((o) => o.code == c)).toSet();
    if (normalized.isEmpty) return;

    value = value.copyWith(selectedCodes: normalized);
  }

  Future<bool> toggle(String code) async {
    final next = {...value.selectedCodes};
    if (next.contains(code)) {
      if (next.length == 1) return false;
      next.remove(code);
    } else {
      next.add(code);
    }
    value = value.copyWith(selectedCodes: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keySelected, next.toList()..sort());
    return true;
  }
}

final ContentLanguagesController contentLanguagesController =
    ContentLanguagesController();

