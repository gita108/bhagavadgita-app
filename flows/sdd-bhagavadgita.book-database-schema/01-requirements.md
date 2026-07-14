# Requirements: Legacy Database Schema

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29
> Source: Legacy iOS/Android code analysis + CSV exports

## Problem Statement

The Flutter app requires a local SQLite database for offline content storage and user data persistence. Analysis of legacy implementations shows:
- iOS uses `DbHelper` with raw SQL
- Android uses annotation-based ORM
- Both store the same logical data with minor differences

This spec documents the exact database schema derived from legacy code and CSV exports.

## User Stories

### Primary

**As a** Flutter app
**I want** a local database that mirrors legacy structure
**So that** I can store downloaded content and user data offline

### Secondary

**As a** developer
**I want** clear separation of content vs user data
**So that** content can be refreshed without losing user bookmarks/notes

## Legacy Schema Analysis

### iOS Tables (from Bookmark.swift SQL)

```sql
-- From Bookmark.swift:38-40
INSERT OR REPLACE INTO Bookmarks (ChapterOrder, SlokaOrder, IsDeleted)
VALUES (:ChapterOrder, :SlokaOrder, :IsDeleted)
```

### Android Tables (from @Table annotations)

```java
// Language.java:14
@Table("Languages")
public class Language { @Key int id; String name, code; }

// Book.java:16
@Table("Books")
public class Book { @Key int id; int languageId; String name, initials; int chaptersCount; }

// Chapter.java:13
@Table("Chapters")
public class Chapter { @Key int id; int bookId; String name; @Column("Position") int order; }

// Sloka.java:18-19
@Table("Slokas")
public class Sloka {
  @Key int id; int chapterId; String name, text, transcription, translation, comment;
  @Column("Position") int order; String audio, audioSanskrit;
  boolean isBookmark; String note;  // user data mixed in!
}

// Vocabulary.java:17
@Table("Vocabularies")
public class Vocabulary { @Key int id; int slokaId; String text, translation; }
```

### CSV Exports (column verification)

| CSV File | Delimiter | Columns Discovered |
|----------|-----------|-------------------|
| db_languages.csv | `,` | Id, Name, Code |
| db_books.csv | `,` | Id, LanguageId, Name, Initials |
| db_chapters.csv | `,` | Id, BookId, Name, Order |
| Gita_Slokas.csv | `;` | Id, ChapterId, Name, Text, Transcription, Translation, Comment, Order, Audio, AudioSanskrit |
| Gita_Vocabularies.csv | `;` | Id, SlokaId, Text, Translation |

## Acceptance Criteria

### Must Have

1. **Given** downloaded chapter data
   **When** stored in database
   **Then** all slokas and vocabularies are persisted

2. **Given** user creates a bookmark
   **When** content is refreshed
   **Then** bookmark is preserved (not deleted)

3. **Given** database schema
   **When** app starts fresh
   **Then** all tables are created with correct structure

4. **Given** foreign key relationships
   **When** parent record deleted
   **Then** child records are cascaded appropriately

### Should Have

- Index on frequently queried columns (chapterId, shlokaId)
- Migration support for future schema changes
- Separate databases for content vs user data (optional)

### Won't Have (This Iteration)

- Full-text search indexes
- Encryption
- Cloud sync schema

## Constraints

- **Technical**: Must use SQLite (via Drift)
- **Technical**: Must support atomic content replacement
- **Platform**: Schema must work on iOS, Android, Web
- **Dependencies**: ADR-002 defines storage strategy

## Key Design Decision

**Problem**: Legacy Android mixes user data (`isBookmark`, `note`) in Slokas table.

**Solution**: Separate into distinct tables:
- Content tables (replaceable snapshot): languages, books, chapters, slokas, vocabularies
- User tables (never deleted): bookmarks, notes, settings

This allows atomic content refresh without touching user data.

## Open Questions

- [x] Should we use compound keys or auto-increment? → **Client-generated IDs for content, auto-increment for user data**
- [x] How to handle bookmark reference when content refreshed? → **Store chapterOrder + shlokaOrder, not raw IDs**
- [ ] Should quotes be cached locally?

## References

- Swift source: `legacy/legacy_bhagavadgita.book_swift/Gita/Model/DataAccess/DataClasses/Bookmark.swift`
- Java source: `legacy/legacy_bhagavadgita.book_java/app/src/main/java/com/ethnoapp/bgita/model/*.java`
- CSV exports: `legacy/legacy_bhagavadgita.book.db/Books/`
- ADR-002: Local Storage Strategy

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
