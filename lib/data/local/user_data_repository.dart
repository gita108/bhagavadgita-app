import 'package:drift/drift.dart';

import 'app_database.dart';

class UserDataRepository {
  UserDataRepository(this._db);

  final AppDatabase _db;

  Stream<bool> watchBookmark(int slokaId) {
    final q = _db.select(_db.bookmarks)..where((t) => t.slokaId.equals(slokaId));
    return q.watchSingleOrNull().map((row) => row != null);
  }

  Future<void> setBookmark(int slokaId, bool value) async {
    if (value) {
      await _db.into(_db.bookmarks).insertOnConflictUpdate(
            BookmarksCompanion(
              slokaId: Value(slokaId),
              createdAtMs: Value(DateTime.now().millisecondsSinceEpoch),
            ),
          );
    } else {
      await (_db.delete(_db.bookmarks)..where((t) => t.slokaId.equals(slokaId))).go();
    }
  }

  Stream<String?> watchNote(int slokaId) {
    final q = _db.select(_db.notes)..where((t) => t.slokaId.equals(slokaId));
    return q.watchSingleOrNull().map((row) => row?.note);
  }

  Future<void> saveNote(int slokaId, String note) async {
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      await (_db.delete(_db.notes)..where((t) => t.slokaId.equals(slokaId))).go();
      return;
    }

    await _db.into(_db.notes).insertOnConflictUpdate(
          NotesCompanion(
            slokaId: Value(slokaId),
            note: Value(trimmed),
            updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }
}

