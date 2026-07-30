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
  String get confirmNo => 'Нет';

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
  String get retry => 'Повторить';

  @override
  String get splashAppName => 'Бхагавад Гита';

  @override
  String get splashAudioDownloadPrompt =>
      'Хотите ли вы скачать аудио сейчас? Это можно будет сделать позднее.';

  @override
  String get splashConnectionError =>
      'Соединение с сервером не может быть установлено. Пожалуйста, проверьте настройки интернет-соединения или повторите попытку чуть позже.';

  @override
  String get guideSkip => 'Пропустить';

  @override
  String get guideBack => 'Назад';

  @override
  String get guideNext => 'Вперед';

  @override
  String get guideTitle1 => 'Что делать?';

  @override
  String get guideText1 =>
      'Ответы на этот вопрос человечество искало еще задолго до Чернышевского. «Бхагавад-гита» — одно из древнейших духовных писаний на Земле — предлагает ответы на него.';

  @override
  String get guideTitle2 => 'Древнее знание для современных людей';

  @override
  String get guideText2 =>
      'Книга представляет собой живой диалог между Кришной и Арджуной. Перед величайшей битвой Кришна дает наставления своему другу, объясняя, что делать, чтобы успешно и счастливо жить в этом мире, а также раскрывает различные аспекты духовной жизни.';

  @override
  String get guideChecklist1 => 'Читайте так, как вам удобно';

  @override
  String get guideChecklist2 => 'Сравнивайте трактовки и переводы';

  @override
  String get guideChecklist3 => 'Изучайте комментарии';

  @override
  String get guideChecklist4 => 'Слушайте';

  @override
  String get guideChecklist5 => 'Записывайте заметки';

  @override
  String get contentsTitle => 'Бхагавад Гита';

  @override
  String get contentsQuoteTitle => 'Цитата дня';

  @override
  String chapterLabel(int number) {
    return 'Глава $number';
  }

  @override
  String shlokaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count шлок',
      many: '$count шлок',
      few: '$count шлоки',
      one: '$count шлока',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'Поиск';

  @override
  String get searchNotFound => 'Поиск не дал результатов';

  @override
  String get noteTitle => 'Заметка';

  @override
  String get save => 'Сохранить';

  @override
  String get languageName_en => 'English';

  @override
  String get languageName_ru => 'Русский';

  @override
  String get languageName_de => 'Deutsch';

  @override
  String get languageName_spa => 'Español';
}
