import 'package:flutter/material.dart';

import '../../app/audio/audio_download_controller.dart';
import '../../app/audio/audio_track.dart';
import '../../data/local/app_database.dart';
import '../../data/local/book_repository.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../../l10n/l10n.dart';
import '../shared/widgets/section_header.dart';
import 'app_language_screen.dart';
import 'audio_settings_controller.dart';
import 'content_languages_controller.dart';
import 'content_languages_screen.dart';
import 'reader_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.db});

  final AppDatabase db;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final BookRepository _books = BookRepository(widget.db);
  final Set<int> _busyBookIds = {};

  Future<void> _download(int bookId) async {
    setState(() => _busyBookIds.add(bookId));
    try {
      await _books.downloadBook(bookId);
    } finally {
      if (mounted) setState(() => _busyBookIds.remove(bookId));
    }
  }

  Future<void> _delete(int bookId) async {
    setState(() => _busyBookIds.add(bookId));
    try {
      await _books.deleteBook(bookId);
    } finally {
      if (mounted) setState(() => _busyBookIds.remove(bookId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          readerSettingsController,
          contentLanguagesController,
          audioSettingsController,
          audioDownloadController,
        ]),
        builder: (context, _) {
          final reader = readerSettingsController.value;
          final contentLangs = contentLanguagesController.value;
          final audio = audioSettingsController.value;
          final dl = audioDownloadController.value;

          return ListView(
            children: [
              const SizedBox(height: 6),
              SectionHeader(l10n.settingsSectionLanguages, settingsStyle: true),
              ListTile(
                title: Text(l10n.settingsContentLanguagesTitle),
                subtitle: Text(_contentLanguagesSummary(context, contentLangs)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContentLanguagesScreen(),
                  ),
                ),
              ),
              ListTile(
                title: Text(l10n.settingsAppLanguageTitle),
                subtitle: Text(_appLanguageSummary(context)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppLanguageScreen(),
                  ),
                ),
              ),

              SectionHeader(l10n.settingsSectionDisplay, settingsStyle: true),
              SwitchListTile(
                title: Text(l10n.settingsShowSanskrit, style: AppText.body()),
                value: reader.showSanskrit,
                activeTrackColor: AppColors.red1,
                onChanged: (v) => readerSettingsController.update(
                  reader.copyWith(showSanskrit: v),
                ),
              ),
              SwitchListTile(
                title: Text(
                  l10n.settingsShowTransliteration,
                  style: AppText.body(),
                ),
                value: reader.showTransliteration,
                activeTrackColor: AppColors.red1,
                onChanged: (v) => readerSettingsController.update(
                  reader.copyWith(showTransliteration: v),
                ),
              ),
              SwitchListTile(
                title: Text(
                  l10n.settingsShowTranslation,
                  style: AppText.body(),
                ),
                value: reader.showTranslation,
                activeTrackColor: AppColors.red1,
                onChanged: (v) => readerSettingsController.update(
                  reader.copyWith(showTranslation: v),
                ),
              ),
              SwitchListTile(
                title: Text(l10n.settingsShowComment, style: AppText.body()),
                value: reader.showComment,
                activeTrackColor: AppColors.red1,
                onChanged: (v) => readerSettingsController.update(
                  reader.copyWith(showComment: v),
                ),
              ),
              SwitchListTile(
                title: Text(l10n.settingsShowVocabulary, style: AppText.body()),
                value: reader.showVocabulary,
                activeTrackColor: AppColors.red1,
                onChanged: (v) => readerSettingsController.update(
                  reader.copyWith(showVocabulary: v),
                ),
              ),

              SectionHeader(l10n.settingsSectionAudio, settingsStyle: true),
              SwitchListTile(
                title: Text(
                  l10n.settingsAudioTranslation,
                  style: AppText.body(),
                ),
                value: audio.useTranslationAudio,
                activeTrackColor: AppColors.red1,
                onChanged: (v) async {
                  final ok = await _confirmAudioToggle(
                    context,
                    enable: v,
                    isSanskrit: false,
                  );
                  if (!ok) return;
                  await audioSettingsController.update(
                    audio.copyWith(useTranslationAudio: v),
                  );
                },
              ),
              SwitchListTile(
                title: Text(l10n.settingsAudioSanskrit, style: AppText.body()),
                value: audio.useSanskritAudio,
                activeTrackColor: AppColors.red1,
                onChanged: (v) async {
                  final ok = await _confirmAudioToggle(
                    context,
                    enable: v,
                    isSanskrit: true,
                  );
                  if (!ok) return;
                  await audioSettingsController.update(
                    audio.copyWith(useSanskritAudio: v),
                  );
                },
              ),
              SwitchListTile(
                title: Text(l10n.settingsAudioAutoPlay, style: AppText.body()),
                value: audio.autoPlayNext,
                activeTrackColor: AppColors.red1,
                onChanged: (v) => audioSettingsController.update(
                  audio.copyWith(autoPlayNext: v),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (dl.errorMessage != null)
                      Text(
                        dl.errorMessage!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.red),
                      ),
                    const SizedBox(height: 6),
                    FilledButton.icon(
                      onPressed: audioDownloadController.isBusy
                          ? null
                          : () async {
                              await audioDownloadController.downloadAllChapters(
                                AudioTrack.translation,
                              );
                            },
                      icon:
                          audioDownloadController.isBusy &&
                              dl.track == AudioTrack.translation
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: Text(
                        audioDownloadController.isBusy &&
                                dl.track == AudioTrack.translation
                            ? 'Downloading RU…'
                            : 'Download RU (AudioVeda)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: audioDownloadController.isBusy
                          ? null
                          : () async {
                              await audioDownloadController.downloadAllChapters(
                                AudioTrack.sanskrit,
                              );
                            },
                      icon:
                          audioDownloadController.isBusy &&
                              dl.track == AudioTrack.sanskrit
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: Text(
                        audioDownloadController.isBusy &&
                                dl.track == AudioTrack.sanskrit
                            ? 'Downloading Sanskrit…'
                            : 'Download Sanskrit (AudioVeda)',
                      ),
                    ),
                    if (dl.isDownloading) ...[
                      const SizedBox(height: 10),
                      LinearProgressIndicator(value: dl.progress),
                      if (dl.currentLabel != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          dl.currentLabel!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.gray2),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              SectionHeader(
                l10n.settingsSectionInterpretations,
                settingsStyle: true,
              ),
              StreamBuilder<List<InterpretationBook>>(
                stream: _books.watchCatalog(
                  languageCodes: contentLangs.selectedCodes,
                ),
                builder: (context, snap) {
                  final books = snap.data ?? const <InterpretationBook>[];
                  if (books.isEmpty) {
                    return ListTile(title: Text(l10n.loadingEllipsis));
                  }
                  return Column(
                    children: [
                      for (final book in books)
                        ListTile(
                          title: Text(book.name, style: AppText.body()),
                          trailing: _busyBookIds.contains(book.id)
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : book.isDefault
                              ? const Icon(Icons.check, color: AppColors.red1)
                              : book.isDownloaded
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: AppColors.red1,
                                  ),
                                  onPressed: () => _delete(book.id),
                                )
                              : TextButton(
                                  onPressed: () => _download(book.id),
                                  child: Text(l10n.confirmDownloadTitle),
                                ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  String _contentLanguagesSummary(
    BuildContext context,
    ContentLanguagesSettings settings,
  ) {
    final l10n = context.l10n;
    final labels =
        settings.selectedCodes
            .map(
              (code) => switch (code) {
                'en' => l10n.languageName_en,
                'ru' => l10n.languageName_ru,
                'de' => l10n.languageName_de,
                'spa' => l10n.languageName_spa,
                _ => code,
              },
            )
            .toList()
          ..sort();
    return labels.join(', ');
  }

  String _appLanguageSummary(BuildContext context) {
    final l10n = context.l10n;
    final code = Localizations.localeOf(context).languageCode;
    return switch (code) {
      'en' => l10n.languageName_en,
      'ru' => l10n.languageName_ru,
      'de' => l10n.languageName_de,
      'spa' => l10n.languageName_spa,
      _ => l10n.settingsAppLanguageSystemDefault,
    };
  }

  Future<bool> _confirmAudioToggle(
    BuildContext context, {
    required bool enable,
    required bool isSanskrit,
  }) async {
    final l10n = context.l10n;
    if (enable) {
      return (await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.confirmDownloadTitle),
              content: Text(
                isSanskrit
                    ? l10n.confirmDownloadAudioSanskrit
                    : l10n.confirmDownloadAudioTranslation,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.confirmCancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.confirmOk),
                ),
              ],
            ),
          )) ??
          false;
    }

    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.confirmDeleteTitle),
            content: Text(
              isSanskrit
                  ? l10n.confirmDeleteAudioSanskrit
                  : l10n.confirmDeleteAudioTranslation,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.confirmCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.confirmYes),
              ),
            ],
          ),
        )) ??
        false;
  }
}
