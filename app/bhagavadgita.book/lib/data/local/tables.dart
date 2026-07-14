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
