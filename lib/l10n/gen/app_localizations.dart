import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionLanguages.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGES'**
  String get settingsSectionLanguages;

  /// No description provided for @settingsSectionDisplay.
  ///
  /// In en, this message translates to:
  /// **'DISPLAY'**
  String get settingsSectionDisplay;

  /// No description provided for @settingsSectionAudio.
  ///
  /// In en, this message translates to:
  /// **'AUDIO'**
  String get settingsSectionAudio;

  /// No description provided for @settingsSectionInterpretations.
  ///
  /// In en, this message translates to:
  /// **'INTERPRETATIONS'**
  String get settingsSectionInterpretations;

  /// No description provided for @settingsContentLanguagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Content languages'**
  String get settingsContentLanguagesTitle;

  /// No description provided for @settingsContentLanguagesChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose content languages'**
  String get settingsContentLanguagesChooseTitle;

  /// No description provided for @settingsContentLanguagesAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'You must keep at least one content language.'**
  String get settingsContentLanguagesAtLeastOne;

  /// No description provided for @settingsAppLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsAppLanguageTitle;

  /// No description provided for @settingsAppLanguageChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsAppLanguageChooseTitle;

  /// No description provided for @settingsAppLanguageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsAppLanguageSystemDefault;

  /// No description provided for @settingsShowSanskrit.
  ///
  /// In en, this message translates to:
  /// **'Show Sanskrit'**
  String get settingsShowSanskrit;

  /// No description provided for @settingsShowTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Show transliteration'**
  String get settingsShowTransliteration;

  /// No description provided for @settingsShowTranslation.
  ///
  /// In en, this message translates to:
  /// **'Show translation'**
  String get settingsShowTranslation;

  /// No description provided for @settingsShowComment.
  ///
  /// In en, this message translates to:
  /// **'Show comments'**
  String get settingsShowComment;

  /// No description provided for @settingsShowVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Show vocabulary'**
  String get settingsShowVocabulary;

  /// No description provided for @settingsAudioTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation audio'**
  String get settingsAudioTranslation;

  /// No description provided for @settingsAudioSanskrit.
  ///
  /// In en, this message translates to:
  /// **'Sanskrit audio'**
  String get settingsAudioSanskrit;

  /// No description provided for @settingsAudioAutoPlay.
  ///
  /// In en, this message translates to:
  /// **'Auto-play next'**
  String get settingsAudioAutoPlay;

  /// No description provided for @confirmDownloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get confirmDownloadTitle;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get confirmCancel;

  /// No description provided for @confirmOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get confirmOk;

  /// No description provided for @confirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get confirmYes;

  /// No description provided for @confirmNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get confirmNo;

  /// No description provided for @confirmDownloadAudioTranslation.
  ///
  /// In en, this message translates to:
  /// **'Would you like to download audio translation?'**
  String get confirmDownloadAudioTranslation;

  /// No description provided for @confirmDownloadAudioSanskrit.
  ///
  /// In en, this message translates to:
  /// **'Would you like to download audio sanskrit?'**
  String get confirmDownloadAudioSanskrit;

  /// No description provided for @confirmDeleteAudioTranslation.
  ///
  /// In en, this message translates to:
  /// **'Would you like to delete audio translation?'**
  String get confirmDeleteAudioTranslation;

  /// No description provided for @confirmDeleteAudioSanskrit.
  ///
  /// In en, this message translates to:
  /// **'Would you like to delete audio sanskrit?'**
  String get confirmDeleteAudioSanskrit;

  /// No description provided for @loadingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingEllipsis;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @splashAppName.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita'**
  String get splashAppName;

  /// No description provided for @splashAudioDownloadPrompt.
  ///
  /// In en, this message translates to:
  /// **'Would you like to download audio right now? You can do it later.'**
  String get splashAudioDownloadPrompt;

  /// No description provided for @splashConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection to the server can not establish. Please, check the settings of Internet connection or try again later.'**
  String get splashConnectionError;

  /// No description provided for @guideSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get guideSkip;

  /// No description provided for @guideBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get guideBack;

  /// No description provided for @guideNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get guideNext;

  /// No description provided for @guideTitle1.
  ///
  /// In en, this message translates to:
  /// **'What to do?'**
  String get guideTitle1;

  /// No description provided for @guideText1.
  ///
  /// In en, this message translates to:
  /// **'Answers to this question mankind sought long before Chernyshevsky. “Bhagavad-gita” - one of the oldest spiritual scriptures on Earth - offers answers to it.'**
  String get guideText1;

  /// No description provided for @guideTitle2.
  ///
  /// In en, this message translates to:
  /// **'Ancient knowledge for modern people'**
  String get guideTitle2;

  /// No description provided for @guideText2.
  ///
  /// In en, this message translates to:
  /// **'The book is a living dialogue between Krishna and Arjuna. Before the greatest battle, Krsna instructs his friend, explaining what to do to live successfully and happily in this world, and also reveals various aspects of spiritual life.'**
  String get guideText2;

  /// No description provided for @guideChecklist1.
  ///
  /// In en, this message translates to:
  /// **'Read as it’s convenient for you'**
  String get guideChecklist1;

  /// No description provided for @guideChecklist2.
  ///
  /// In en, this message translates to:
  /// **'Compare interpretations and translations'**
  String get guideChecklist2;

  /// No description provided for @guideChecklist3.
  ///
  /// In en, this message translates to:
  /// **'Study comments'**
  String get guideChecklist3;

  /// No description provided for @guideChecklist4.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get guideChecklist4;

  /// No description provided for @guideChecklist5.
  ///
  /// In en, this message translates to:
  /// **'Make notes'**
  String get guideChecklist5;

  /// No description provided for @contentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita'**
  String get contentsTitle;

  /// No description provided for @contentsQuoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Quote of the Day'**
  String get contentsQuoteTitle;

  /// No description provided for @chapterLabel.
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}'**
  String chapterLabel(int number);

  /// No description provided for @shlokaCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} shloka} other{{count} shlokas}}'**
  String shlokaCount(int count);

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchPlaceholder;

  /// No description provided for @searchNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get searchNotFound;

  /// No description provided for @noteTitle.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @languageName_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName_en;

  /// No description provided for @languageName_ru.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageName_ru;

  /// No description provided for @languageName_de.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageName_de;

  /// No description provided for @languageName_spa.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageName_spa;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
