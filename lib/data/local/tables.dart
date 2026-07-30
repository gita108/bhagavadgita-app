import 'package:drift/drift.dart';

class SnapshotMeta extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contentHash => text()();
  IntColumn get fetchedAtMs => integer()();
  TextColumn get source => text()(); // bundled_seed | remote_sync
  IntColumn get schemaVersion => integer()();
}

class Languages extends Table {
  IntColumn get id => integer()();
  TextColumn get code => text()(); // ru, en, zh-CN, ...
  TextColumn get name => text().nullable()();
  TextColumn get nativeName => text().nullable()();
  TextColumn get script => text().nullable()();
  TextColumn get direction => text().nullable()(); // ltr | rtl
  TextColumn get type => text().nullable()(); // source | original | translated

  @override
  Set<Column> get primaryKey => {id};
}

class Books extends Table {
  IntColumn get id => integer()();
  IntColumn get languageId => integer()();
  TextColumn get name => text()();
  TextColumn get initials => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Chapters extends Table {
  IntColumn get id => integer()();
  IntColumn get bookId => integer()();
  TextColumn get name => text()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Slokas extends Table {
  IntColumn get id => integer()();
  IntColumn get chapterId => integer()();
  TextColumn get name => text()(); // e.g. "2.11"
  TextColumn get slokaText => text().nullable()(); // sanskrit
  TextColumn get transcription => text().nullable()();
  TextColumn get translation => text().nullable()();
  TextColumn get comment => text().nullable()();
  IntColumn get position => integer()();
  TextColumn get audio => text().nullable()();
  TextColumn get audioSanskrit => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Vocabularies extends Table {
  IntColumn get id => integer()();
  IntColumn get slokaId => integer()();
  TextColumn get tokenText => text()(); // token/translit
  TextColumn get translation => text()(); // meaning
  IntColumn get position => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// User data must be isolated from content snapshot updates.
class Bookmarks extends Table {
  IntColumn get slokaId => integer()();
  IntColumn get createdAtMs => integer()();

  @override
  Set<Column> get primaryKey => {slokaId};
}

class Notes extends Table {
  IntColumn get slokaId => integer()();
  TextColumn get note => text()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {slokaId};
}

// Multi-book/multi-interpretation catalog + downloaded editions. Deliberately
// isolated from SnapshotRepository.replaceSnapshot (same reasoning as
// Bookmarks/Notes above) — replaceSnapshot unconditionally wipes the
// snapshot-owned `Books`/`Chapters`/`Slokas` tables on every seed/sync, which
// would silently delete a user's downloaded extra editions if they lived
// there instead. Named `InterpretationBooks` (not `Books`) to avoid
// colliding with the existing snapshot-owned `Books` table above, which
// continues to hold only the single default/bundled book's catalog row.
class InterpretationBooks extends Table {
  IntColumn get id => integer()(); // matches backend Books.Id
  IntColumn get languageId => integer()();
  TextColumn get name => text()();
  TextColumn get initials => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// One row per (verse, book) — that book's translation+comment for the verse
// identified by `defaultSlokaId` (a row id in the snapshot-owned `Slokas`
// table, always sourced from the default book). Matched to the fetched
// book's own (independently-numbered) sloka by `Sloka.Name` (e.g. "2.47") —
// there is no shared verse id across books' own Chapters/Slokas rows.
class SlokaEditions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get defaultSlokaId => integer()();
  IntColumn get bookId => integer()();
  TextColumn get translation => text().nullable()();
  TextColumn get comment => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {defaultSlokaId, bookId},
  ];
}
