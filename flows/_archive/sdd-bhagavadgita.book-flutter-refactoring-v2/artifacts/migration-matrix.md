# Migration Matrix v2

## Scope

Source systems:
- `legacy/legacy_bhagavadgita.book_java`
- `legacy/legacy_bhagavadgita.book_swift`
- `legacy/legacy_bhagavadgita.book_db`

Target:
- `app/bhagavadgita.book` (Flutter/Drift)

## Entity Mapping

| Legacy Entity | Java | Swift | Legacy DB | Flutter Target | Notes |
|---|---|---|---|---|---|
| Language | `model/Language.java` | `DataClasses/Language.swift` | `db_languages.csv` | `languages` table + `LanguageDto` | `code` may be null, fallback generated in sync |
| Book | `model/Book.java` | `DataClasses/Book.swift` | `db_books.csv` | `books` table + `BookDto` | `chaptersCount` optional |
| Chapter | `model/Chapter.java` | `DataClasses/Chapter.swift` | `db_chapters.csv` | `chapters` table + `ChapterDto` | keeps `order -> position` |
| Shloka | `model/Sloka.java` | `DataClasses/Shloka.swift` | `Gita_Slokas.csv` | `slokas` table + `SlokaDto` | maps text/transcription/translation/comment/audio |
| Vocabulary | `model/Vocabulary.java` | `DataClasses/Vocabulary.swift` | `Gita_Vocabularies.csv` | `vocabularies` table + `VocabularyDto` | `text -> tokenText` |
| Quote | `model/Quote.java` | `DataClasses/Quote.swift` | `db_quoutes.csv` | `QuoteDto` (remote) | currently transient, no local table |
| Bookmark | bookmark flags/table | `BookmarkModel.swift` | n/a | `bookmarks` table | isolated from snapshot replace |
| Note | `note` in Sloka | `UserComment` model | n/a | `notes` table | isolated from snapshot replace |

## Compatibility Rules

1. Legacy backend contract remains unchanged (`Data/*` endpoints).
2. Content tables are replaced atomically on sync.
3. User tables (`bookmarks`, `notes`) are never touched by content replace.
4. Invalid or partial legacy rows are skipped during parse, not fatal for whole payload.
