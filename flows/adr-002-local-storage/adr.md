# ADR-002: Local Storage Strategy

## Meta

- **Number**: ADR-002
- **Type**: constraining
- **Status**: DRAFT
- **Created**: 2026-04-29
- **Author**: Legacy Analysis
- **Source**: `legacy/legacy_bhagavadgita.book_swift`, `legacy/legacy_bhagavadgita.book_java`

## Context

The Bhagavad Gita app requires local storage for:
1. **Content data** (downloaded books, chapters, slokas, vocabulary)
2. **User data** (bookmarks, notes, settings)
3. **Sync metadata** (last fetch timestamps, download status)

Analysis of legacy implementations shows both iOS and Android use SQLite with custom ORM wrappers. The Flutter migration must decide on a storage strategy that:
- Preserves data model semantics
- Supports offline-first behavior
- Separates content from user data (for safe content updates)

## Decision Drivers

- **Offline Capability**: App must work without network
- **Content Updates**: Content can be refreshed without losing user data
- **Performance**: Fast queries for shloka lookup, search, bookmarks
- **Cross-Platform**: Must work identically on iOS and Android

## Legacy Implementation Analysis

### iOS (Swift) - DbHelper Pattern

```swift
// From Bookmark.swift:34-46
let conn = DbConnection(dbPath: DbHelper.dbPath())
conn.open()
let cmd = DbCommand(connection: conn)
cmd.text = "INSERT OR REPLACE INTO Bookmarks (ChapterOrder, SlokaOrder, IsDeleted) VALUES (:ChapterOrder, :SlokaOrder, :IsDeleted)"
cmd.parameters.append(DbParameter(name: ":ChapterOrder", value: chapterOrder))
cmd.executeNonQuery()
conn.close()
```

### Android (Java) - Annotation ORM

```java
// From Sloka.java:18-36
@Table("Slokas")
public class Sloka implements Serializable {
    @Key(false)
    private int id;
    @Column("Position")
    private int order;
    @NotMapped
    private ArrayList<Vocabulary> vocabularies;
}
```

### Legacy Database Tables

| Table | Type | Purpose |
|-------|------|---------|
| Languages | Content | Available translation languages |
| Books | Content | Book editions with language mapping |
| Chapters | Content | Chapter metadata |
| Slokas | Content | Verse text, translations, audio refs |
| Vocabularies | Content | Word-by-word breakdown |
| Bookmarks | User | User-marked verses |
| (Notes) | User | User notes (Android: in Sloka.note) |
| (Settings) | User | User preferences |

## Considered Options

### Option 1: SQLite + Drift (Chosen)

**Description**: Use Drift (formerly Moor) as type-safe SQLite wrapper for Flutter

**Pros**:
- Type-safe queries with compile-time checks
- Reactive streams (watch queries)
- Migration support
- Production-proven in Flutter ecosystem
- Closest to legacy pattern

**Cons**:
- Code generation required
- Slightly more boilerplate than NoSQL

**Estimated Effort**: Medium

### Option 2: Isar (NoSQL)

**Description**: Use Isar NoSQL database

**Pros**:
- Very fast
- No SQL
- Built-in full-text search

**Cons**:
- Different data model from legacy
- Migration from relational model complex
- Less mature than SQLite

**Estimated Effort**: Medium-High

### Option 3: Hive (Key-Value)

**Description**: Use Hive for simple key-value storage

**Pros**:
- Very simple API
- Fast for simple use cases

**Cons**:
- No relational queries
- Complex for hierarchical content
- Would require restructuring data model

**Estimated Effort**: High (due to model changes)

### Option 4: Raw SQLite (sqflite)

**Description**: Use sqflite directly without ORM

**Pros**:
- Minimal dependencies
- Full control

**Cons**:
- Manual SQL strings
- No type safety
- Error-prone

**Estimated Effort**: Medium

## Decision

We will use **Option 1: SQLite + Drift** because:

- Maintains relational model matching legacy implementation
- Type-safe queries prevent runtime SQL errors
- Reactive streams integrate well with Flutter state management
- Migration system supports future schema evolution
- Industry standard for Flutter SQLite

## Database Schema Design

### Content Tables (replaceable snapshot)

```sql
-- Languages
CREATE TABLE languages (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  code TEXT NOT NULL
);

-- Books
CREATE TABLE books (
  id INTEGER PRIMARY KEY,
  language_id INTEGER NOT NULL REFERENCES languages(id),
  name TEXT NOT NULL,
  initials TEXT NOT NULL,
  chapters_count INTEGER NOT NULL DEFAULT 0,
  is_downloaded INTEGER NOT NULL DEFAULT 0
);

-- Chapters
CREATE TABLE chapters (
  id INTEGER PRIMARY KEY,
  book_id INTEGER NOT NULL REFERENCES books(id),
  name TEXT NOT NULL,
  "order" INTEGER NOT NULL
);

-- Slokas
CREATE TABLE slokas (
  id INTEGER PRIMARY KEY,
  chapter_id INTEGER NOT NULL REFERENCES chapters(id),
  name TEXT NOT NULL,
  text TEXT,
  transcription TEXT,
  translation TEXT,
  comment TEXT,
  "order" INTEGER NOT NULL,
  audio TEXT,
  audio_sanskrit TEXT
);

-- Vocabularies
CREATE TABLE vocabularies (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sloka_id INTEGER NOT NULL REFERENCES slokas(id),
  text TEXT NOT NULL,
  translation TEXT NOT NULL
);

-- Snapshot Metadata
CREATE TABLE snapshot_meta (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  version TEXT NOT NULL,
  fetched_at INTEGER NOT NULL,
  source TEXT NOT NULL
);
```

### User Tables (preserved across updates)

```sql
-- Bookmarks (matches legacy: ChapterOrder + SlokaOrder)
CREATE TABLE bookmarks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  chapter_order INTEGER NOT NULL,
  sloka_order INTEGER NOT NULL,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  UNIQUE(chapter_order, sloka_order)
);

-- Notes
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sloka_id INTEGER NOT NULL,
  text TEXT NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE(sloka_id)
);

-- User Settings
CREATE TABLE user_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```

## Consequences

### Positive

- Clean separation: content can be replaced atomically
- User data preserved across content updates
- Relational queries for search and navigation
- Type-safe with Drift codegen

### Negative

- Requires codegen build step
- Schema migrations needed for future changes
- Slightly larger bundle than NoSQL options

### Neutral

- Same conceptual model as legacy apps
- Standard SQLite debugging tools work

## Implementation Notes

- Use separate Drift databases for content vs user data (optional)
- Implement atomic snapshot replacement with transaction
- Index `chapter_id` on slokas for fast chapter loading
- Index `sloka_id` on vocabularies for word lookup

## Related Decisions

- ADR-001: API Contract Design (data fetched from these endpoints)
- ADR-003: Offline-First Architecture (storage enables offline)

## Related Specs

- `flows/sdd-legacy-database-schema/`: Detailed schema spec
- `flows/tdd-user-data-persistence/`: Tests for bookmark/note operations

## References

- Swift DB: `legacy/legacy_bhagavadgita.book_swift/Gita/Model/DataAccess/DataClasses/Bookmark.swift`
- Java ORM: `legacy/legacy_bhagavadgita.book_java/app/src/main/java/com/ethnoapp/bgita/model/Sloka.java`
- Drift docs: https://drift.simonbinder.eu/

## Tags

database sqlite storage drift offline persistence

---

## Approval

### Review History

| Date | Reviewer | Status | Comments |
|------|----------|--------|----------|
| 2026-04-29 | Legacy Analysis | draft | Generated from code analysis |

### Final Decision

- [ ] Approved by: [name]
- [ ] Decided on: [date]
- [ ] Implementation assigned to: [name/team]
