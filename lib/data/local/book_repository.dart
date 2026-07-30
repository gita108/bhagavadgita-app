import 'package:drift/drift.dart';

import '../remote/legacy_api_client.dart';
import 'app_database.dart';

/// One book/edition's translation+comment for a single verse, ready for the
/// Reader to render as a stacked section. The default book's own row (from
/// the snapshot-owned `Slokas` table) is included alongside any downloaded
/// extra editions (from `SlokaEditions`) — both surface through this same
/// shape so the Reader doesn't need to special-case the default book.
class SlokaEditionView {
  const SlokaEditionView({
    required this.bookId,
    required this.bookInitials,
    required this.bookName,
    required this.translation,
    required this.comment,
  });

  final int bookId;
  final String bookInitials;
  final String bookName;
  final String? translation;
  final String? comment;
}

/// Manages the multi-book/multi-interpretation catalog (`InterpretationBooks`)
/// and downloaded per-book verse content (`SlokaEditions`). Deliberately
/// separate from `SnapshotRepository`/the content-snapshot pipeline — see
/// `lib/data/local/tables.dart` for why.
class BookRepository {
  BookRepository(this._db, {LegacyApiClient? apiClient})
    : _api = apiClient ?? LegacyApiClient();

  final AppDatabase _db;
  final LegacyApiClient _api;

  /// The single book bundled/synced via the existing content-snapshot
  /// pipeline (`SnapshotRepository`/`SeedInstaller`/`SyncOrchestrator`).
  static const int defaultBookId = 1;

  /// Fetches the full book list and upserts the local catalog. Existing
  /// `isDownloaded` flags are preserved; the default book is always marked
  /// downloaded (it's the one the snapshot pipeline already maintains).
  Future<void> refreshCatalog() async {
    final books = await _api.getBooks(const []);
    if (books.isEmpty) return;

    final existing = await _db.select(_db.interpretationBooks).get();
    final downloadedIds = {
      for (final b in existing)
        if (b.isDownloaded) b.id,
    };

    await _db.batch((batch) {
      batch.insertAll(_db.interpretationBooks, [
        for (final b in books)
          InterpretationBooksCompanion.insert(
            id: Value(b.id),
            languageId: b.languageId,
            name: b.name ?? '',
            initials: Value(b.initials),
            isDefault: Value(b.id == defaultBookId),
            isDownloaded: Value(
              b.id == defaultBookId || downloadedIds.contains(b.id),
            ),
          ),
      ], mode: InsertMode.insertOrReplace);
    });
  }

  /// Catalog filtered to the given content-language codes (matches
  /// `ContentLanguagesController.selectedCodes`); pass null/empty for the
  /// unfiltered full catalog.
  Stream<List<InterpretationBook>> watchCatalog({Set<String>? languageCodes}) {
    final query = _db.select(_db.interpretationBooks).join([
      innerJoin(
        _db.languages,
        _db.languages.id.equalsExp(_db.interpretationBooks.languageId),
      ),
    ])..orderBy([OrderingTerm.asc(_db.interpretationBooks.id)]);

    if (languageCodes != null && languageCodes.isNotEmpty) {
      query.where(_db.languages.code.isIn(languageCodes));
    }

    return query.watch().map(
      (rows) => rows.map((r) => r.readTable(_db.interpretationBooks)).toList(),
    );
  }

  /// Fetches [bookId]'s chapters/slokas and matches them against the default
  /// book's own verses by [Sloka.name] (e.g. "2.47") — there is no shared
  /// verse id across books' independently-numbered Chapters/Slokas. Verses
  /// with no match in the fetched book are skipped, not an error.
  Future<void> downloadBook(int bookId) async {
    if (bookId == defaultBookId) return; // already always "downloaded"

    // Ensure a catalog row exists even if refreshCatalog hasn't run yet.
    final catalogRow = await (_db.select(
      _db.interpretationBooks,
    )..where((t) => t.id.equals(bookId))).getSingleOrNull();
    if (catalogRow == null) {
      final books = await _api.getBooks([bookId]);
      final book = books.where((b) => b.id == bookId).firstOrNull;
      if (book == null) return;
      await _db
          .into(_db.interpretationBooks)
          .insertOnConflictUpdate(
            InterpretationBooksCompanion.insert(
              id: Value(book.id),
              languageId: book.languageId,
              name: book.name ?? '',
              initials: Value(book.initials),
              isDefault: const Value(false),
            ),
          );
    }

    final chapters = await _api.getChapters(bookId);
    final fetchedByName = {
      for (final chapter in chapters)
        for (final sloka in chapter.slokas)
          if (sloka.name != null) sloka.name!: sloka,
    };
    if (fetchedByName.isEmpty) return;

    final defaultSlokas = await _db.select(_db.slokas).get();

    final editionRows = <SlokaEditionsCompanion>[
      for (final defaultSloka in defaultSlokas)
        if (fetchedByName[defaultSloka.name] case final fetched?)
          if ((fetched.translation ?? '').isNotEmpty ||
              (fetched.comment ?? '').isNotEmpty)
            SlokaEditionsCompanion.insert(
              defaultSlokaId: defaultSloka.id,
              bookId: bookId,
              translation: Value(fetched.translation),
              comment: Value(fetched.comment),
            ),
    ];

    await _db.transaction(() async {
      await (_db.delete(
        _db.slokaEditions,
      )..where((t) => t.bookId.equals(bookId))).go();
      if (editionRows.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(_db.slokaEditions, editionRows);
        });
      }
      await (_db.update(_db.interpretationBooks)
            ..where((t) => t.id.equals(bookId)))
          .write(const InterpretationBooksCompanion(isDownloaded: Value(true)));
    });
  }

  /// Clears [bookId]'s downloaded verse content. No-op for the default book.
  Future<void> deleteBook(int bookId) async {
    if (bookId == defaultBookId) return;
    await _db.transaction(() async {
      await (_db.delete(
        _db.slokaEditions,
      )..where((t) => t.bookId.equals(bookId))).go();
      await (_db.update(
        _db.interpretationBooks,
      )..where((t) => t.id.equals(bookId))).write(
        const InterpretationBooksCompanion(isDownloaded: Value(false)),
      );
    });
  }

  /// All editions (default book + any downloaded extras) for the verse
  /// identified by [defaultSlokaId], for the Reader to render stacked.
  Stream<List<SlokaEditionView>> watchEditions(int defaultSlokaId) async* {
    final defaultSloka = await (_db.select(
      _db.slokas,
    )..where((t) => t.id.equals(defaultSlokaId))).getSingleOrNull();
    final defaultBook = await (_db.select(
      _db.interpretationBooks,
    )..where((t) => t.id.equals(defaultBookId))).getSingleOrNull();

    final editionsQuery = _db.select(_db.slokaEditions).join([
      innerJoin(
        _db.interpretationBooks,
        _db.interpretationBooks.id.equalsExp(_db.slokaEditions.bookId),
      ),
    ])..where(_db.slokaEditions.defaultSlokaId.equals(defaultSlokaId));

    await for (final rows in editionsQuery.watch()) {
      yield [
        if (defaultSloka != null &&
            defaultBook != null &&
            ((defaultSloka.translation ?? '').isNotEmpty ||
                (defaultSloka.comment ?? '').isNotEmpty))
          SlokaEditionView(
            bookId: defaultBook.id,
            bookInitials: defaultBook.initials ?? '',
            bookName: defaultBook.name,
            translation: defaultSloka.translation,
            comment: defaultSloka.comment,
          ),
        for (final row in rows)
          SlokaEditionView(
            bookId: row.readTable(_db.interpretationBooks).id,
            bookInitials: row.readTable(_db.interpretationBooks).initials ?? '',
            bookName: row.readTable(_db.interpretationBooks).name,
            translation: row.readTable(_db.slokaEditions).translation,
            comment: row.readTable(_db.slokaEditions).comment,
          ),
      ];
    }
  }
}
