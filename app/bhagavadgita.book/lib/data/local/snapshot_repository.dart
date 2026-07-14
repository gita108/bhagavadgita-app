import 'package:drift/drift.dart';

import 'app_database.dart';

class SnapshotRepository {
  SnapshotRepository(this._db);

  final AppDatabase _db;

  Future<bool> hasUsableSnapshot() async {
    final meta = await _db.select(_db.snapshotMeta).get();
    return meta.isNotEmpty;
  }

  Future<SnapshotMetaData?> getCurrentMeta() async {
    final q = _db.select(_db.snapshotMeta)
      ..orderBy([(t) => OrderingTerm.desc(t.fetchedAtMs)])
      ..limit(1);
    return q.getSingleOrNull();
  }

  /// Atomically replaces ONLY the content snapshot.
  ///
  /// User tables (`bookmarks`, `notes`) are intentionally untouched.
  Future<void> replaceSnapshot({
    required List<LanguagesCompanion> languages,
    required List<BooksCompanion> books,
    required List<ChaptersCompanion> chapters,
    required List<SlokasCompanion> slokas,
    required List<VocabulariesCompanion> vocabularies,
    required SnapshotMetaCompanion meta,
  }) async {
    await _db.transaction(() async {
      // Delete from leaves to roots (avoid FK issues if added later).
      await (_db.delete(_db.vocabularies)).go();
      await (_db.delete(_db.slokas)).go();
      await (_db.delete(_db.chapters)).go();
      await (_db.delete(_db.books)).go();
      await (_db.delete(_db.languages)).go();
      await (_db.delete(_db.snapshotMeta)).go();

      await _db.batch((batch) {
        batch.insertAll(_db.languages, languages, mode: InsertMode.insertOrReplace);
        batch.insertAll(_db.books, books, mode: InsertMode.insertOrReplace);
        batch.insertAll(_db.chapters, chapters, mode: InsertMode.insertOrReplace);
        batch.insertAll(_db.slokas, slokas, mode: InsertMode.insertOrReplace);
        batch.insertAll(_db.vocabularies, vocabularies, mode: InsertMode.insertOrReplace);
        batch.insert(_db.snapshotMeta, meta, mode: InsertMode.insertOrReplace);
      });
    });
  }
}

