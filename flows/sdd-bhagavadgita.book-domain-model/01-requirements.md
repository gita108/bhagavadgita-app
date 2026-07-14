# Requirements: Legacy Domain Model

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29
> Source: Legacy iOS/Android code analysis

## Problem Statement

The Bhagavad Gita application has 7 core domain entities that are used consistently across iOS (Swift) and Android (Java) implementations. A Flutter migration requires a unified Dart domain model that:
- Matches the semantic meaning of legacy entities
- Supports both API parsing and local storage
- Enables proper separation of content vs user data

This spec documents the exact domain model extracted from legacy code.

## User Stories

### Primary

**As a** Flutter developer
**I want** a well-defined domain model matching legacy apps
**So that** I can implement equivalent functionality in Dart

### Secondary

**As a** maintainer
**I want** clear documentation of entity relationships
**So that** I can understand data flow through the app

## Entities Discovered

### 1. Language

**Purpose**: Represents a translation language

| Field | Swift Type | Java Type | Dart Type | Notes |
|-------|------------|-----------|-----------|-------|
| id | Int | int | int | Primary key |
| name | String | String | String | Display name (e.g., "English") |
| code | String | String | String | ISO code (e.g., "en") |
| isSelected | Bool | boolean (transient) | bool? | Client-only, not from API |

**Source**:
- Swift: `Language.swift:10-31`
- Java: `Language.java:14-21`

### 2. Book

**Purpose**: Represents a book edition/translation

| Field | Swift Type | Java Type | Dart Type | Notes |
|-------|------------|-----------|-----------|-------|
| id | Int | int | int | Primary key |
| languageId | Int | int | int | FK to Language |
| name | String | String | String | Full book title |
| initials | String | String | String | Author code (SM, VC, SP) |
| chaptersCount | Int | int | int | Number of chapters |
| isDownloaded | Bool | int (STATUS_*) | bool | Client-only download state |

**Initials Legend**:
- **SM** = Sridhar Maharaj
- **VC** = Visvanath Cakravarti Thakur
- **SP** = A.C. Bhaktivedanta Swami Prabhupada

**Source**:
- Swift: `Book.swift:19-40`
- Java: `Book.java:16-30`

### 3. Chapter

**Purpose**: Represents a chapter within a book

| Field | Swift Type | Java Type | Dart Type | Notes |
|-------|------------|-----------|-----------|-------|
| id | Int | int | int | Primary key (client-assigned) |
| bookId | Int | int | int | FK to Book |
| name | String | String | String | Chapter title |
| order | Int | int (Position) | int | Display order (1-18) |
| shlokas | [Shloka] | ArrayList<Sloka> | List<Shloka>? | Nested in API response |

**Note**: `id` is not in API response, assigned client-side based on bookId + order.

**Source**:
- Swift: `Chapter.swift:10-36`
- Java: `Chapter.java:13-27`

### 4. Shloka (Verse)

**Purpose**: Represents a single verse/sloka

| Field | Swift Type | Java Type | Dart Type | Notes |
|-------|------------|-----------|-----------|-------|
| id | Int | int | int | Primary key (client-assigned) |
| chapterId | Int | int | int | FK to Chapter |
| name | String | String | String | Verse number (e.g., "1.1") |
| text | String | String | String | Sanskrit in Devanagari |
| transcription | String | String | String | Transliteration (IAST/Cyrillic) |
| translation | String | String | String | Translated text |
| comment | String | String | String? | Commentary (often null) |
| order | Int | int (Position) | int | Display order |
| audio | String | String | String? | Audio file path |
| audioSanskrit | String | String | String? | Sanskrit recitation path |
| vocabularies | [Vocabulary] | ArrayList<Vocabulary> | List<Vocabulary> | Nested |
| isBookmark | Bool | boolean | bool | Client-only |
| note | - | String | String? | Android only, client-only |

**Note**: `id` not in API response, assigned based on chapterId + order.

**Source**:
- Swift: `Shloka.swift:10-60`
- Java: `Sloka.java:18-42`

### 5. Vocabulary

**Purpose**: Word-by-word breakdown

| Field | Swift Type | Java Type | Dart Type | Notes |
|-------|------------|-----------|-----------|-------|
| id | - | int | int | Auto-increment locally |
| shlokaId | Int | int | int | FK to Shloka |
| text | String | String | String | Sanskrit word |
| translation | String | String | String | Word meaning |

**Source**:
- Swift: `Vocabulary.swift:10-31`
- Java: `Vocabulary.java:17-24`

### 6. Quote

**Purpose**: Inspirational quote

| Field | Swift Type | Java Type | Dart Type | Notes |
|-------|------------|-----------|-----------|-------|
| author | String | String | String | Quote author |
| text | String | String | String | Quote content |

**Note**: Quotes endpoint returns single quote (random), not list.

**Source**:
- Swift: `Quote.swift:10-23`
- Java: `Quote.java:5-11`

### 7. Bookmark

**Purpose**: User bookmarked verse

| Field | Swift Type | Java Type | Dart Type | Notes |
|-------|------------|-----------|-----------|-------|
| id | - | - | int | Auto-increment |
| chapterOrder | Int | - | int | Chapter number (1-18) |
| shlokaOrder | Int | - | int | Sloka number in chapter |
| isDeleted | Bool | - | bool | Soft delete flag |
| createdAt | - | - | DateTime | For sorting |

**Note**: iOS uses separate Bookmarks table. Android stores `isBookmark` in Sloka.

**Source**:
- Swift: `Bookmark.swift:11-21`

## Entity Relationships

```
Language (1) ──────► (N) Book
                          │
                          │ (1)
                          ▼
                         (N) Chapter
                          │
                          │ (1)
                          ▼
                         (N) Shloka ◄──── Bookmark (user data)
                          │
                          │ (1)
                          ▼
                         (N) Vocabulary

Quote (standalone)
```

## Acceptance Criteria

### Must Have

1. **Given** legacy iOS entity
   **When** converted to Dart
   **Then** all fields preserve their semantic meaning

2. **Given** API JSON response
   **When** parsed into Dart entities
   **Then** nested structures (Chapter→Shloka→Vocabulary) are handled correctly

3. **Given** entities for database storage
   **When** saved and loaded
   **Then** relationships are maintained via foreign keys

### Should Have

- Equality operators for entities (for testing/comparison)
- `copyWith` methods for immutable updates
- JSON serialization/deserialization

### Won't Have (This Iteration)

- Full-text search indexes
- Audio file download management
- Complex caching policies

## Constraints

- **Technical**: Entities must be serializable to/from JSON
- **Platform**: Must work on iOS, Android, Web (Flutter)
- **Dependencies**: Use json_serializable or equivalent for codegen

## Open Questions

- [x] Are IDs assigned server-side or client-side? → **Client-side for Chapter/Shloka**
- [x] How are notes stored? → **Android: in Sloka. iOS: separate table (not found)**
- [ ] Should we unify bookmark storage across platforms?

## References

- Swift source: `legacy/legacy_bhagavadgita.book_swift/Gita/Model/DataAccess/DataClasses/`
- Java source: `legacy/legacy_bhagavadgita.book_java/app/src/main/java/com/ethnoapp/bgita/model/`
- ADR-001: API Contract Design
- ADR-002: Local Storage Strategy

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
