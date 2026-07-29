import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_versegrid/flutter_versegrid.dart';

import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../../app/audio/audio_controller_scope.dart';
import '../../app/audio/audio_state.dart';
import '../../app/audio/audio_storage.dart';
import '../../app/audio/audio_track.dart';
import '../../data/local/app_database.dart';
import '../../data/local/user_data_repository.dart';
import '../settings/audio_settings_controller.dart';
import '../settings/reader_settings.dart';
import '../shared/widgets/audio_player_bar.dart';
import '../shared/widgets/author_badge.dart';
import '../shared/widgets/section_header.dart';
import 'widgets/mini_player_bar.dart';
import 'widgets/variant_pill.dart';
import '../../ui/widgets/share_button.dart';

class SlokaScreen extends StatefulWidget {
  const SlokaScreen({
    super.key,
    required this.db,
    required this.slokaId,
    this.chapterId,
    this.position,
    this.embedded = false,
    this.isCompact = false,
  });

  final AppDatabase db;
  final int slokaId;
  final int? chapterId;
  final int? position;
  final bool embedded;
  final bool isCompact;

  @override
  State<SlokaScreen> createState() => _SlokaScreenState();
}

class _SlokaScreenState extends State<SlokaScreen> {
  late final UserDataRepository _userData;
  late final TextEditingController _noteController;
  int? _boundSlokaId;
  bool _wiredCompletion = false;

  int _translationVariant = 0;
  int _commentaryVariant = 0;

  static const _translationVariants = ['Ru'];
  static const _commentaryVariants = ['BG'];

  @override
  void initState() {
    super.initState();
    _userData = UserDataRepository(widget.db);
    _noteController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wiredCompletion) return;
    _wiredCompletion = true;
    AudioControllerScope.of(context).onCompleted = _handleAudioCompleted;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  static const _legacyHost = 'http://app.bhagavadgitaapp.online';

  Uri? _resolveAudioUri(String? raw) {
    final s = (raw ?? '').trim();
    if (s.isEmpty) return null;
    final parsed = Uri.tryParse(s);
    if (parsed == null) return null;
    if (parsed.hasScheme) return parsed;
    return Uri.parse('$_legacyHost$s');
  }

  void _bindAudioIfNeeded(Sloka sloka) {
    if (_boundSlokaId == sloka.id) return;
    _boundSlokaId = sloka.id;

    final audio = AudioControllerScope.of(context);
    final sanskritUri = _resolveAudioUri(sloka.audioSanskrit);
    final translationUri = _resolveAudioUri(sloka.audio);

    () async {
      final audioSettings = audioSettingsController.value;
      final chapterId = widget.chapterId;

      final sanskrit = await _resolveBestSource(
        isEnabled: audioSettings.useSanskritAudio,
        trackLabel: 'Sanskrit',
        chapterId: chapterId,
        slokaNetworkUri: sanskritUri,
        chapter1AssetPath: 'assets/audio/sanskrit/chapter_1_sanskrit.mp3',
        track: AudioTrack.sanskrit,
      );
      final translation = await _resolveBestSource(
        isEnabled: audioSettings.useTranslationAudio,
        trackLabel: 'Translation',
        chapterId: chapterId,
        slokaNetworkUri: translationUri,
        chapter1AssetPath: 'assets/audio/ru/chapter_1_ru.mp3',
        track: AudioTrack.translation,
      );

      if (!mounted) return;
      await audio.setSources(sanskrit: sanskrit, translation: translation);
    }();
  }

  Future<AudioSourceRef> _resolveBestSource({
    required bool isEnabled,
    required String trackLabel,
    required int? chapterId,
    required Uri? slokaNetworkUri,
    required String chapter1AssetPath,
    required AudioTrack track,
  }) async {
    if (!isEnabled) return const AudioSourceRef.none();

    if (chapterId != null) {
      final local = await audioStorage.chapterLocalUriIfExists(track, chapterId);
      if (local != null) return AudioSourceRef.file(local, label: trackLabel);
    }

    if (slokaNetworkUri != null) {
      return AudioSourceRef.network(slokaNetworkUri, label: trackLabel);
    }

    if (chapterId == 1) {
      return AudioSourceRef.asset(chapter1AssetPath, label: trackLabel);
    }

    return const AudioSourceRef.none();
  }

  Future<void> _handleAudioCompleted() async {
    if (!audioSettingsController.value.autoPlayNext) return;
    final chapterId = widget.chapterId;
    final position = widget.position;
    if (chapterId == null || position == null) return;

    AudioControllerScope.of(context).requestPlayOnNextSourceBind();

    final next = await (widget.db.select(widget.db.slokas)
          ..where(
            (t) =>
                t.chapterId.equals(chapterId) &
                t.position.isBiggerThanValue(position),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.position)])
          ..limit(1))
        .getSingleOrNull();

    if (!mounted || next == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SlokaScreen(
          db: widget.db,
          slokaId: next.id,
          chapterId: chapterId,
          position: next.position,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slokaQuery = (widget.db.select(
      widget.db.slokas,
    )..where((t) => t.id.equals(widget.slokaId)))..limit(1);
    final vocabQuery =
        (widget.db.select(widget.db.vocabularies)
            ..where((t) => t.slokaId.equals(widget.slokaId)))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]);

    final body = StreamBuilder<Sloka?>(
      stream: slokaQuery.watchSingleOrNull(),
      builder: (context, snap) {
          final sloka = snap.data;
          if (snap.connectionState == ConnectionState.waiting &&
              sloka == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (sloka == null) {
            return const Center(child: Text('Sloka not found.'));
          }

          _bindAudioIfNeeded(sloka);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.chapterId != null && widget.position != null) ...[
                _SlokaNavigator(
                  db: widget.db,
                  chapterId: widget.chapterId!,
                  position: widget.position!,
                ),
                const SizedBox(height: 12),
              ],
              Center(
                child: Text(
                  sloka.position.toString(),
                  style: AppText.caption(),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                sloka.name,
                textAlign: TextAlign.center,
                style: AppText.heading(),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<ReaderSettings>(
                valueListenable: readerSettingsController,
                builder: (context, settings, _) {
                  final divider = const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (settings.showSanskrit &&
                          (sloka.slokaText ?? '').isNotEmpty) ...[
                        const SectionHeader('Sanskrit'),
                        VersePassage(
                          layout: VersePassageLayout.columnCenter,
                          primary: sloka.slokaText!,
                          primaryStyle: AppText.sanskrit(),
                          primaryTextAlign: TextAlign.center,
                        ),
                        divider,
                      ],
                      if (settings.showTransliteration &&
                          (sloka.transcription ?? '').isNotEmpty) ...[
                        const SectionHeader('Transcription'),
                        VersePassage(
                          layout: VersePassageLayout.columnStretch,
                          primary: sloka.transcription!,
                          primaryStyle: AppText.bodyItalic(),
                          primaryTextAlign: TextAlign.start,
                        ),
                        divider,
                      ],
                      if (settings.showTranslation &&
                          (sloka.translation ?? '').isNotEmpty) ...[
                        const SectionHeader('Translation'),
                        VariantPillRow(
                          variants: _translationVariants,
                          selectedIndex: _translationVariant,
                          onSelect: (i) => setState(() => _translationVariant = i),
                        ),
                        const SizedBox(height: 8),
                        VersePassage(
                          layout: VersePassageLayout.columnStretch,
                          primary: sloka.translation!,
                          primaryStyle: AppText.body(),
                          primaryTextAlign: TextAlign.start,
                        ),
                        divider,
                      ],
                      if (settings.showComment &&
                          (sloka.comment ?? '').isNotEmpty) ...[
                        const SectionHeader('Commentary'),
                        VariantPillRow(
                          variants: _commentaryVariants,
                          selectedIndex: _commentaryVariant,
                          onSelect: (i) => setState(() => _commentaryVariant = i),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AuthorBadge(
                              initials: 'BG',
                              name: 'Bhagavad Gita',
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: VersePassage(
                                layout: VersePassageLayout.columnStretch,
                                primary: sloka.comment!,
                                primaryStyle: AppText.body(),
                                primaryTextAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                        divider,
                      ],
                      if (settings.showVocabulary) ...[
                        const SectionHeader('Vocabulary'),
                        StreamBuilder<List<Vocabulary>>(
                          stream: vocabQuery.watch(),
                          builder: (context, vocabSnap) {
                            final items = vocabSnap.data ?? const [];
                            if (items.isEmpty) {
                              return Text(
                                'No vocabulary yet.',
                                style: AppText.caption(),
                              );
                            }
                            return Column(
                              children: [
                                for (final v in items)
                                  ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      v.tokenText,
                                      style: AppText.body().copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      v.translation,
                                      style: AppText.body(),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              const SectionHeader('Note'),
              const SizedBox(height: 8),
              StreamBuilder<String?>(
                stream: _userData.watchNote(widget.slokaId),
                builder: (context, noteSnap) {
                  final note = noteSnap.data ?? '';
                  if (_noteController.text != note) {
                    _noteController.text = note;
                    _noteController.selection = TextSelection.collapsed(
                      offset: _noteController.text.length,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _noteController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Write your note…',
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: () => _userData.saveNote(
                          widget.slokaId,
                          _noteController.text,
                        ),
                        child: const Text('Save note'),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
      },
    );

    if (widget.embedded) return body;

    final content = widget.isCompact
        ? Stack(
            children: [
              body,
              Positioned(
                top: MediaQuery.of(context).size.height * 0.45,
                left: 12,
                child: _RoundNavButton(
                  icon: Icons.chevron_left,
                  onPressed: () {},
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.45,
                right: 12,
                child: _RoundNavButton(
                  icon: Icons.chevron_right,
                  onPressed: () {},
                ),
              ),
            ],
          )
        : body;

    return Scaffold(
      appBar: widget.isCompact
          ? AppBar(
              title: Text('К оглавлению', style: AppText.navTitle()),
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.gray1,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.gray1),
              actions: [
                IconButton(
                  icon: const Icon(Icons.mode_comment_outlined),
                  onPressed: () {},
                ),
                ShareButton(chapter: widget.chapterId, verse: widget.slokaId),
                StreamBuilder<bool>(
                  stream: _userData.watchBookmark(widget.slokaId),
                  builder: (context, snap) {
                    final isBookmarked = snap.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? AppColors.red1 : AppColors.gray1,
                      ),
                      onPressed: () =>
                          _userData.setBookmark(widget.slokaId, !isBookmarked),
                    );
                  },
                ),
              ],
            )
          : AppBar(
              title: Text('Sloka', style: AppText.navTitle()),
              backgroundColor: AppColors.red1,
              foregroundColor: AppColors.white,
              actions: [
                ShareButton(chapter: widget.chapterId, verse: widget.slokaId),
                StreamBuilder<bool>(
                  stream: _userData.watchBookmark(widget.slokaId),
                  builder: (context, snap) {
                    final isBookmarked = snap.data ?? false;
                    return IconButton(
                      tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      onPressed: () =>
                          _userData.setBookmark(widget.slokaId, !isBookmarked),
                    );
                  },
                ),
              ],
            ),
      bottomNavigationBar: widget.isCompact
          ? MiniPlayerBar(
              controller: AudioControllerScope.of(context),
              slokaName: 'Sloka ${widget.position}',
            )
          : AnimatedBuilder(
              animation: audioSettingsController,
              builder: (context, _) {
                final audioSettings = audioSettingsController.value;
                return AudioPlayerBarWithController(
                  controller: AudioControllerScope.of(context),
                  autoPlay: audioSettings.autoPlayNext,
                  onToggleAutoPlay: (v) => audioSettingsController.update(
                    audioSettings.copyWith(autoPlayNext: v),
                  ),
                );
              },
            ),
      body: content,
    );
  }
}

class _RoundNavButton extends StatelessWidget {
  const _RoundNavButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.black20, blurRadius: 6)],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.gray1),
        onPressed: onPressed,
      ),
    );
  }
}

class _SlokaNavigator extends StatelessWidget {
  const _SlokaNavigator({
    required this.db,
    required this.chapterId,
    required this.position,
  });

  final AppDatabase db;
  final int chapterId;
  final int position;

  @override
  Widget build(BuildContext context) {
    final previousQuery =
        (db.select(db.slokas)
              ..where(
                (t) =>
                    t.chapterId.equals(chapterId) &
                    t.position.isSmallerThanValue(position),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.position)])
              ..limit(1))
            .watchSingleOrNull();
    final nextQuery =
        (db.select(db.slokas)
              ..where(
                (t) =>
                    t.chapterId.equals(chapterId) &
                    t.position.isBiggerThanValue(position),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.position)])
              ..limit(1))
            .watchSingleOrNull();

    return StreamBuilder<Sloka?>(
      stream: previousQuery,
      builder: (context, prevSnap) {
        return StreamBuilder<Sloka?>(
          stream: nextQuery,
          builder: (context, nextSnap) {
            final previous = prevSnap.data;
            final next = nextSnap.data;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavButton(
                    icon: Icons.chevron_left,
                    onPressed: previous == null
                        ? null
                        : () => _navigateToSloka(context, previous),
                  ),
                  _NavButton(
                    icon: Icons.chevron_right,
                    onPressed: next == null
                        ? null
                        : () => _navigateToSloka(context, next),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToSloka(BuildContext context, Sloka sloka) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SlokaScreen(
          db: db,
          slokaId: sloka.id,
          chapterId: chapterId,
          position: sloka.position,
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: onPressed != null ? AppColors.red1 : AppColors.gray3,
              width: 1.5,
            ),
            boxShadow: onPressed != null
                ? [const BoxShadow(color: AppColors.black20, blurRadius: 4, offset: Offset(0, 2))]
                : null,
          ),
          child: Icon(
            icon,
            color: onPressed != null ? AppColors.red1 : AppColors.gray3,
          ),
        ),
      ),
    );
  }
}
