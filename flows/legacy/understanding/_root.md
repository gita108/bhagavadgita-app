# Understanding: Bhagavad Gita Application - Full Legacy Analysis

> Entry point for data structure and code analysis of legacy apps

## Project Overview

This is a **Bhagavad Gita study application** with:
- Native iOS app (Swift)
- Native Android app (Java)
- Backend API (shared by both platforms)
- SQLite local database (platform-specific implementations)
- Multilingual content support (4 languages, 6 book editions)

## Source Analysis Summary

### 1. iOS Swift App (`legacy/legacy_bhagavadgita.book_swift`)

**Architecture**: MVC with service layer
- **Domain Model**: 7 entities in `Model/DataAccess/DataClasses/`
- **API Client**: `GitaRequestManager.swift` with 4 endpoints
- **Local Storage**: SQLite via `DbHelper`, `DbConnection`, `DbCommand`
- **UI**: ViewControllers for Splash, Contents, Shloka, Bookmarks, Settings

### 2. Android Java App (`legacy/legacy_bhagavadgita.book_java`)

**Architecture**: Activity/Fragment with ORM layer
- **Domain Model**: Same entities in `model/` package with annotations
- **API Client**: `DataService.java` using `GitaRequest`
- **Local Storage**: SQLite via custom ORM (`DbContext`, `DbSet`, `Table` annotations)
- **UI**: Activities (Splash, Main, Settings) + Fragments (Slokas, Bookmarks)

### 3. Database Exports (`legacy/legacy_bhagavadgita.book.db`)

**Content**: CSV exports from production database
- 7 files covering content and analytics domains
- Mix of `,` and `;` delimiters
- UTF-8 with BOM encoding

## Unified Entity Model

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DOMAIN MODEL (iOS/Android)                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌──────────────┐         ┌──────────────┐         ┌──────────────┐        │
│   │  Language    │◄────────│    Book      │────────►│   Chapter    │        │
│   │──────────────│ 1    N  │──────────────│ 1    N  │──────────────│        │
│   │ id: Int      │         │ id: Int      │         │ id: Int      │        │
│   │ name: String │         │ languageId   │         │ bookId: Int  │        │
│   │ code: String │         │ name: String │         │ name: String │        │
│   │ isSelected*  │         │ initials     │         │ order: Int   │        │
│   └──────────────┘         │ chaptersCount│         │ shlokas: []  │        │
│                            │ isDownloaded*│         └──────────────┘        │
│                            └──────────────┘                │                │
│                                                            │ 1              │
│                                                            ▼ N              │
│                                                    ┌──────────────┐         │
│                                                    │    Shloka    │         │
│                                                    │──────────────│         │
│                                                    │ id: Int      │         │
│                                                    │ chapterId    │         │
│                                                    │ name: String │ (1.1)   │
│                                                    │ text: String │ (Skt)   │
│                                                    │ transcription│ (IAST)  │
│                                                    │ translation  │         │
│                                                    │ comment      │         │
│                                                    │ order: Int   │         │
│                                                    │ audio: String│ (path)  │
│                                                    │ audioSanskrit│ (path)  │
│                                                    │ vocabularies │ []      │
│                                                    │ isBookmark*  │         │
│                                                    │ note* (Java) │         │
│                                                    └──────────────┘         │
│                                                            │                │
│                                                            │ 1              │
│                                                            ▼ N              │
│                                                    ┌──────────────┐         │
│                                                    │  Vocabulary  │         │
│                                                    │──────────────│         │
│                                                    │ id: Int*     │         │
│                                                    │ shlokaId     │         │
│                                                    │ text: String │ (word)  │
│                                                    │ translation  │         │
│                                                    └──────────────┘         │
│                                                                              │
│   ┌──────────────┐         ┌──────────────┐                                 │
│   │    Quote     │         │   Bookmark   │ (iOS: separate table)           │
│   │──────────────│         │──────────────│                                 │
│   │ author       │         │ chapterOrder │                                 │
│   │ text         │         │ shlokaOrder  │                                 │
│   └──────────────┘         │ isDeleted    │                                 │
│                            └──────────────┘                                 │
│                                                                              │
│   * = client-only field (not from API)                                       │
└─────────────────────────────────────────────────────────────────────────────┘
```

## API Contract (Both Platforms)

**Base URL**: `http://app.bhagavadgitaapp.online/api/`

| Endpoint | Method | Request Body | Response |
|----------|--------|--------------|----------|
| `Data/Languages` | POST | `{}` | `{code: 0, data: [Language]}` |
| `Data/Books` | POST | `{ids: [int]}` | `{code: 0, data: [Book]}` |
| `Data/Chapters` | POST | `{bookId: int}` | `{code: 0, data: [Chapter]}` |
| `Data/Quotes` | POST | `{}` | `{code: 0, data: Quote}` |

**Response Wrapper**: All responses have `{code, data, message}` structure.

### Chapters Response (nested)

```json
{
  "code": 0,
  "data": [{
    "name": "Observing the Armies",
    "order": 1,
    "slokas": [{
      "name": "1.1",
      "text": "धृतराष्ट्र उवाच...",
      "transcription": "dhṛtarāṣṭra uvāca...",
      "translation": "Dhritarashtra said...",
      "comment": null,
      "order": 1,
      "audio": "/Files/xxx.mp3",
      "audioSanskrit": "/Files/yyy.mp3",
      "vocabularies": [
        {"text": "dhṛtarāṣṭraḥ", "translation": "Dhritarashtra"}
      ]
    }]
  }]
}
```

## Platform-Specific Differences

| Feature | iOS (Swift) | Android (Java) |
|---------|-------------|----------------|
| **Book download** | `DownloadInfo` struct | `STATUS_*` int constants |
| **User notes** | `UserComment` entity | `note` field in Sloka |
| **Bookmarks** | Separate `Bookmarks` table | `isBookmark` field + table |
| **DB wrapper** | `DbConnection`, `DbCommand` | `DbContext`, `DbSet<T>` |
| **ORM style** | Manual SQL | Annotation-based reflection |
| **API client** | `GitaRequestManager` | `DataService` + `GitaRequest` |

## Data Flows

### Content Loading Flow

```
App Start
    │
    ▼
Splash Screen
    │
    ├── Load Languages (API or cache)
    │
    ├── Load Books (API or cache)
    │
    ├── Download selected book chapters
    │   │
    │   └── Data/Chapters?bookId=N
    │       │
    │       └── Save to local DB:
    │           - chapters
    │           - slokas
    │           - vocabularies
    │
    └── Navigate to Contents
```

### Reading Flow

```
Contents Screen (Chapter List)
    │
    ├── Load chapters from local DB
    │
    └── On chapter tap → Shloka Screen
        │
        ├── Load shlokas from local DB
        │
        ├── Display: Sanskrit + Transliteration + Translation
        │
        ├── Vocabulary popup available
        │
        └── Audio playback (translation + Sanskrit)
```

### Bookmark/Note Flow

```
Shloka Screen
    │
    ├── Toggle bookmark → Save to Bookmarks table
    │
    └── Edit note → Save to local storage
```

## Database Schema (from CSV exports)

### Languages (4 records)
| Id | Name | Code |
|----|------|------|
| 1 | English | en |
| 2 | Русский | ru |
| 3 | Deutsch | de |
| 5 | Español | spa |

### Books (6 editions)
| Id | LanguageId | Name | Initials |
|----|------------|------|----------|
| 1 | 2 (ru) | Бхагавад Гита Жемчужина мудрости Востока | ШМ |
| 2 | 1 (en) | Bhagavad-gītā. The Hidden Treasure | SM |
| 5 | 1 (en) | Visvanath Cakravarti Thakur commentary | VC |
| 8 | 1 (en) | Srimad Bhagavad-Gītā As It Is (Prabhupada) | SP |
| 11 | 3 (de) | Die BHAGAVAD-GITA in Deutsch | SM |
| 14 | 5 (spa) | Śrīmad Bhagavad-Gītā | SM |

### Initials Legend
- **SM** = Sridhar Maharaj
- **VC** = Visvanath Cakravarti
- **SP** = Swami Prabhupada

### Content Statistics
| Entity | Records | Notes |
|--------|---------|-------|
| Languages | 4 | en, ru, de, spa |
| Books | 6 | 3 EN, 1 RU, 1 DE, 1 SPA |
| Chapters | 143 | 18 per book × editions |
| Slokas | ~700 | All verses of Bhagavad Gita |
| Vocabularies | ~5000 | Word-by-word breakdown |
| Quotes | ~150 | Multi-language |
| Devices | ~50000 | Analytics (mostly Android India) |

## Cross-Cutting Concerns

### Data Quality Issues
1. **ID Gaps**: Missing IDs in sequences (Language 4, Books 3,4,6,7...)
2. **Delimiter Inconsistency**: Some CSV use `;`, others `,`
3. **Multiline Content**: German chapter names have embedded newlines
4. **Audio Paths**: Reference `/Files/*.mp3` (external storage)

### Localization Approach
- Content language tied to Book edition
- UI language follows device locale
- Transliteration varies by target language (Cyrillic for RU, IAST for others)

### Offline Capability
- Full book content downloaded and cached locally
- Audio files downloaded separately
- Bookmarks/notes stored locally only

## Flow Recommendations

### Matched to Existing Flows

| Discovery | Matches Flow | Action |
|-----------|--------------|--------|
| Domain entities (7 types) | sdd-bhagavadgita-book-flutter-refactoring | APPEND: entity details |
| API endpoints (4 Data/*) | sdd-bhagavadgita-book-flutter-refactoring | APPEND: contract details |
| CSV data structure | sdd-gitabook-database | APPEND: legacy validation |
| Content hierarchy | sdd-gitabook-structure | CONFIRM: structure matches |

### No New Flows Needed

All discoveries map to existing SDD flows:
- Database design: `sdd-gitabook-database`
- Flutter migration: `sdd-bhagavadgita-book-flutter-refactoring`
- Content structure: `sdd-gitabook-structure`

---

## Source References

### Swift Files Analyzed
- `Gita/Model/DataAccess/DataClasses/Shloka.swift`
- `Gita/Model/DataAccess/DataClasses/Book.swift`
- `Gita/Model/DataAccess/DataClasses/Chapter.swift`
- `Gita/Model/DataAccess/DataClasses/Language.swift`
- `Gita/Model/DataAccess/DataClasses/Vocabulary.swift`
- `Gita/Model/DataAccess/DataClasses/Quote.swift`
- `Gita/Model/DataAccess/DataClasses/Bookmark.swift`
- `Gita/Model/DataAccess/GitaRequestManager.swift`

### Java Files Analyzed
- `com/ethnoapp/bgita/model/Sloka.java`
- `com/ethnoapp/bgita/model/Book.java`
- `com/ethnoapp/bgita/model/Chapter.java`
- `com/ethnoapp/bgita/model/Language.java`
- `com/ethnoapp/bgita/model/Vocabulary.java`
- `com/ethnoapp/bgita/model/Quote.java`
- `com/ethnoapp/bgita/server/DataService.java`

### DB Files Analyzed
- `Books/db_languages.csv`
- `Books/db_books.csv`
- `Books/db_chapters.csv`
- `Books/Gita_Slokas.csv`
- `Books/Gita_Vocabularies.csv`
- `Books/db_quoutes.csv`

---

*Created by /legacy analysis - 2026-04-29*
*Sources: legacy_bhagavadgita.book_swift, legacy_bhagavadgita.book_java, legacy_bhagavadgita.book.db*
