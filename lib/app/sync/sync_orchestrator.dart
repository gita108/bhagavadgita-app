import 'package:drift/drift.dart';

import '../../data/local/app_database.dart';
import '../../data/local/snapshot_repository.dart';
import '../../data/remote/dto/chapter_dto.dart';
import '../../data/remote/dto/sloka_dto.dart';
import '../../data/remote/legacy_api_client.dart';
import 'refresh_policy.dart';

class SyncOrchestrator {
  SyncOrchestrator({
    required AppDatabase db,
    LegacyApiClient? apiClient,
    SnapshotRepository? snapshotRepository,
    RefreshPolicy? refreshPolicy,
  })  : _db = db,
        _apiClient = apiClient ?? LegacyApiClient(),
        _snapshotRepository = snapshotRepository ?? SnapshotRepository(db),
        _refreshPolicy = refreshPolicy ?? const RefreshPolicy();

  final AppDatabase _db;
  final LegacyApiClient _apiClient;
  final SnapshotRepository _snapshotRepository;
  final RefreshPolicy _refreshPolicy;

  Future<SyncResult> startupSync() async {
    final shouldRefresh = await _refreshPolicy.shouldRefresh(_snapshotRepository);
    if (!shouldRefresh) return const SyncResult.skipped();
    return refreshNow();
  }

  Future<SyncResult> refreshNow() async {
    try {
      final languages = await _apiClient.getLanguages();
      if (languages.isEmpty) return const SyncResult.failed('Empty languages payload.');

      final languageIds = languages.map((e) => e.id).toList(growable: false);
      final books = await _apiClient.getBooks(languageIds);
      if (books.isEmpty) return const SyncResult.failed('Empty books payload.');

      final chaptersByBook = <int, List<ChapterDto>>{};
      for (final book in books) {
        chaptersByBook[book.id] = await _apiClient.getChapters(book.id);
      }

      final languageRows = languages
          .map(
            (l) => LanguagesCompanion(
              id: Value(l.id),
              code: Value((l.code == null || l.code!.isEmpty) ? 'lang-${l.id}' : l.code!),
              name: Value(l.name),
              nativeName: const Value(null),
              script: const Value(null),
              direction: const Value(null),
              type: const Value('translated'),
            ),
          )
          .toList(growable: false);

      final bookRows = books
          .map(
            (b) => BooksCompanion(
              id: Value(b.id),
              languageId: Value(b.languageId),
              name: Value((b.name == null || b.name!.isEmpty) ? 'Book ${b.id}' : b.name!),
              initials: Value(b.initials),
            ),
          )
          .toList(growable: false);

      final chapterRows = <ChaptersCompanion>[];
      final slokaRows = <SlokasCompanion>[];
      final vocabularyRows = <VocabulariesCompanion>[];

      for (final book in books) {
        final chapters = chaptersByBook[book.id] ?? const <ChapterDto>[];
        for (final chapter in chapters) {
          chapterRows.add(
            ChaptersCompanion(
              id: Value(chapter.id),
              bookId: Value(book.id),
              name: Value((chapter.name == null || chapter.name!.isEmpty) ? 'Chapter ${chapter.id}' : chapter.name!),
              position: Value(chapter.order ?? 0),
            ),
          );

          for (final sloka in chapter.slokas) {
            slokaRows.add(_mapSloka(chapter.id, sloka));
            vocabularyRows.addAll(_mapVocabularies(sloka));
          }
        }
      }

      await _snapshotRepository.replaceSnapshot(
        languages: languageRows,
        books: bookRows,
        chapters: chapterRows,
        slokas: slokaRows,
        vocabularies: vocabularyRows,
        meta: SnapshotMetaCompanion.insert(
          contentHash: 'remote-${DateTime.now().millisecondsSinceEpoch}',
          fetchedAtMs: DateTime.now().millisecondsSinceEpoch,
          source: 'remote_sync',
          schemaVersion: _db.schemaVersion,
        ),
      );

      return SyncResult.success(
        languages: languageRows.length,
        books: bookRows.length,
        chapters: chapterRows.length,
        slokas: slokaRows.length,
      );
    } catch (e) {
      return SyncResult.failed(e.toString());
    }
  }

  SlokasCompanion _mapSloka(int chapterId, SlokaDto s) {
    return SlokasCompanion(
      id: Value(s.id),
      chapterId: Value(chapterId),
      name: Value((s.name == null || s.name!.isEmpty) ? 'Sloka ${s.id}' : s.name!),
      slokaText: Value(s.text),
      transcription: Value(s.transcription),
      translation: Value(s.translation),
      comment: Value(s.comment),
      position: Value(s.order ?? 0),
      audio: Value(s.audio),
      audioSanskrit: Value(s.audioSanskrit),
    );
  }

  List<VocabulariesCompanion> _mapVocabularies(SlokaDto s) {
    return s.vocabularies
        .map(
          (v) => VocabulariesCompanion(
            id: Value(v.id),
            slokaId: Value(s.id),
            tokenText: Value((v.text == null || v.text!.isEmpty) ? 'token-${v.id}' : v.text!),
            translation: Value(v.translation ?? ''),
            position: const Value(null),
          ),
        )
        .toList(growable: false);
  }
}

class SyncResult {
  const SyncResult({
    required this.didSync,
    required this.message,
    required this.languages,
    required this.books,
    required this.chapters,
    required this.slokas,
  });

  const SyncResult.skipped()
      : didSync = false,
        message = 'Skipped by refresh policy.',
        languages = 0,
        books = 0,
        chapters = 0,
        slokas = 0;

  const SyncResult.failed(this.message)
      : didSync = false,
        languages = 0,
        books = 0,
        chapters = 0,
        slokas = 0;

  factory SyncResult.success({
    required int languages,
    required int books,
    required int chapters,
    required int slokas,
  }) {
    return SyncResult(
      didSync: true,
      message: 'Sync completed.',
      languages: languages,
      books: books,
      chapters: chapters,
      slokas: slokas,
    );
  }

  final bool didSync;
  final String message;
  final int languages;
  final int books;
  final int chapters;
  final int slokas;
}

