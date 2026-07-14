# Specifications: Legacy Database Schema

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29
> Requirements: [01-requirements.md](./01-requirements.md)

## Overview

This spec defines the complete SQLite database schema for the Flutter Bhagavad Gita app, based on legacy iOS/Android implementations and CSV exports.

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `lib/data/database/` | Create | Drift database definition |
| `lib/data/database/tables/` | Create | Table definitions |
| `lib/data/database/daos/` | Create | Data access objects |

## Architecture

### Table Organization

```
┌─────────────────────────────────────────────────────────────┐
│                    CONTENT TABLES                            │
│         (Replaceable - full refresh on sync)                │
├─────────────────────────────────────────────────────────────┤
│   languages    books    chapters    slokas    vocabularies  │
│                                                              │
│   snapshot_meta (version, timestamp)                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                     USER TABLES                              │
│          (Preserved - never deleted by sync)                │
├─────────────────────────────────────────────────────────────┤
│   bookmarks         notes         user_settings             │
│                                                              │
│   reading_progress (optional)                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    SYSTEM TABLES                             │
│              (Sync state, recovery)                         │
├─────────────────────────────────────────────────────────────┤
│   sync_events       pending_tasks                           │
└─────────────────────────────────────────────────────────────┘
```

## Schema Definition

### Content Tables

#### languages

```sql
CREATE TABLE languages (
  id INTEGER PRIMARY KEY NOT NULL,
  name TEXT NOT NULL,
  code TEXT NOT NULL
);

-- Indexes
CREATE INDEX idx_languages_code ON languages(code);
```

**Drift Definition**:
```dart
class Languages extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get code => text()();

  @override
  Set<Column> get primaryKey => {id};
}
```

#### books

```sql
CREATE TABLE books (
  id INTEGER PRIMARY KEY NOT NULL,
  language_id INTEGER NOT NULL REFERENCES languages(id),
  name TEXT NOT NULL,
  initials TEXT NOT NULL,
  chapters_count INTEGER NOT NULL DEFAULT 0,
  is_downloaded INTEGER NOT NULL DEFAULT 0
);

-- Indexes
CREATE INDEX idx_books_language_id ON books(language_id);
```

**Drift Definition**:
```dart
class Books extends Table {
  IntColumn get id => integer()();
  IntColumn get languageId => integer().references(Languages, #id)();
  TextColumn get name => text()();
  TextColumn get initials => text()();
  IntColumn get chaptersCount => integer().withDefault(const Constant(0))();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

#### chapters

```sql
CREATE TABLE chapters (
  id INTEGER PRIMARY KEY NOT NULL,
  book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  "order" INTEGER NOT NULL
);

-- Indexes
CREATE INDEX idx_chapters_book_id ON chapters(book_id);
CREATE INDEX idx_chapters_order ON chapters(book_id, "order");
```

**Drift Definition**:
```dart
class Chapters extends Table {
  IntColumn get id => integer()();
  IntColumn get bookId => integer().references(Books, #id)();
  TextColumn get name => text()();
  IntColumn get order => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
```

#### slokas

```sql
CREATE TABLE slokas (
  id INTEGER PRIMARY KEY NOT NULL,
  chapter_id INTEGER NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  text TEXT NOT NULL,
  transcription TEXT NOT NULL,
  translation TEXT NOT NULL,
  comment TEXT,
  "order" INTEGER NOT NULL,
  audio TEXT,
  audio_sanskrit TEXT
);

-- Indexes (critical for performance)
CREATE INDEX idx_slokas_chapter_id ON slokas(chapter_id);
CREATE INDEX idx_slokas_order ON slokas(chapter_id, "order");
```

**Drift Definition**:
```dart
class Slokas extends Table {
  IntColumn get id => integer()();
  IntColumn get chapterId => integer().references(Chapters, #id)();
  TextColumn get name => text()();
  TextColumn get text => text()();
  TextColumn get transcription => text()();
  TextColumn get translation => text()();
  TextColumn get comment => text().nullable()();
  IntColumn get order => integer()();
  TextColumn get audio => text().nullable()();
  TextColumn get audioSanskrit => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

#### vocabularies

```sql
CREATE TABLE vocabularies (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sloka_id INTEGER NOT NULL REFERENCES slokas(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  translation TEXT NOT NULL
);

-- Indexes
CREATE INDEX idx_vocabularies_sloka_id ON vocabularies(sloka_id);
```

**Drift Definition**:
```dart
class Vocabularies extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get slokaId => integer().references(Slokas, #id)();
  TextColumn get text => text()();
  TextColumn get translation => text()();
}
```

#### snapshot_meta

```sql
CREATE TABLE snapshot_meta (
  id INTEGER PRIMARY KEY CHECK (id = 1),  -- singleton row
  version TEXT NOT NULL,
  fetched_at INTEGER NOT NULL,  -- Unix timestamp
  source TEXT NOT NULL  -- 'bundled_seed' | 'remote_sync'
);
```

**Drift Definition**:
```dart
class SnapshotMeta extends Table {
  IntColumn get id => integer()();
  TextColumn get version => text()();
  IntColumn get fetchedAt => integer()();
  TextColumn get source => text()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### User Tables

#### bookmarks

```sql
CREATE TABLE bookmarks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  chapter_order INTEGER NOT NULL,  -- 1-18
  sloka_order INTEGER NOT NULL,    -- verse number in chapter
  is_deleted INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,  -- Unix timestamp
  UNIQUE(chapter_order, sloka_order)
);

-- Index for lookup
CREATE INDEX idx_bookmarks_lookup ON bookmarks(chapter_order, sloka_order)
  WHERE is_deleted = 0;
```

**Note**: Uses `chapter_order` + `sloka_order` instead of `sloka_id` so bookmarks survive content refresh.

**Drift Definition**:
```dart
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chapterOrder => integer()();
  IntColumn get shlokaOrder => integer()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [{chapterOrder, shlokaOrder}];
}
```

#### notes

```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sloka_id INTEGER NOT NULL,  -- reference by content ID
  text TEXT NOT NULL,
  updated_at INTEGER NOT NULL,  -- Unix timestamp
  UNIQUE(sloka_id)
);
```

**Note**: References `sloka_id` directly. If content refreshed with different IDs, notes would orphan. Alternative: use chapter_order + sloka_order like bookmarks.

**Drift Definition**:
```dart
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get shlokaId => integer()();
  TextColumn get text => text()();
  IntColumn get updatedAt => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [{shlokaId}];
}
```

#### user_settings

```sql
CREATE TABLE user_settings (
  key TEXT PRIMARY KEY NOT NULL,
  value TEXT NOT NULL
);
```

**Keys**:
- `selected_language_id`
- `selected_book_id`
- `last_read_chapter_order`
- `last_read_sloka_order`
- `font_size`
- `theme`

**Drift Definition**:
```dart
class UserSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
```

### System Tables

#### sync_events

```sql
CREATE TABLE sync_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  event_type TEXT NOT NULL,  -- 'started' | 'completed' | 'failed'
  timestamp INTEGER NOT NULL,
  details TEXT  -- JSON with error info etc.
);
```

## Data Access Objects (DAOs)

### ContentDao

```dart
@DriftAccessor(tables: [Languages, Books, Chapters, Slokas, Vocabularies, SnapshotMeta])
class ContentDao extends DatabaseAccessor<AppDatabase> with _$ContentDaoMixin {
  ContentDao(AppDatabase db) : super(db);

  // Languages
  Future<List<Language>> getAllLanguages() => select(languages).get();
  Stream<List<Language>> watchLanguages() => select(languages).watch();

  // Books
  Future<List<Book>> getBooksByLanguage(int languageId) =>
      (select(books)..where((b) => b.languageId.equals(languageId))).get();

  Stream<List<Book>> watchDownloadedBooks() =>
      (select(books)..where((b) => b.isDownloaded.equals(true))).watch();

  // Chapters
  Future<List<Chapter>> getChapters(int bookId) =>
      (select(chapters)
        ..where((c) => c.bookId.equals(bookId))
        ..orderBy([(c) => OrderingTerm.asc(c.order)]))
      .get();

  // Slokas
  Future<List<Sloka>> getSlokas(int chapterId) =>
      (select(slokas)
        ..where((s) => s.chapterId.equals(chapterId))
        ..orderBy([(s) => OrderingTerm.asc(s.order)]))
      .get();

  Stream<Sloka?> watchSloka(int shlokaId) =>
      (select(slokas)..where((s) => s.id.equals(shlokaId))).watchSingleOrNull();

  // Vocabularies
  Future<List<Vocabulary>> getVocabularies(int shlokaId) =>
      (select(vocabularies)..where((v) => v.slokaId.equals(shlokaId))).get();

  // Atomic snapshot replacement
  Future<void> replaceSnapshot(ContentSnapshot snapshot) async {
    await transaction(() async {
      // Delete all content tables
      await delete(vocabularies).go();
      await delete(slokas).go();
      await delete(chapters).go();
      await delete(books).go();
      await delete(languages).go();

      // Insert new data
      await batch((b) {
        b.insertAll(languages, snapshot.languages);
        b.insertAll(books, snapshot.books);
        b.insertAll(chapters, snapshot.chapters);
        b.insertAll(slokas, snapshot.slokas);
        b.insertAll(vocabularies, snapshot.vocabularies);
      });

      // Update metadata
      await into(snapshotMeta).insertOnConflictUpdate(snapshot.meta);
    });
  }
}
```

### UserDataDao

```dart
@DriftAccessor(tables: [Bookmarks, Notes, UserSettings])
class UserDataDao extends DatabaseAccessor<AppDatabase> with _$UserDataDaoMixin {
  UserDataDao(AppDatabase db) : super(db);

  // Bookmarks
  Stream<List<Bookmark>> watchActiveBookmarks() =>
      (select(bookmarks)
        ..where((b) => b.isDeleted.equals(false))
        ..orderBy([(b) => OrderingTerm.desc(b.createdAt)]))
      .watch();

  Future<bool> isBookmarked(int chapterOrder, int shlokaOrder) async {
    final result = await (select(bookmarks)
      ..where((b) => b.chapterOrder.equals(chapterOrder) &
                     b.shlokaOrder.equals(shlokaOrder) &
                     b.isDeleted.equals(false)))
      .getSingleOrNull();
    return result != null;
  }

  Future<void> setBookmark(int chapterOrder, int shlokaOrder, bool bookmarked) async {
    if (bookmarked) {
      await into(bookmarks).insertOnConflictUpdate(
        BookmarksCompanion.insert(
          chapterOrder: chapterOrder,
          shlokaOrder: shlokaOrder,
          isDeleted: const Value(false),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } else {
      await (update(bookmarks)
        ..where((b) => b.chapterOrder.equals(chapterOrder) &
                       b.shlokaOrder.equals(shlokaOrder)))
        .write(const BookmarksCompanion(isDeleted: Value(true)));
    }
  }

  // Notes
  Future<String?> getNote(int shlokaId) async {
    final result = await (select(notes)
      ..where((n) => n.shlokaId.equals(shlokaId)))
      .getSingleOrNull();
    return result?.text;
  }

  Future<void> saveNote(int shlokaId, String text) async {
    await into(notes).insertOnConflictUpdate(
      NotesCompanion.insert(
        shlokaId: shlokaId,
        text: text,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // Settings
  Future<String?> getSetting(String key) async {
    final result = await (select(userSettings)
      ..where((s) => s.key.equals(key)))
      .getSingleOrNull();
    return result?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(userSettings).insertOnConflictUpdate(
      UserSettingsCompanion.insert(key: key, value: value),
    );
  }
}
```

## Behavior Specifications

### Cascade Behavior

| Parent Deleted | Child Action |
|---------------|--------------|
| Book | Chapters cascade delete |
| Chapter | Slokas cascade delete |
| Sloka | Vocabularies cascade delete |
| Language | Books remain (soft constraint) |

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| Empty database | First launch | Tables created, ready for seed |
| Bookmark survives refresh | Content replaced | Bookmark by order preserved |
| Duplicate vocabulary | API returns dupe | Auto-increment creates unique ID |
| Null comment | Sloka without commentary | Store NULL, display nothing |

## Migration Strategy

```dart
@DriftDatabase(
  tables: [Languages, Books, Chapters, Slokas, Vocabularies, SnapshotMeta,
           Bookmarks, Notes, UserSettings, SyncEvents],
  daos: [ContentDao, UserDataDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Future migrations here
    },
  );
}
```

## Testing Strategy

### Unit Tests

- [ ] Create all tables - verify schema
- [ ] Insert content snapshot - verify cascade creates
- [ ] Replace snapshot - verify atomic replacement
- [ ] Bookmark CRUD - create, read, soft delete
- [ ] Note CRUD - create, update, read
- [ ] Settings - key-value storage

### Integration Tests

- [ ] Fresh install → seed → read chapters
- [ ] Bookmark → sync → bookmark preserved
- [ ] Note on sloka → verify persistence

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
