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
