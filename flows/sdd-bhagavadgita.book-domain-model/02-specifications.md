# Specifications: Legacy Domain Model

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29
> Requirements: [01-requirements.md](./01-requirements.md)

## Overview

This spec defines the Dart domain model classes that mirror the legacy iOS/Android entity structure. These classes serve as the core data types throughout the Flutter application.

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `lib/domain/entities/` | Create | New Dart entity classes |
| `lib/data/models/` | Create | DTO classes for API/DB |
| `lib/data/mappers/` | Create | DTO ↔ Entity converters |

## Architecture

### Layer Separation

```
┌─────────────────────────────────────────────────────────┐
│                    Domain Layer                          │
│   lib/domain/entities/                                   │
│   - language.dart                                        │
│   - book.dart                                            │
│   - chapter.dart                                         │
│   - shloka.dart                                          │
│   - vocabulary.dart                                      │
│   - quote.dart                                           │
│   - bookmark.dart                                        │
│   - note.dart                                            │
└─────────────────────────────────────────────────────────┘
                           ▲
                           │ (uses)
                           │
┌─────────────────────────────────────────────────────────┐
│                     Data Layer                           │
│   lib/data/models/                                       │
│   - language_dto.dart (API)                              │
│   - book_dto.dart (API)                                  │
│   - chapter_dto.dart (API, nested)                       │
│   - shloka_dto.dart (API, nested)                        │
│   - vocabulary_dto.dart (API)                            │
│   - quote_dto.dart (API)                                 │
│                                                          │
│   lib/data/database/tables/                              │
│   - (Drift table definitions)                            │
└─────────────────────────────────────────────────────────┘
```

## Data Models

### Domain Entities (Immutable)

```dart
// lib/domain/entities/language.dart
class Language {
  final int id;
  final String name;
  final String code;

  const Language({
    required this.id,
    required this.name,
    required this.code,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

```dart
// lib/domain/entities/book.dart
class Book {
  final int id;
  final int languageId;
  final String name;
  final String initials;
  final int chaptersCount;
  final bool isDownloaded;

  const Book({
    required this.id,
    required this.languageId,
    required this.name,
    required this.initials,
    required this.chaptersCount,
    this.isDownloaded = false,
  });

  Book copyWith({bool? isDownloaded}) => Book(
        id: id,
        languageId: languageId,
        name: name,
        initials: initials,
        chaptersCount: chaptersCount,
        isDownloaded: isDownloaded ?? this.isDownloaded,
      );
}
```

```dart
// lib/domain/entities/chapter.dart
class Chapter {
  final int id;
  final int bookId;
  final String name;
  final int order;
  final List<Shloka>? shlokas; // null when loaded from DB without nested

  const Chapter({
    required this.id,
    required this.bookId,
    required this.name,
    required this.order,
    this.shlokas,
  });
}
```

```dart
// lib/domain/entities/shloka.dart
class Shloka {
  final int id;
  final int chapterId;
  final String name;
  final String text;           // Sanskrit (Devanagari)
  final String transcription;  // IAST/Cyrillic
  final String translation;
  final String? comment;
  final int order;
  final String? audio;
  final String? audioSanskrit;
  final List<Vocabulary> vocabularies;

  const Shloka({
    required this.id,
    required this.chapterId,
    required this.name,
    required this.text,
    required this.transcription,
    required this.translation,
    this.comment,
    required this.order,
    this.audio,
    this.audioSanskrit,
    required this.vocabularies,
  });

  /// Constructs full audio URL from relative path
  String? get audioUrl => audio != null
      ? 'http://app.bhagavadgitaapp.online$audio'
      : null;

  String? get audioSanskritUrl => audioSanskrit != null
      ? 'http://app.bhagavadgitaapp.online$audioSanskrit'
      : null;
}
```

```dart
// lib/domain/entities/vocabulary.dart
class Vocabulary {
  final int? id;       // null when from API
  final int shlokaId;
  final String text;
  final String translation;

  const Vocabulary({
    this.id,
    required this.shlokaId,
    required this.text,
    required this.translation,
  });
}
```

```dart
// lib/domain/entities/quote.dart
class Quote {
  final String author;
  final String text;

  const Quote({
    required this.author,
    required this.text,
  });
}
```

```dart
// lib/domain/entities/bookmark.dart
class Bookmark {
  final int? id;
  final int chapterOrder;
  final int shlokaOrder;
  final bool isDeleted;
  final DateTime createdAt;

  const Bookmark({
    this.id,
    required this.chapterOrder,
    required this.shlokaOrder,
    this.isDeleted = false,
    required this.createdAt,
  });
}
```

```dart
// lib/domain/entities/note.dart
class Note {
  final int? id;
  final int shlokaId;
  final String text;
  final DateTime updatedAt;

  const Note({
    this.id,
    required this.shlokaId,
    required this.text,
    required this.updatedAt,
  });
}
```

### API DTOs (with json_serializable)

```dart
// lib/data/models/api_response.dart
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final int code;
  final T? data;
  final String? message;

  ApiResponse({required this.code, this.data, this.message});

  bool get isSuccess => code == 0;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);
}
```

```dart
// lib/data/models/language_dto.dart
@JsonSerializable()
class LanguageDto {
  final int id;
  final String name;
  final String code;

  LanguageDto({required this.id, required this.name, required this.code});

  factory LanguageDto.fromJson(Map<String, dynamic> json) =>
      _$LanguageDtoFromJson(json);

  Language toEntity() => Language(id: id, name: name, code: code);
}
```

```dart
// lib/data/models/chapter_dto.dart
@JsonSerializable()
class ChapterDto {
  final String name;
  final int order;
  @JsonKey(name: 'slokas')
  final List<ShlokaDto>? slokas;

  ChapterDto({required this.name, required this.order, this.slokas});

  factory ChapterDto.fromJson(Map<String, dynamic> json) =>
      _$ChapterDtoFromJson(json);

  /// Converts to entity, assigning client-side IDs
  Chapter toEntity(int bookId, int chapterIndex) {
    final chapterId = bookId * 100 + order;
    return Chapter(
      id: chapterId,
      bookId: bookId,
      name: name,
      order: order,
      shlokas: slokas
          ?.asMap()
          .entries
          .map((e) => e.value.toEntity(chapterId, e.key))
          .toList(),
    );
  }
}
```

```dart
// lib/data/models/shloka_dto.dart
@JsonSerializable()
class ShlokaDto {
  final String name;
  final String text;
  final String transcription;
  final String translation;
  final String? comment;
  final int order;
  final String? audio;
  final String? audioSanskrit;
  final List<VocabularyDto>? vocabularies;

  ShlokaDto({
    required this.name,
    required this.text,
    required this.transcription,
    required this.translation,
    this.comment,
    required this.order,
    this.audio,
    this.audioSanskrit,
    this.vocabularies,
  });

  factory ShlokaDto.fromJson(Map<String, dynamic> json) =>
      _$ShlokaDtoFromJson(json);

  Shloka toEntity(int chapterId, int shlokaIndex) {
    final shlokaId = chapterId * 1000 + order;
    return Shloka(
      id: shlokaId,
      chapterId: chapterId,
      name: name,
      text: text,
      transcription: transcription,
      translation: translation,
      comment: comment,
      order: order,
      audio: audio,
      audioSanskrit: audioSanskrit,
      vocabularies: vocabularies
              ?.map((v) => v.toEntity(shlokaId))
              .toList() ??
          [],
    );
  }
}
```

## ID Assignment Strategy

Since API doesn't return IDs for Chapter/Shloka, we generate deterministic IDs:

```
Chapter ID = bookId * 100 + chapterOrder
  Example: Book 2, Chapter 5 → ID = 205

Shloka ID = chapterId * 1000 + shlokaOrder
  Example: Chapter 205, Shloka 12 → ID = 205012

Vocabulary ID = auto-increment (local only)
```

This ensures:
- IDs are deterministic (same data = same IDs)
- IDs are globally unique within the app
- IDs can be reconstructed from bookId + orders

## Behavior Specifications

### Entity Creation

1. **From API**: Parse DTO → Call `toEntity()` with context (bookId, etc.)
2. **From DB**: Load table row → Construct entity directly
3. **Client-side**: Create bookmark/note with generated ID

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| Null vocabularies in API | API returns null instead of [] | Default to empty list |
| Missing comment | comment field is null | Keep as null, display nothing |
| Audio path null | No audio for this sloka | `audioUrl` getter returns null |
| Duplicate bookmark | User taps bookmark twice | Use UNIQUE constraint, update |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| JSON parse error | Malformed API response | Throw, let repository handle |
| Missing required field | API contract violation | Throw with field name |
| Invalid ID | Corrupted data | Log error, skip entity |

## Dependencies

### Requires

- ADR-001: API Contract (defines JSON structure)
- ADR-002: Storage Strategy (defines table schema)

### Blocks

- API Client implementation (uses DTOs)
- Repository implementations (uses entities)
- UI layer (displays entities)

## Integration Points

### External Systems

- Backend API (JSON parsing)

### Internal Systems

- Drift database (table definitions reference these models)
- Repository layer (returns entities)
- UI widgets (display entity data)

## Testing Strategy

### Unit Tests

- [ ] `LanguageDto.fromJson` - Parse valid JSON
- [ ] `ChapterDto.toEntity` - Verify nested shloka conversion
- [ ] `ShlokaDto.toEntity` - Verify ID generation formula
- [ ] Entity equality - Compare by ID
- [ ] Edge cases - null fields, empty arrays

### Integration Tests

- [ ] Parse full chapters response → entities
- [ ] Round-trip: entity → DB → entity

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
