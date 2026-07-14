import 'package:flutter/foundation.dart';

class ReaderSettings {
  const ReaderSettings({
    this.showSanskrit = true,
    this.showTranscription = true,
    this.showTranslation = true,
    this.showVocabulary = true,
    this.showCommentary = true,
    this.downloadSanskritAudio = false,
    this.downloadTranslationAudio = false,
    this.autoPlayNext = false,
    this.quoteOfTheDayEnabled = true,
    this.languageCode = 'en',
  });

  final bool showSanskrit;
  final bool showTranscription;
  final bool showTranslation;
  final bool showVocabulary;
  final bool showCommentary;

  final bool downloadSanskritAudio;
  final bool downloadTranslationAudio;
  final bool autoPlayNext;

  final bool quoteOfTheDayEnabled;
  final String languageCode;

  ReaderSettings copyWith({
    bool? showSanskrit,
    bool? showTranscription,
    bool? showTranslation,
    bool? showVocabulary,
    bool? showCommentary,
    bool? downloadSanskritAudio,
    bool? downloadTranslationAudio,
    bool? autoPlayNext,
    bool? quoteOfTheDayEnabled,
    String? languageCode,
  }) {
    return ReaderSettings(
      showSanskrit: showSanskrit ?? this.showSanskrit,
      showTranscription: showTranscription ?? this.showTranscription,
      showTranslation: showTranslation ?? this.showTranslation,
      showVocabulary: showVocabulary ?? this.showVocabulary,
      showCommentary: showCommentary ?? this.showCommentary,
      downloadSanskritAudio:
          downloadSanskritAudio ?? this.downloadSanskritAudio,
      downloadTranslationAudio:
          downloadTranslationAudio ?? this.downloadTranslationAudio,
      autoPlayNext: autoPlayNext ?? this.autoPlayNext,
      quoteOfTheDayEnabled: quoteOfTheDayEnabled ?? this.quoteOfTheDayEnabled,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class ReaderSettingsController extends ValueNotifier<ReaderSettings> {
  ReaderSettingsController() : super(const ReaderSettings());

  void update(ReaderSettings next) => value = next;
}

final ReaderSettingsController readerSettings = ReaderSettingsController();
