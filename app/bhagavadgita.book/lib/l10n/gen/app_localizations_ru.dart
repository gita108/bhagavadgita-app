// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSectionLanguages => 'ЯЗЫКИ';

  @override
  String get settingsSectionDisplay => 'ПОКАЗЫВАТЬ';

  @override
  String get settingsSectionAudio => 'АУДИО';

  @override
  String get settingsSectionInterpretations => 'ТРАКТОВКИ';

  @override
  String get settingsContentLanguagesTitle => 'Языки контента';

  @override
  String get settingsContentLanguagesChooseTitle => 'Выбор языка';

  @override
  String get settingsContentLanguagesAtLeastOne =>
      'Нужно оставить хотя бы один язык контента.';

  @override
  String get settingsAppLanguageTitle => 'Язык приложения';

  @override
  String get settingsAppLanguageChooseTitle => 'Язык приложения';

  @override
  String get settingsAppLanguageSystemDefault => 'Системный';

  @override
  String get settingsShowSanskrit => 'Санскрит';

  @override
  String get settingsShowTransliteration => 'Транскрипция';

  @override
  String get settingsShowTranslation => 'Перевод';

  @override
  String get settingsShowComment => 'Комментарии';

  @override
  String get settingsShowVocabulary => 'Пословный перевод';

  @override
  String get settingsAudioTranslation => 'Перевод (аудио)';

  @override
  String get settingsAudioSanskrit => 'Санскрит (аудио)';

  @override
  String get settingsAudioAutoPlay => 'Проигрывать автоматически';

  @override
  String get confirmDownloadTitle => 'Скачать';

  @override
  String get confirmDeleteTitle => 'Удалить';

  @override
  String get confirmCancel => 'Отмена';

  @override
  String get confirmOk => 'OK';

  @override
  String get confirmYes => 'Да';

  @override
  String get confirmDownloadAudioTranslation => 'Скачать аудио перевод?';

  @override
  String get confirmDownloadAudioSanskrit => 'Скачать аудио санскрит?';

  @override
  String get confirmDeleteAudioTranslation => 'Удалить аудио перевод?';

  @override
  String get confirmDeleteAudioSanskrit => 'Удалить аудио санскрит?';

  @override
  String get loadingEllipsis => 'Загрузка…';

  @override
  String get languageName_en => 'English';

  @override
  String get languageName_ru => 'Русский';

  @override
  String get languageName_de => 'Deutsch';

  @override
  String get languageName_spa => 'Español';
}
