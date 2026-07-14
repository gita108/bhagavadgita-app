# Traversal State

> Persistent recursion stack for tree traversal. AI reads this to know where it is and what to do next.

## Mode

- **BFS** - Breadth-first analysis of legacy codebases

## Source Paths

- `legacy/legacy_bhagavadgita.book_swift` - iOS Swift app
- `legacy/legacy_bhagavadgita.book_java` - Android Java app
- `legacy/legacy_bhagavadgita.book.db` - Database CSV exports

## Focus (DFS only)

[none - BFS mode]

## Existing Flows Index

| Flow Path | Type | Topics | Key Decisions |
|-----------|------|--------|---------------|
| flows/sdd-gitabook-database/ | SDD | database, schema, languages, books, chapters, slokas, vocabulary, quotes | Single comment per sloka, Q&A system, audio paths only |
| flows/sdd-gitabook-structure/ | SDD | folder structure, translations, sanskrit, original/translated split | Language-first structure, separate files per sloka/translit |
| flows/sdd-gitabook-translation/ | SDD | batch translation, zh-CN, th, vocabulary | Priority TH and ZH-CN |
| flows/sdd-gitabook-generate-md/ | SDD | markdown generation, chinese, thai, hebrew | Book generation from chapters |
| flows/sdd-gitanjali-flutter-refactoring/ | SDD | gitanjali, xml, audio, bookmarks, flutter migration | Offline reader, bundled content |
| flows/sdd-bhagavadgita-book-flutter-refactoring/ | SDD | flutter, offline-first, sync, backend API, splash | Existing endpoints, stale-while-revalidate |

### NEW FLOWS CREATED (2026-04-29)

| Flow Path | Type | Topics | Key Decisions |
|-----------|------|--------|---------------|
| flows/adr-001-api-contract/ | ADR | API endpoints, POST, response wrapper | Maintain legacy contract |
| flows/adr-002-local-storage/ | ADR | SQLite, Drift, content/user separation | SQLite + Drift chosen |
| flows/adr-003-offline-first/ | ADR | offline, sync, stale-while-revalidate | Background sync pattern |
| flows/sdd-legacy-domain-model/ | SDD | 7 entities, Dart, JSON serialization | Client-side ID generation |
| flows/sdd-legacy-api-client/ | SDD | Dio, 4 endpoints, error handling | LegacyApiClient interface |
| flows/sdd-legacy-database-schema/ | SDD | Drift tables, DAOs, migrations | Cascade delete for content |
| flows/tdd-api-parsing/ | TDD | JSON parsing, nested structures, edge cases | 20+ test cases |
| flows/tdd-user-data-persistence/ | TDD | bookmarks, notes, soft delete, survival | 20+ test cases |

## Files Discovered - Swift (iOS)

| File | Domain | Key Entities |
|------|--------|--------------|
| Model/DataAccess/DataClasses/Shloka.swift | Domain Model | Shloka: id, chapterId, name, text, transcription, translation, comment, order, audio, audioSanskrit, vocabularies |
| Model/DataAccess/DataClasses/Book.swift | Domain Model | Book: id, languageId, name, initials, chaptersCount, isDownloaded |
| Model/DataAccess/DataClasses/Chapter.swift | Domain Model | Chapter: id, bookId, name, order, shlokas |
| Model/DataAccess/DataClasses/Language.swift | Domain Model | Language: id, name, code, isSelected |
| Model/DataAccess/DataClasses/Vocabulary.swift | Domain Model | Vocabulary: shlokaId, text, translation |
| Model/DataAccess/DataClasses/Quote.swift | Domain Model | Quote: author, text |
| Model/DataAccess/DataClasses/Bookmark.swift | Domain Model | Bookmark: chapterOrder, shlokaOrder, isDeleted |
| Model/DataAccess/GitaRequestManager.swift | API Client | Endpoints: Data/Languages, Data/Books, Data/Chapters, Data/Quotes |
| ViewControllers/SplashViewController.swift | UI | Splash screen |
| ViewControllers/ContentsViewController.swift | UI | Chapter/shloka navigation |
| ViewControllers/ShlokaViewController.swift | UI | Shloka detail view |
| ViewControllers/BookmarksViewController.swift | UI | Bookmarks list |
| ViewControllers/SettingsViewController.swift | UI | Settings |

## Files Discovered - Java (Android)

| File | Domain | Key Entities |
|------|--------|--------------|
| model/Sloka.java | Domain Model | Same fields as Swift + note field |
| model/Book.java | Domain Model | Same fields + download status states |
| model/Chapter.java | Domain Model | Same fields + slokasCount |
| model/Language.java | Domain Model | Same fields + checked flag |
| model/Vocabulary.java | Domain Model | Same fields |
| model/Quote.java | Domain Model | Same fields |
| server/DataService.java | API Client | Same endpoints as Swift |
| database/Db.java | Persistence | SQLite ORM wrapper |
| screens/SplashActivity.java | UI | Splash screen |
| screens/MainActivity.java | UI | Main navigation |
| fragments/SlokaFragment.java | UI | Shloka detail |
| fragments/BookmarksFragment.java | UI | Bookmarks |

## Files Discovered - DB Exports

| File | Delimiter | Records Est. | Domain |
|------|-----------|--------------|--------|
| Books/db_languages.csv | , | 4 | Localization |
| Books/db_books.csv | , | 6 | Content - Book editions |
| Books/db_chapters.csv | , | 143 | Content - Chapter metadata |
| Books/Gita_Slokas.csv | ; | 700+ | Content - Sanskrit verses |
| Books/Gita_Vocabularies.csv | ; | 5000+ | Content - Word definitions |
| Books/db_quoutes.csv | , | 150+ | Content - Quotes |
| devices/Gita_Devices.csv | ; | 50000+ | Analytics - User devices |

## Current Stack

```
/ (root)                           SYNTHESIZING <- current
├── swift-domain-model             DONE
├── java-domain-model              DONE
├── db-data-model                  DONE (from prior session)
├── api-contracts                  DONE
└── ui-flows                       DONE
```

## Stack Operations Log

| # | Operation | Node | Phase | Result |
|---|-----------|------|-------|--------|
| 1 | PUSH | / (root) | ENTERING | Started analysis |
| 2 | UPDATE | / (root) | EXPLORING | Identified 3 legacy sources |
| 3 | SPAWN | swift-domain-model | ENTERING | Swift model classes |
| 4 | UPDATE | swift-domain-model | DONE | 7 domain entities extracted |
| 5 | SPAWN | java-domain-model | ENTERING | Java model classes |
| 6 | UPDATE | java-domain-model | DONE | Same entities, minor differences |
| 7 | SPAWN | api-contracts | ENTERING | API endpoints |
| 8 | UPDATE | api-contracts | DONE | 4 Data/* endpoints |
| 9 | UPDATE | / (root) | SYNTHESIZING | Combining all insights |

## Current Position

- **Node**: / (root)
- **Phase**: SYNTHESIZING
- **Depth**: 0
- **Sources**: legacy_bhagavadgita.book_swift, legacy_bhagavadgita.book_java, legacy_bhagavadgita.book.db

## Key Findings Summary

### Domain Entities (iOS/Android parity)

| Entity | Swift | Java | DB Table | Notes |
|--------|-------|------|----------|-------|
| Language | Language | Language | Languages | id, name, code |
| Book | Book | Book | Books | id, languageId, name, initials, chaptersCount |
| Chapter | Chapter | Chapter | Chapters | id, bookId, name, order |
| Shloka | Shloka | Sloka | Slokas | id, chapterId, name, text, transcription, translation, comment, order, audio, audioSanskrit |
| Vocabulary | Vocabulary | Vocabulary | Vocabularies | id, shlokaId, text, translation |
| Quote | Quote | Quote | (quotes from API) | author, text |
| Bookmark | Bookmark | (in Sloka) | Bookmarks | chapterOrder, shlokaOrder, isDeleted |
| Note | (in UserComment) | (note in Sloka) | - | User notes per shloka |

### API Endpoints (both platforms)

| Endpoint | Method | Request | Response |
|----------|--------|---------|----------|
| Data/Languages | POST | {} | [Language] |
| Data/Books | POST | {ids: [int]} | [Book] |
| Data/Chapters | POST | {bookId: int} | [Chapter with Slokas and Vocabularies] |
| Data/Quotes | POST | {} | Quote |

### Platform Differences

| Aspect | iOS (Swift) | Android (Java) |
|--------|-------------|----------------|
| Download status | DownloadInfo struct | STATUS_* constants |
| User notes | UserComment entity | note field in Sloka |
| Bookmarks | Separate table | isBookmark field + Bookmarks table |
| Local DB | SQLite via DbHelper | SQLite via Db ORM |
| Audio files | Relative paths stored | Same |

## Visited Nodes

| Node Path | Summary | Flow Match |
|-----------|---------|------------|
| swift-domain-model | 7 entities: Language, Book, Chapter, Shloka, Vocabulary, Quote, Bookmark | sdd-bhagavadgita-book-flutter-refactoring |
| java-domain-model | Same entities with minor differences | sdd-bhagavadgita-book-flutter-refactoring |
| db-data-model | CSV exports matching domain model | sdd-gitabook-database |
| api-contracts | 4 Data/* endpoints | sdd-bhagavadgita-book-flutter-refactoring |

## Next Action

```
1. Update sdd-gitabook-database with legacy insights
2. Update sdd-bhagavadgita-book-flutter-refactoring with API/model insights
3. Log all updates
4. Mark traversal complete
```

---

## Phase Definitions

### ENTERING
- Just arrived at this node
- Create _node.md file
- Read relevant source files
- Form initial hypothesis

### EXPLORING
- Deep analysis of this node's scope
- Validate/refine hypothesis
- Identify what belongs here vs. children

### SPAWNING
- Identify child concepts that need deeper exploration
- Add children to Pending stack
- Children are LOGICAL concepts, not filesystem paths

### SYNTHESIZING
- All children completed (or no children)
- Combine insights from children
- Update this node's _node.md with full understanding

### EXITING
- Pop from stack
- Bubble up summary to parent
- Mark as visited

---

*Updated by /legacy recursive traversal - 2026-04-29*
