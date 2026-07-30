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
  String get confirmNo => 'No';

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
  String get retry => 'Retry';

  @override
  String get splashAppName => 'Bhagavad Gita';

  @override
  String get splashAudioDownloadPrompt =>
      'Would you like to download audio right now? You can do it later.';

  @override
  String get splashConnectionError =>
      'Connection to the server can not establish. Please, check the settings of Internet connection or try again later.';

  @override
  String get guideSkip => 'Skip';

  @override
  String get guideBack => 'Back';

  @override
  String get guideNext => 'Next';

  @override
  String get guideTitle1 => 'What to do?';

  @override
  String get guideText1 =>
      'Answers to this question mankind sought long before Chernyshevsky. “Bhagavad-gita” - one of the oldest spiritual scriptures on Earth - offers answers to it.';

  @override
  String get guideTitle2 => 'Ancient knowledge for modern people';

  @override
  String get guideText2 =>
      'The book is a living dialogue between Krishna and Arjuna. Before the greatest battle, Krsna instructs his friend, explaining what to do to live successfully and happily in this world, and also reveals various aspects of spiritual life.';

  @override
  String get guideChecklist1 => 'Read as it’s convenient for you';

  @override
  String get guideChecklist2 => 'Compare interpretations and translations';

  @override
  String get guideChecklist3 => 'Study comments';

  @override
  String get guideChecklist4 => 'Listen';

  @override
  String get guideChecklist5 => 'Make notes';

  @override
  String get contentsTitle => 'Bhagavad Gita';

  @override
  String get contentsQuoteTitle => 'Quote of the Day';

  @override
  String chapterLabel(int number) {
    return 'Chapter $number';
  }

  @override
  String shlokaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shlokas',
      one: '$count shloka',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'Search';

  @override
  String get searchNotFound => 'Not found';

  @override
  String get noteTitle => 'Note';

  @override
  String get save => 'Save';

  @override
  String get readerToContents => 'To contents';

  @override
  String get readerToBookmarks => 'To bookmarks';

  @override
  String get readerMinimize => 'Minimize';

  @override
  String readerMoreComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more comments',
      one: '$count more comment',
    );
    return '$_temp0';
  }

  @override
  String get bookmarksTitle => 'Bookmarks';

  @override
  String get languageName_en => 'English';

  @override
  String get languageName_ru => 'Русский';

  @override
  String get languageName_de => 'Deutsch';

  @override
  String get languageName_spa => 'Español';
}
