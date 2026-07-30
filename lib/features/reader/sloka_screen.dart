import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_versegrid/flutter_versegrid.dart';

import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text.dart';
import '../../app/audio/audio_controller_scope.dart';
import '../../app/audio/audio_state.dart';
import '../../app/audio/audio_storage.dart';
import '../../app/audio/audio_track.dart';
import '../../data/local/app_database.dart';
import '../../data/local/book_repository.dart';
import '../../data/local/user_data_repository.dart';
import '../../l10n/l10n.dart';
import '../settings/audio_settings_controller.dart';
import '../settings/reader_settings.dart';
import '../shared/widgets/audio_player_bar.dart';
import '../shared/widgets/author_badge.dart';
import 'note_screen.dart';
import 'widgets/mini_player_bar.dart';
import '../../ui/widgets/share_button.dart';

/// Ornamental divider used between content sections, matching legacy's
/// `divider.png` flourish (used instead of a plain hairline `Divider`).
class _OrnamentalDivider extends StatelessWidget {
  const _OrnamentalDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
      child: Center(
        child: Image.asset(
          'assets/icons/divider.png',
          height: 12,
          color: AppColors.red1,
        ),
      ),
    );
  }
}

class SlokaScreen extends StatefulWidget {
  const SlokaScreen({
    super.key,
    required this.db,
    required this.slokaId,
    this.chapterId,
    this.position,
    this.embedded = false,
    this.isCompact = false,
    this.cameFromBookmarks = false,
  });

  final AppDatabase db;
  final int slokaId;
  final int? chapterId;
  final int? position;
  final bool embedded;
  final bool isCompact;
  final bool cameFromBookmarks;

  @override
  State<SlokaScreen> createState() => _SlokaScreenState();
}

class _SlokaScreenState extends State<SlokaScreen> {
  late final UserDataRepository _userData;
  late final BookRepository _bookRepository;
  int? _boundSlokaId;
  bool _wiredCompletion = false;
  bool _commentsExpanded = false;

  @override
  void initState() {
    super.initState();
    _userData = UserDataRepository(widget.db);
    _bookRepository = BookRepository(widget.db);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wiredCompletion) return;
    _wiredCompletion = true;
    AudioControllerScope.of(context).onCompleted = _handleAudioCompleted;
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
      final local = await audioStorage.chapterLocalUriIfExists(
        track,
        chapterId,
      );
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

    final next =
        await (widget.db.select(widget.db.slokas)
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
          cameFromBookmarks: widget.cameFromBookmarks,
        ),
      ),
    );
  }

  Future<Sloka?> _fetchAdjacentSloka({required bool forward}) async {
    final chapterId = widget.chapterId;
    final position = widget.position;
    if (chapterId == null || position == null) return null;
    final query = widget.db.select(widget.db.slokas)
      ..where(
        (t) =>
            t.chapterId.equals(chapterId) &
            (forward
                ? t.position.isBiggerThanValue(position)
                : t.position.isSmallerThanValue(position)),
      )
      ..orderBy([
        (t) => forward
            ? OrderingTerm.asc(t.position)
            : OrderingTerm.desc(t.position),
      ])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<void> _navigateAdjacent({required bool forward}) async {
    final next = await _fetchAdjacentSloka(forward: forward);
    if (!mounted || next == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SlokaScreen(
          db: widget.db,
          slokaId: next.id,
          chapterId: widget.chapterId,
          position: next.position,
          embedded: widget.embedded,
          isCompact: widget.isCompact,
          cameFromBookmarks: widget.cameFromBookmarks,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
        if (snap.connectionState == ConnectionState.waiting && sloka == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (sloka == null) {
          return const Center(child: Text('Sloka not found.'));
        }

        _bindAudioIfNeeded(sloka);

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: [
            // Header: prev/next arrows flanking the verse number, chapter
            // name below — matches legacy's fragment_sloka.xml layout.
            Row(
              children: [
                _HeaderNavIcon(
                  icon: Icons.chevron_left,
                  onPressed: widget.chapterId == null || widget.position == null
                      ? null
                      : () => _navigateAdjacent(forward: false),
                  futureEnabled: _fetchAdjacentSloka(forward: false),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        sloka.name,
                        textAlign: TextAlign.center,
                        style: AppText.heading().copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      StreamBuilder<Chapter?>(
                        stream:
                            (widget.db.select(widget.db.chapters)
                                  ..where((t) => t.id.equals(sloka.chapterId)))
                                .watchSingleOrNull(),
                        builder: (context, chapterSnap) {
                          final chapterName = chapterSnap.data?.name;
                          if (chapterName == null) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            chapterName,
                            textAlign: TextAlign.center,
                            style: AppText.heading(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                _HeaderNavIcon(
                  icon: Icons.chevron_right,
                  onPressed: widget.chapterId == null || widget.position == null
                      ? null
                      : () => _navigateAdjacent(forward: true),
                  futureEnabled: _fetchAdjacentSloka(forward: true),
                ),
              ],
            ),
            ValueListenableBuilder<ReaderSettings>(
              valueListenable: readerSettingsController,
              builder: (context, settings, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (settings.showSanskrit &&
                        (sloka.slokaText ?? '').isNotEmpty) ...[
                      const _OrnamentalDivider(),
                      VersePassage(
                        layout: VersePassageLayout.columnCenter,
                        primary: sloka.slokaText!,
                        primaryStyle: AppText.sanskrit(),
                        primaryTextAlign: TextAlign.center,
                      ),
                    ],
                    if (settings.showTransliteration &&
                        (sloka.transcription ?? '').isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.space4),
                      VersePassage(
                        layout: VersePassageLayout.columnCenter,
                        primary: sloka.transcription!,
                        primaryStyle: AppText.bodyItalic(),
                        primaryTextAlign: TextAlign.center,
                      ),
                    ],
                    if (settings.showVocabulary) ...[
                      StreamBuilder<List<Vocabulary>>(
                        stream: vocabQuery.watch(),
                        builder: (context, vocabSnap) {
                          final items = vocabSnap.data ?? const [];
                          if (items.isEmpty) return const SizedBox.shrink();
                          return Column(
                            children: [
                              const _OrnamentalDivider(),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: AppText.body(),
                                  children: [
                                    for (var i = 0; i < items.length; i++) ...[
                                      TextSpan(
                                        text: items[i].tokenText,
                                        style: AppText.body().copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' — ${items[i].translation}',
                                      ),
                                      TextSpan(
                                        text: i == items.length - 1
                                            ? '.'
                                            : '; ',
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                    if (settings.showTranslation)
                      StreamBuilder<List<SlokaEditionView>>(
                        stream: _bookRepository.watchEditions(sloka.id),
                        builder: (context, editionsSnap) {
                          final editions = editionsSnap.data ?? const [];
                          final translations = editions
                              .where((e) => (e.translation ?? '').isNotEmpty)
                              .toList();
                          if (translations.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final edition in translations) ...[
                                const _OrnamentalDivider(),
                                if (translations.length > 1) ...[
                                  Center(
                                    child: Text(
                                      edition.bookInitials,
                                      style: AppText.pillLabel(),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.space2),
                                ],
                                VersePassage(
                                  layout: VersePassageLayout.columnCenter,
                                  primary: edition.translation!,
                                  primaryStyle: AppText.body(),
                                  primaryTextAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    if (settings.showComment)
                      StreamBuilder<List<SlokaEditionView>>(
                        stream: _bookRepository.watchEditions(sloka.id),
                        builder: (context, editionsSnap) {
                          final editions = editionsSnap.data ?? const [];
                          final comments = editions
                              .where((e) => (e.comment ?? '').isNotEmpty)
                              .toList();
                          if (comments.isEmpty) return const SizedBox.shrink();
                          final shown = _commentsExpanded
                              ? comments
                              : comments.take(1).toList();
                          final moreCount = comments.length - 1;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final edition in shown) ...[
                                const _OrnamentalDivider(),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AuthorBadge(
                                      initials: edition.bookInitials,
                                      name: edition.bookName,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.space2),
                                VersePassage(
                                  layout: VersePassageLayout.columnStretch,
                                  primary: edition.comment!,
                                  primaryStyle: AppText.body(),
                                  primaryTextAlign: TextAlign.start,
                                ),
                              ],
                              if (moreCount > 0) ...[
                                const SizedBox(height: AppSpacing.space3),
                                Center(
                                  child: FilledButton(
                                    onPressed: () => setState(
                                      () => _commentsExpanded =
                                          !_commentsExpanded,
                                    ),
                                    child: Text(
                                      _commentsExpanded
                                          ? l10n.readerMinimize
                                          : l10n.readerMoreComments(moreCount),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
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
              if (widget.chapterId != null && widget.position != null) ...[
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.45,
                  left: 12,
                  child: _RoundNavButton(
                    icon: Icons.chevron_left,
                    onPressed: () => _navigateAdjacent(forward: false),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.45,
                  right: 12,
                  child: _RoundNavButton(
                    icon: Icons.chevron_right,
                    onPressed: () => _navigateAdjacent(forward: true),
                  ),
                ),
              ],
            ],
          )
        : body;

    final backTitle = widget.cameFromBookmarks
        ? l10n.readerToBookmarks
        : l10n.readerToContents;

    return Scaffold(
      appBar: widget.isCompact
          ? AppBar(
              title: Text(backTitle, style: AppText.navTitle()),
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.gray1,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.gray1),
              actions: [
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
                StreamBuilder<String?>(
                  stream: _userData.watchNote(widget.slokaId),
                  builder: (context, snap) {
                    final hasNote = (snap.data ?? '').isNotEmpty;
                    return IconButton(
                      icon: Icon(
                        hasNote
                            ? Icons.mode_comment
                            : Icons.mode_comment_outlined,
                        color: hasNote ? AppColors.red1 : AppColors.gray1,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NoteScreen(
                              userData: _userData,
                              slokaId: widget.slokaId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                ShareButton(chapter: widget.chapterId, verse: widget.slokaId),
              ],
            )
          : AppBar(
              title: Text(backTitle, style: AppText.navTitle()),
              actions: [
                StreamBuilder<String?>(
                  stream: _userData.watchNote(widget.slokaId),
                  builder: (context, snap) {
                    final hasNote = (snap.data ?? '').isNotEmpty;
                    return IconButton(
                      icon: Icon(
                        hasNote
                            ? Icons.mode_comment
                            : Icons.mode_comment_outlined,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NoteScreen(
                              userData: _userData,
                              slokaId: widget.slokaId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                ShareButton(chapter: widget.chapterId, verse: widget.slokaId),
                StreamBuilder<bool>(
                  stream: _userData.watchBookmark(widget.slokaId),
                  builder: (context, snap) {
                    final isBookmarked = snap.data ?? false;
                    return IconButton(
                      tooltip: isBookmarked
                          ? 'Remove bookmark'
                          : 'Add bookmark',
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

/// Prev/next chevron flanking the header verse number (phone/non-compact
/// mode). Disabled at the first/last verse of the book, matching legacy.
class _HeaderNavIcon extends StatelessWidget {
  const _HeaderNavIcon({
    required this.icon,
    required this.onPressed,
    required this.futureEnabled,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Future<Sloka?> futureEnabled;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) return const SizedBox(width: 40, height: 40);
    return FutureBuilder<Sloka?>(
      future: futureEnabled,
      builder: (context, snap) {
        final enabled = snap.data != null;
        return IconButton(
          icon: Icon(icon),
          color: enabled ? AppColors.gray1 : AppColors.gray3,
          onPressed: enabled ? onPressed : null,
        );
      },
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
