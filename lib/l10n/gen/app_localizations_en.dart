// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionLanguages => 'LANGUAGES';

  @override
  String get settingsSectionDisplay => 'DISPLAY';

  @override
  String get settingsSectionAudio => 'AUDIO';

  @override
  String get settingsSectionInterpretations => 'INTERPRETATIONS';

  @override
  String get settingsContentLanguagesTitle => 'Content languages';

  @override
  String get settingsContentLanguagesChooseTitle => 'Choose content languages';

  @override
  String get settingsContentLanguagesAtLeastOne =>
      'You must keep at least one content language.';

  @override
  String get settingsAppLanguageTitle => 'App language';

  @override
  String get settingsAppLanguageChooseTitle => 'App language';

  @override
  String get settingsAppLanguageSystemDefault => 'System default';

  @override
  String get settingsShowSanskrit => 'Show Sanskrit';

  @override
  String get settingsShowTransliteration => 'Show transliteration';

  @override
  String get settingsShowTranslation => 'Show translation';

  @override
  String get settingsShowComment => 'Show comments';

  @override
  String get settingsShowVocabulary => 'Show vocabulary';

  @override
  String get settingsAudioTranslation => 'Translation audio';

  @override
  String get settingsAudioSanskrit => 'Sanskrit audio';

  @override
  String get settingsAudioAutoPlay => 'Auto-play next';

  @override
  String get confirmDownloadTitle => 'Download';

  @override
  String get confirmDeleteTitle => 'Delete';

  @override
  String get confirmCancel => 'Cancel';

  @override
  String get confirmOk => 'OK';

  @override
  String get confirmYes => 'Yes';

  @override
  String get confirmDownloadAudioTranslation =>
      'Would you like to download audio translation?';

  @override
  String get confirmDownloadAudioSanskrit =>
      'Would you like to download audio sanskrit?';

  @override
  String get confirmDeleteAudioTranslation =>
      'Would you like to delete audio translation?';

  @override
  String get confirmDeleteAudioSanskrit =>
      'Would you like to delete audio sanskrit?';

  @override
  String get loadingEllipsis => 'Loading…';

  @override
  String get languageName_en => 'English';

  @override
  String get languageName_ru => 'Русский';

  @override
  String get languageName_de => 'Deutsch';

  @override
  String get languageName_spa => 'Español';
}
